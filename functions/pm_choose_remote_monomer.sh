## /* @function
 #  @usage pm_choose_remote_monomer <search-string>
 #
 #  @output true
 #
 #  @exports
 #  $_pm_remote_monomer_choice
 #  exports@
 #
 #  @description
 #  Given a <search-string>, remote branches are searched, matched, and returned.
 #  The user is then presented with a selectable list of the matched branches.
 #  description@
 #
 #  @notes
 #  - Because `grep` is used to filter branches, <search-string> must be
 #  `grep`-compatible.
 #  notes@
 #
 #  @examples
 #  pm_choose_remote_monomer JIRA-123
 #  examples@
 #
 #  @dependencies
 #  $PM_LAB_REPOS_PATH
 #  $_pm_active_lab
 #  `grep`
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_git.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - no arguments passed to function
 #  2 - lab repo could not be found
 #  4 - no matching remote branches
 #  returns@
 #
 #  @file functions/pm_choose_remote_monomer.sh
 ## */

function pm_choose_remote_monomer {
    pm_debug "pm_choose_remote_monomer( $@ )"

    declare -a branchArr
    local retVal=0 labRepo="${PM_LAB_REPOS_PATH}/${_pm_active_lab}"

    _pm_remote_monomer_choice=

    if [ $# == 0 ]; then
        pm_err "Not sure which remote monomer you want me to find..."
        retVal=1

    elif [ ! -d "${labRepo}/.git" ]; then
        pm_err "Could not locate remote monomers because laboratory repo can't be found:"
        pm_err "  ${labRepo}"
        retVal=2

    else
        branchArr=( `pm_git -v --lab="$_pm_active_lab" branch -r --list --no-color | grep --ignore-case "$@" | grep --invert-match ' -> '` )
        # pm_debug "branchArr[@] = ${branchArr[@]}"
        # pm_debug "\${branchArr[@]#*/} = ${branchArr[@]#*/}"
        if [ ${#branchArr[@]} == 0 ]; then
            echo "There were no matching remote branches for \"${@}\"."
            retVal=4

        else
            __menu "${branchArr[@]#*/}"
            [ -n "$_menu_sel_value" ] && _pm_remote_monomer_choice="$_menu_sel_value"
        fi
    fi

    export _pm_remote_monomer_choice

    pm_debug "_pm_remote_monomer_choice = ${_pm_remote_monomer_choice}"

    pm_debug "pm_choose_remote_monomer() -> ${retVal}"
    return $retVal
}
