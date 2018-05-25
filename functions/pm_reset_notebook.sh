## /* @function
 #  @usage pm_reset_notebook [<notebook-name>]
 #
 #  @output false
 #
 #  @description
 #  This function resets all of the polymers which are currently modified for the
 #  $_pm_active_notebook. If the operation is required within a specific notebook,
 #  the <notebook-name> can be passed as the only argument to this function. By
 #  default, $_pm_active_notebook is used.
 #  description@
 #
 #  @dependencies
 #  $_pm_active_notebook
 #  `egrep`
 #  functions/pm_debug.sh
 #  functions/pm_git.sh
 #  functions/pm_validate_notebook_repo.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - no notebook specified
 #  2 - target notebook is invalid (pm_validate_notebook_repo fails)
 #  4 - git reset operation failed
 #  returns@
 #
 #  @file functions/pm_reset_notebook.sh
 ## */

function pm_reset_notebook {
    pm_debug "pm_reset_notebook( $@ )"

    local retVal=0 nb="${@-$_pm_active_notebook}"

    if [ -z "$nb" ]; then
        retVal=1

    elif ! pm_validate_notebook_repo "$nb"; then
        retVal=2

    elif pm_git -v --nb="$nb" status --porcelain | egrep -q '.+'; then
        ## legacy (for reference)
        # for file in $(git status --porcelain -- lists/); do
        #     pm_git checkout -fq -- "lists/${file##*lists/}" || {
        #         pm_git clean -f -- lists/"${file##*lists/}"
        #     }
        # done

        # need to inspect untracked files for polys and unset the active
        # poly if it is getting cleaned
        if ! pm_git --nb="$nb" reset --hard HEAD && ! pm_git --nb="$nb" clean -f; then
            retVal=4
        fi
    fi

    pm_debug "pm_reset_notebook() -> ${retVal}"
    return $retVal
}
