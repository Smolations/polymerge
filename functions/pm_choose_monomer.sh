## /* @function
 #  @usage pm_choose_monomer [--prompt=<menu-prompt>]
 #
 #  @output true
 #
 #  @exports
 #  $_pm_monomer_choice
 #  exports@
 #
 #  @description
 #  There is often a need in polymerge for a user to select a monomer (contained in
 #  a single polymer). This mostly occurs when removing a monomer or re-ordering an
 #  active polymer. This function gathers up the monomers in the active polymer,
 #  presents them in a selectable list to the user, and then exports the chosen
 #  monomer in a variable for calling scripts to access.
 #  description@
 #
 #  @options
 #  --prompt=<menu-prompt>  This allows the user to set the prompt for the __menu
 #                          function which is used to display the selectable list
 #                          of monomers.
 #  options@
 #
 #  @examples
 #  pm_choose_monomer --prompt="Please choose a monomer to remove"
 #  examples@
 #
 #  @dependencies
 #  functions/pm_continue.sh
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_list_monomers.sh
 #  lib/functionsh/functions/__in_args.sh
 #  lib/functionsh/functions/__menu.sh
 #  dependencies@
 #
 #  @returns
 #  0 - user has made a valid choice, aborts, or there are no monomers to choose from
 #  1 - pm_list_monomers returned failure
 #  2 - no monomers to choose from
 #  4 - user aborted __menu
 #  8 - __menu error
 #  returns@
 #
 #  @file functions/pm_choose_monomer.sh
 ## */

function pm_choose_monomer {
    pm_debug "pm_choose_monomer( $@ )"

    local retVal=0 menuPrompt='--prompt=' monomers= listMonomersExitCode
    _pm_monomer_choice=

    pm_debug "_pm_active_polymer = ${_pm_active_polymer}"

    monomers=$( pm_list_monomers )
    listMonomersExitCode=$?

    pm_debug "pm_list_monomers returned:  ${listMonomersExitCode}"
    pm_debug "available monomers:  ${monomers}"

    __in_args prompt "$@" && menuPrompt+="${_arg_val}" || menuPrompt+="Choose a monomer branch"

    # this first condition may need to spoof success to avoid infinite loops
    if [ $listMonomersExitCode != 0 ]; then
        pm_err "Unable to retrieve list of monomers. See log for details."
        pm_continue
        retVal=1

    elif [ -z "$monomers" ]; then
        echo "There are no monomer branches to choose from."
        pm_continue
        retVal=2

    elif __menu "$menuPrompt" $monomers; then
        [ -n "$_menu_sel_value" ] && _pm_monomer_choice="$_menu_sel_value" || retVal=4

    else
        # keep this conditional at the top of this block
        if [ $? != 4 ]; then
            retVal=8
        fi
        pm_debug "__menu returned failure exit code"
    fi

    export _pm_monomer_choice

    pm_debug "_pm_monomer_choice = ${_pm_monomer_choice}"

    pm_debug "pm_choose_monomer() -> ${retVal}"
    return $retVal
}
