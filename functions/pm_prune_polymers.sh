## /* @function
 #  @usage pm_prune_polymers
 #
 #  @output true
 #
 #  @description
 #  This function will cycle through the polymers in the active notebook and remove
 #  any polymer branches that are currently merged into `master` in the
 #  corresponding lab repo. Each polymer and the resultant action for that polymer
 #  are displayed for the user to see.
 #  description@
 #
 #  @dependencies
 #  $PM_LAB_NOTEBOOKS_PATH
 #  $PM_POLYMERS_FOLDER_NAME
 #  $_pm_active_notebook
 #  $_pm_active_lab
 #  `grep`
 #  `rm`
 #  functions/pm_debug.sh
 #  functions/pm_git.sh
 #  functions/pm_list_polymers.sh
 #  functions/pm_set_active_polymer.sh
 #  functions/pm_update_repo.sh
 #  lib/functionsh/functions/__yes_no.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - problem unsetting value for active polymer
 #  2 - unable to remove polymer definition file
 #  returns@
 #
 #  @file functions/pm_prune_polymers.sh
 ## */

function pm_prune_polymers {
    pm_debug "pm_prune_polymers( $@ )"

    local retVal=0 poly
    local polymersPath="${PM_LAB_NOTEBOOKS_PATH}/${_pm_active_notebook}/${PM_POLYMERS_FOLDER_NAME}"

    pm_update_repo --lab="$_pm_active_lab"
    echo
    echo "NOTE: If you end up removing the currently active polymer"
    echo "you will need to choose a new active polymer."
    echo

    # if the list being refreshed happens to be the active list, prompt the
    # user to choose a new active list once the refreshing is finished.
    for poly in $( pm_list_polymers ); do
        pm_debug "Checking poly: [${poly}]"
        echo

        # make sure polymer (branch) exists
        if pm_git -v --lab="$_pm_active_lab" branch -r | grep -q "origin/${poly}"; then

            # check if poly has been merged into master
            if pm_git -v --lab="$_pm_active_lab" branch -r --contains "origin/${poly}" | grep -q 'origin/master'; then

                __yes_no --default=y "${BY}\`${poly}\`${Q} is in \`master\`. Remove this polymer from your notebook"
                if [ $_yes ]; then
                    if [ "$poly" == "$_pm_active_polymer" ]; then
                        pm_set_active_polymer '' || retVal=1
                    fi
                    rm -f "${polymersPath}/${poly}" || retVal=2
                fi

            else
                echo "  ${BY}\`${poly}\`${X} not merged into \`master\`. Skipping..."
            fi

        else
            echo "  ${BY}\`${poly}\`${X} does not exist on the remote yet. Skipping..."
        fi
    done

    pm_debug "pm_prune_polymers() -> ${retVal}"
    return $retVal
}
