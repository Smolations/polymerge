## /* @function
 #  @usage pm_notebook_has_remote <notebook-name>
 #
 #  @output false
 #
 #  @description
 #  Check to see if a given notebook has a remote configured.
 #  description@
 #
 #  @examples
 #  if pm_notebook_has_remote "my-notebook"; then
 #      ...
 #  fi
 #  examples@
 #
 #  @dependencies
 #  $PM_LAB_NOTEBOOKS_PATH
 #  functions/pm_debug.sh
 #  functions/pm_git.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution; notebook has a remote
 #  1 - no arguments passed to function
 #  2 - notebook repo couldn't be found
 #  4 - notebook has no remote
 #  returns@
 #
 #  @file functions/pm_notebook_has_remote.sh
 ## */

function pm_notebook_has_remote {
    pm_debug "pm_notebook_has_remote( $@ )"

    local retVal=4 nb="$@" remote
    local nbPath="${PM_LAB_NOTEBOOKS_PATH}/${nb}/.git"

    pm_debug "nbPath = $nbPath"

    if [ $# == 0 ]; then
        retVal=1

    elif [ ! -d "$nbPath" ]; then
        retVal=2

    else
        remote=$( pm_git -v --nb="$nb" remote )
        [ -n "$remote" ] && retVal=0
    fi

    pm_debug "pm_notebook_has_remote() -> ${retVal}"
    return $retVal
}
