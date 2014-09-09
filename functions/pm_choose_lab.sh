## /* @function
 #  @usage pm_choose_lab [--filter=<pattern>]
 #
 #  @output true
 #
 #  @exports
 #  $_pm_lab_choice
 #  exports@
 #
 #  @description
 #  There is often a need in polymerge for a user to select a lab. This mostly
 #  occurs when removing a lab or choosing an active lab. This function gathers up
 #  the available labs, presents them in a selectable list to the user, and then
 #  exports the chosen lab in a variable for calling scripts to access. This
 #  function takes an option to filter out specific labs from the list the user can
 #  choose from.
 #  description@
 #
 #  @options
 #  --filter=<pattern>      If any projects should be removed from the list, specify
 #                          an egrep-compatible pattern to match those labs.
 #  options@
 #
 #  @notes
 #  - Labs are validated before adding them to the list so that a chosen lab can
 #  always be expected to be valid.
 #  notes@
 #
 #  @dependencies
 #  `egrep`
 #  functions/pm_get_notebook_from_lab.sh
 #  functions/pm_list_labs.sh
 #  functions/pm_validate_lab.sh
 #  lib/functionsh/functions/__in_args.sh
 #  lib/functionsh/functions/__menu.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - no laboratories to choose from
 #  returns@
 #
 #  @file functions/pm_choose_lab.sh
 ## */

function pm_choose_lab {
    pm_debug "pm_choose_lab( $@ )"

    declare -a labs
    local retVal=0 pattMatch entry nb filterPatt

    _pm_lab_choice=

    if [ $# == 1 ] && __in_args filter "$1"; then
        filterPatt="$_arg_val"
        pm_debug "filterPatt = $filterPatt"
    fi

    for entry in $( pm_list_labs ); do
        pm_debug "lab repo: $entry"
        pattMatch=

        [ -n "$filterPatt" ] && egrep -q "$filterPatt" <<< "$entry" && pattMatch=true

        if [ ! $pattMatch ] && pm_validate_lab "$entry"; then
            nb=$( pm_get_notebook_from_lab "$entry" )
            labs+=( "${entry}  (notebook: ${nb})" )
        fi
    done

    if (( ${#labs[@]} > 0 )); then
        __menu --prompt="Select a laboratory" "${labs[@]}"
        [ -n "$_menu_sel_value" ] && _pm_lab_choice="${_menu_sel_value%% *}"

    else
        # no labs
        pm_debug "No laboratories to choose from."
        retVal=1
    fi

    export _pm_lab_choice

    pm_debug "_pm_lab_choice = ${_pm_lab_choice}"

    pm_debug "pm_choose_lab() -> ${retVal}"
    return $retVal
}
