## /* @function
 #  @usage pm_validate_notebook_repo <notebook-name>
 #
 #  @output false
 #
 #  @description
 #  This function determines if the given <notebook-name> represents a valid
 #  notebook. It makes sure that it is associated with a valid git repository, and
 #  that the defined file structure is adhered to.
 #  description@
 #
 #  @dependencies
 #  $PM_LAB_NOTEBOOKS_PATH
 #  $PM_LAB_REPO_FILE_NAME
 #  $PM_POLYMERS_FOLDER_NAME
 #  functions/pm_debug.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - no arguments passed to function
 #  2 - no folder with <notebook-name> found in $PM_LAB_NOTEBOOKS_PATH
 #  4 - notebook is not a git repository
 #  8 - notebook is missing lab repo file
 #  16 - notebook is missing folder to contain polymers
 #  returns@
 #
 #  @file functions/pm_validate_notebook_repo.sh
 ## */

function pm_validate_notebook_repo {
    pm_debug "pm_validate_notebook_repo( $@ )"

    local retVal=0 nb="$@"
    local nbPath="${PM_LAB_NOTEBOOKS_PATH}/${nb}"

    if [ $# == 0 ]; then
        retVal=1

    elif [ ! -d "${nbPath}" ]; then
        retVal=2

    elif [ ! -d "${nbPath}/.git" ]; then
        retVal=4

    elif [ ! -f "${nbPath}/${PM_LAB_REPO_FILE_NAME}" ]; then
        retVal=8

    elif [ ! -d "${nbPath}/${PM_POLYMERS_FOLDER_NAME}" ]; then
        retVal=16
    fi

    pm_debug "pm_validate_notebook_repo() -> ${retVal}"
    return $retVal
}
