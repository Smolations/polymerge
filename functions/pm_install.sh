## /* @function
 #  @usage pm_install
 #
 #  @output false
 #
 #  @description
 #  A number of files and folders need to exist in order for polymerge to work
 #  properly. This function is the function responsible for creating those files
 #  and folders.
 #  description@
 #
 #  @dependencies
 #  $PM_ACTIVE_LAB_FILE_PATH
 #  $PM_DEFAULT_MASTHEAD
 #  $PM_HOME_PATH
 #  $PM_LAB_NOTEBOOKS_PATH
 #  $PM_LAB_REPOS_PATH
 #  $PM_LOG_PATH
 #  $PM_MASTHEAD_PATH
 #  $PM_VAR_PATH
 #  `mkdir`
 #  `touch`
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_log.sh
 #  functions/pm_set_masthead.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - failed to create one or more paths
 #  returns@
 #
 #  @file functions/pm_install.sh
 ## */

function pm_install {
    pm_debug "pm_install( $@ )"

    declare -a paths
    local retVal=0 i

    paths+=( "$PM_HOME_PATH" )
    paths+=( "$PM_LAB_NOTEBOOKS_PATH" )
    paths+=( "$PM_LAB_REPOS_PATH" )
    paths+=( "$PM_VAR_PATH" )
    paths+=( "$PM_LOG_PATH" )

    for (( i = 0; i < ${#paths[@]}; i++ )); do

        if [ ! -d "${paths[$i]}" ]; then
            if ! mkdir -p "${paths[$i]}" && pm_log "pm_install() - Path created:  ${paths[$i]}"; then
                pm_err -q "pm_install() - Failed to create path:  ${paths[$i]}"
                retVal=1
            fi

        else
            pm_debug "pm_install() - Install path exists:  ${paths[$i]}"
        fi

    done

    touch "$PM_ACTIVE_LAB_FILE_PATH"
    touch "$PM_MASTHEAD_PATH"
    pm_set_masthead "$PM_DEFAULT_MASTHEAD"

    pm_debug "pm_install() -> ${retVal}"
    return $retVal
}
