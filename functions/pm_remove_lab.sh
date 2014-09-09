## /* @function
 #  @usage pm_remove_lab <lab-name>
 #
 #  @output true
 #
 #  @description
 #  This function will remote a laboratory completely. This includes it's associated
 #  notebook repo, as well as any associated values in $PM_VAR_PATH. Before any
 #  removal occurs, the user is presented with a comprehensive list of the files and
 #  folders to be removed and is asked to confirm deletion.
 #  description@
 #
 #  @dependencies
 #  $PM_ACTIVE_POLYMER_FILE_SUFFIX
 #  $PM_LAB_NOTEBOOKS_PATH
 #  $PM_LAB_REPOS_PATH
 #  $PM_VAR_PATH
 #  $_pm_active_lab
 #  `rm`
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_get_notebook_from_lab.sh
 #  functions/pm_set_active_lab.sh
 #  functions/pm_validate_lab.sh
 #  lib/functionsh/functions/__yes_no.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - no arguments passed to function
 #  2 - invalid <lab-name> passed to function
 #  4 - unable to get notebook from given <lab-name>
 #  16 - remove operation failed
 #  returns@
 #
 #  @file functions/pm_remove_lab.sh
 ## */

function pm_remove_lab {
    pm_debug "pm_remove_lab( $@ )"

    declare -a killFiles
    local retVal=0 lab="$@" nb activePolymerFile labRepoPath labNotebookPath filePath

    if [ $# == 0 ]; then
        retVal=1

    elif ! pm_validate_lab "$lab"; then
        retVal=2

    else
        nb=$( pm_get_notebook_from_lab "$lab" )
        if [ -z "$nb" ]; then
            retVal=4
        fi
    fi

    if [ $retVal == 0 ]; then
        activePolymerFile="${PM_VAR_PATH}/${lab}${PM_ACTIVE_POLYMER_FILE_SUFFIX}"
        [ -f "$activePolymerFile" ] && killFiles+=( "$activePolymerFile" )

        labRepoPath="${PM_LAB_REPOS_PATH}/${lab}"
        [ -d "$labRepoPath" ] && killFiles+=( "$labRepoPath" )

        labNotebookPath="${PM_LAB_NOTEBOOKS_PATH}/${nb}"
        [ -d "$labNotebookPath" ] && killFiles+=( "$labNotebookPath" )

        if (( ${#killFiles[@]} > 0 )); then
            echo
            echo "The following files will be removed:"
            for filePath in "${killFiles[@]}"; do echo "  ${filePath}"; done
            echo
            if [ "$_pm_active_lab" == "$lab" ]; then
                echo "Also, you have chosen to remove a laboratory which is currently"
                echo "active. You will need to choose a new active laboratory once"
                echo "this operation is complete."
                echo
            fi
            __yes_no --default=n "Continue and delete laboratory"

            if [ $_yes ]; then
                [ "$_pm_active_lab" == "$lab" ] && pm_set_active_lab ''

                for filePath in "${killFiles[@]}"; do
                    pm_debug "removing file:  $filePath"
                    rm -rf "$filePath" || retVal=16
                done
                echo
                if [ $retVal == 0 ]; then
                    echo "The laboratory was removed successfully!"
                else
                    pm_err "There were problems removing one or more files. See log for details."
                fi

            else
                echo
                echo "The laboratory will not be removed."
            fi
        fi
    fi

    pm_debug "pm_remove_lab() -> ${retVal}"
    return $retVal
}
