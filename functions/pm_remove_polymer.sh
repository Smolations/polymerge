## /* @function
 #  @usage pm_remove_polymer <polymer-name>
 #
 #  @output true
 #
 #  @description
 #  Remove a polymer definition from the active notebook. Deletion confirmation is
 #  presented to the user before deletion occurs.
 #  description@
 #
 #  @dependencies
 #  `rm`
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_get_polymer_path.sh
 #  functions/pm_set_active_polymer.sh
 #  lib/functionsh/functions/__yes_no.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - no arguments passed to function
 #  2 - unable to locate polymer with given <polymer-name>
 #  4 - delete operation failed
 #  returns@
 #
 #  @file functions/pm_remove_polymer.sh
 ## */

function pm_remove_polymer {
    pm_debug "pm_remove_polymer( $@ )"

    local retVal=0 poly="$@" polys=
    local polyPath=$( pm_get_polymer_path "$poly" )

    if [ $# == 0 ]; then
        pm_err "There was a glitch in the--nevermind. See log for details."
        retVal=1

    elif [ ! -f "$polyPath" ]; then
        pm_err "Unable to remove polymer because it cannot be found: ${polyPath}"
        retVal=2

    else
        if [ "$poly" == "$_pm_active_polymer" ]; then
            echo "The polymer you selected is currently active. If you remove it, you"
            echo "will have to choose a new active polymer."
            echo
        fi

        __yes_no --default=n "Are you sure you want to remove \`${poly}\`"

        if [ $_yes ]; then
            if rm -f "$polyPath"; then
                pm_debug "removed polymer:  ${poly}"
                [ "$poly" == "$_pm_active_polymer" ] && pm_set_active_polymer ''

            else
                echo
                pm_err "Could not delete the file."
                retVal=4
            fi
        fi
    fi

    pm_debug "pm_remove_polymer() -> ${retVal}"
    return $retVal
}
