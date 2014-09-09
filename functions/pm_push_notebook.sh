## /* @function
 #  @usage pm_push_notebook
 #
 #  @output true
 #
 #  @description
 #  This function handles pushing any notebook changes out to the team. If changes
 #  are found, the user will be prompted to make sure that pushing is the desired
 #  action.
 #  description@
 #
 #  @dependencies
 #  $PM_POLYMERS_FOLDER_NAME
 #  $_pm_active_notebook
 #  `git`
 #  functions/pm_debug.sh
 #  functions/pm_git.sh
 #  functions/pm_polymers_changed.sh
 #  lib/functionsh/functions/__yes_no.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  returns@
 #
 #  @file functions/pm_push_notebook.sh
 ## */

function pm_push_notebook {
    pm_debug "pm_push_notebook( $@ )"

    local retVal=0

    # if there are no notebook changes to push, there's no need to do anything
    if ! pm_polymers_changed "$_pm_active_notebook"; then
        echo "There are no notebook changes to push!"

    else
        echo "Preparing to ${A}push${X} notebook changes out to team:"
        echo
        echo "${O}$ git status --porcelain -- \"${PM_POLYMERS_FOLDER_NAME}/\"${X}"
        pm_git -v --nb="$_pm_active_notebook" status --porcelain -- "${PM_POLYMERS_FOLDER_NAME}/"
        echo
        echo

        __yes_no --default=y "${A}Commit${Q} notebook changes listed above"
        echo
        if [ $_yes ]; then
            echo "Please wait..."
            pm_git --nb="$_pm_active_notebook" add -A "${PM_POLYMERS_FOLDER_NAME}/"
            pm_git --nb="$_pm_active_notebook" commit -m "\"($( git config --get user.name ) via polymerge) updated polymer branch(es)\""
            pm_git --nb="$_pm_active_notebook" push origin "$( pm_git -v --nb="$_pm_active_notebook" get-current-branch )"
            echo
            echo "Notebook changes ${A}pushed${X}!"

        else
            echo "Notebook changes were ${Q}NOT${X} pushed to the server."
        fi
    fi

    pm_debug "pm_push_notebook() -> ${retVal}"
    return $retVal
}
