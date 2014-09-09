## /* @function
 #  @usage pm_info
 #
 #  @output true
 #
 #  @description
 #  This simply outputs all of the global variables used by polymerge, along with
 #  any information about installed laboratories. The default behavior is to dump
 #  the information into a file and feed that file to `less`. If a temp file is
 #  unable to be created for some reason, the information is simply echoed to
 #  stdout.
 #  description@
 #
 #  @dependencies
 #  `cat`
 #  `exec`
 #  `less`
 #  `printf`
 #  `rm`
 #  functions/pm_get_notebook_from_lab.sh
 #  functions/pm_git.sh
 #  functions/pm_list_labs.sh
 #  functions/pm_mktemp.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  returns@
 #
 #  @file functions/pm_info.sh
 ## */

function pm_info {
    local printPatt=' %-30s    %-s\n' lab nb

    if pm_mktemp; then
        exec 6>&1
        exec > "$_pm_temp_file"
    fi

    echo
    cat "$PM_MASTHEAD_PATH"
    echo
    echo
    echo "These are core path variables. These should NOT be overridden."
    echo "--------------------------------------------------------------"
    printf "$printPatt" "\$PM_HOME_PATH" "$PM_HOME_PATH"
    printf "$printPatt" "\$PM_LAB_NOTEBOOKS_PATH" "$PM_LAB_NOTEBOOKS_PATH"
    printf "$printPatt" "\$PM_LAB_REPOS_PATH" "$PM_LAB_REPOS_PATH"
    printf "$printPatt" "\$PM_LOG_PATH" "$PM_LOG_PATH"
    printf "$printPatt" "\$PM_VAR_PATH" "$PM_VAR_PATH"
    echo
    echo "These are configuration variables, also NOT to be overridden."
    echo "-------------------------------------------------------------"
    printf "$printPatt" "\$PM_UPDATE_BRANCH" "$PM_UPDATE_BRANCH"
    printf "$printPatt" "\$PM_LAB_REPO_FILE_NAME" "$PM_LAB_REPO_FILE_NAME"
    printf "$printPatt" "\$PM_POLYMERS_FOLDER_NAME" "$PM_POLYMERS_FOLDER_NAME"
    printf "$printPatt" "\$PM_ACTIVE_LAB_FILE_NAME" "$PM_ACTIVE_LAB_FILE_NAME"
    printf "$printPatt" "\$PM_ACTIVE_POLYMER_FILE_SUFFIX" "$PM_ACTIVE_POLYMER_FILE_SUFFIX"
    printf "$printPatt" "\$PM_DEFAULT_MASTHEAD" "$PM_DEFAULT_MASTHEAD"
    echo
    echo "These are paths derived from the first two sections above. Do NOT override."
    echo "---------------------------------------------------------------------------"
    printf "$printPatt" "\$PM_ACTIVE_LAB_FILE_PATH" "$PM_ACTIVE_LAB_FILE_PATH"
    printf "$printPatt" "\$PM_LOG_FILE_PATH" "$PM_LOG_FILE_PATH"
    printf "$printPatt" "\$PM_MASTHEAD_PATH" "$PM_MASTHEAD_PATH"
    echo
    echo "This are configuration variables which CAN be overridden by the user."
    echo "---------------------------------------------------------------------"
    printf "$printPatt" "\$PM_NOTEBOOK_FETCH_DELAY" "$PM_NOTEBOOK_FETCH_DELAY (seconds)"
    printf "$printPatt" "\$PM_LOG_MAX_SIZE" "$PM_LOG_MAX_SIZE (kb)"
    printf "$printPatt" "\$PM_LOG_FILE_NAME" "$PM_LOG_FILE_NAME"
    echo
    echo
    echo "Laboratory and notebook repositories:"
    echo "-------------------------------------"

    for lab in `pm_list_labs`; do
        nb=$( pm_get_notebook_from_lab "$lab" )

        echo
        echo "  LABORATORY:  ${lab}"
        echo "      - Lab Repo:"
        echo "          (on disk)  ${PM_LAB_REPOS_PATH}/${lab}"
        echo "          (remote)   $( pm_git -v --lab="$lab" ls-remote --get-url )"
        echo "      - Notebook Repo:"
        echo "          (on disk)  ${PM_LAB_NOTEBOOKS_PATH}/${nb}"
        echo "          (remote)   $( pm_git -v --nb="$nb" ls-remote --get-url )"
        echo
    done

    if [ -n "$_pm_temp_file" ]; then
        exec 1>&6 6>&-
        less --raw-control-chars "$_pm_temp_file"
        rm -f "$_pm_temp_file"
    fi
}
