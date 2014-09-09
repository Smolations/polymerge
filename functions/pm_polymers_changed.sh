## /* @function
 #  @usage pm_polymers_changed <notebook-name>
 #
 #  @output true (on error)
 #
 #  @description
 #  This function tells the user whether or not any of the polymers have changed
 #  since the last time polymerge checked.
 #  description@
 #
 #  @notes
 #  - This function is meant to be used in conditionals. It is not useful elsewhere.
 #  notes@
 #
 #  @examples
 #  if pm_polymers_changed; then
 #      echo "We have changes!"
 #  fi
 #  examples@
 #
 #  @dependencies
 #  $PM_POLYMERS_FOLDER_NAME
 #  `egrep`
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_git.sh
 #  functions/pm_validate_notebook_repo.sh
 #  dependencies@
 #
 #  @returns
 #  0 - polymers have changed
 #  1 - invalid <notebook-name> specified
 #  2 - polymers have not changed
 #  returns@
 #
 #  @file functions/pm_polymers_changed.sh
 ## */

function pm_polymers_changed {
    pm_debug "pm_polymers_changed( $@ )"

    # show the short version of git status
    local retVal=2 nb="$@"

    if ! pm_validate_notebook_repo "$nb"; then
        pm_err "Cannot determine if notebook polymer definitions have changed."
        pm_err "Invalid notebook specified: [${nb}]"
        retVal=1

    else
        pm_git -v --nb="$nb" status --porcelain -- "${PM_POLYMERS_FOLDER_NAME}/" | egrep -q '.+' && retVal=0
    fi

    pm_debug "pm_polymers_changed() -> ${retVal}"
    return $retVal
}
