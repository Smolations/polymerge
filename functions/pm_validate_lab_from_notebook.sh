## /* @function
 #  @usage pm_validate_lab_from_notebook <notebook-name> [<notebook-name> [...]]
 #
 #  @output false
 #
 #  @description
 #  When working with labs, polymerge needs a way to determine if a given lab is
 #  valid. This function will take the given <notebook-name> and determine if both a
 #  lab repo and a notebook repo exist for that name. A failure exit code is
 #  returned if no argumewnts are passed or if some part of the validation fails.
 #
 #  It should be evident from the @usage that multiple labs can be validated at
 #  the same time. In this case, if even ONE of the given notebooks or labs is
 #  invalid, this function will return failure.
 #  description@
 #
 #  @examples
 #  pm_validate_lab_from_notebook "my-first-notebook" "my-second-notebook"
 #  examples@
 #
 #  @dependencies
 #  $PM_LAB_NOTEBOOKS_PATH
 #  $PM_LAB_REPOS_PATH
 #  $PM_LAB_REPO_FILE_NAME
 #  `cat`
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_validate_notebook_repo.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - no arguments passed to function
 #  2 - notebook with given <notebook-name> is invalid
 #  4 - could not parse lab repo name from lab repo file in notebook
 #  8 - lab repo is not a valid git repo
 #  returns@
 #
 #  @file functions/pm_validate_lab_from_notebook.sh
 ## */

function pm_validate_lab_from_notebook {
    pm_debug "pm_validate_lab_from_notebook( $@ )"

    local retVal=0 nb nbPath labRepoFile labRepo

    if [ $# == 0 ]; then
        pm_err -q "pm_validate_lab_from_notebook() expects at least one argument."
        retVal=1

    else
        for nb in $@; do
            pm_debug "validating notebook: ${nb}"

            nbPath="${PM_LAB_NOTEBOOKS_PATH}/${nb}"
            labRepoFile="${nbPath}/${PM_LAB_REPO_FILE_NAME}"

            # pm_debug "nbPath = ${nbPath}"
            # pm_debug "labRepoFile = ${labRepoFile}"

            # [ ! -d "${nbPath}/.git" ] && retVal=2
            # [ ! -f "${labRepoFile}" ] && retVal=4
            # [ ! -d "${nbPath}/${PM_POLYMERS_FOLDER_NAME}" ] && pm_log "WARNING: no folder for polymers"

            if pm_validate_notebook_repo "$nb"; then
                labRepo=$( cat "${labRepoFile}" )
                labRepo="${labRepo##*/}"
                labRepo="${labRepo%.git}"

                pm_debug "labRepo = ${labRepo}"

                [ -z "$labRepo" ] && retVal=4
                [ ! -d "${PM_LAB_REPOS_PATH}/${labRepo}/.git" ] && retVal=8

            else
                pm_err "Invalid notebook: ${nb}"
                retVal=2
            fi

            [ $retVal != 0 ] && break
        done
    fi

    pm_debug "pm_validate_lab_from_notebook() -> ${retVal}"
    return $retVal
}
