## /* @function
 #  @usage pm_choose_polymer
 #
 #  @output true
 #
 #  @exports
 #  $_pm_polymer_choice
 #  exports@
 #
 #  @description
 #  There is often a need in polymerge for a user to select a polymer. This mostly
 #  occurs when removing a polymer or choosing an active polymer. This function
 #  gathers up the polymers in the active notebook, presents them in a selectable
 #  list to the user, and then exports the chosen polymer in a variable for calling
 #  scripts to access.
 #  description@
 #
 #  @dependencies
 #  functions/pm_continue.sh
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_list_polymers.sh
 #  lib/functionsh/functions/__menu.sh
 #  dependencies@
 #
 #  @returns
 #  0 - user has made a valid choice
 #  1 - pm_list_polymers returned failure
 #  2 - no polymer to switch to
 #  4 - user aborted __menu
 #  8 - __menu error
 #  returns@
 #
 #  @file functions/pm_choose_polymer.sh
 ## */

function pm_choose_polymer {
    pm_debug "pm_choose_polymer( $@ )"

    local retVal=0 polymers= listPolymersExitCode
    _pm_polymer_choice=

    polymers=$( pm_list_polymers )
    listPolymersExitCode=$?

    pm_debug "listPolymersExitCode = ${listPolymersExitCode}"
    pm_debug "available polymers:  ${polymers}"

    if [ $listPolymersExitCode != 0 ]; then
        retVal=1
        pm_err "Unable to retrieve list of polymers. See log for details."
        pm_continue

    elif [ -z "$polymers" ]; then
        retVal=2
        echo "There are no polymer definitions in the currently active notebook."
        pm_continue

    elif __menu --prompt="Choose a polymer branch" $polymers; then
        [ -n "$_menu_sel_value" ] && _pm_polymer_choice="$_menu_sel_value" || retVal=4

    else
        # if __menu returns 4, that means the choice wasnt understood. give
        # the user another chance. only Enter officially aborts. this check
        # MUST be the first thing in this block to be effective.
        if [ $? != 4 ]; then
            retVal=8
        fi
        pm_debug "__menu returned failure exit code"
    fi

    export _pm_polymer_choice

    pm_debug "_pm_polymer_choice = ${_pm_polymer_choice}"

    pm_debug "pm_choose_polymer() -> ${retVal}"
    return $retVal
}
