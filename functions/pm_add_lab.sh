## /* @function
 #  @usage pm_add_lab <notebook-url>
 #
 #  @output true
 #
 #  @description
 #  This function is responsible for taking a notebook repository URL
 #  and cloning it within polymerge's PM_LAB_NOTEBOOKS_PATH folder. It
 #  also parses the laboratory.repo file and clones the associated lab
 #  repo into polymerge's PM_LAB_REPOS_PATH. Each URL can be any URL
 #  which the `git clone` command accepts. This includes both SSH and
 #  HTTP URLs.
 #  description@
 #
 #  @notes
 #  - The provided <notebook-url> can technically be a file path to a
 #  local repository in case a user wishes to manage his/her own branch
 #  management workflow.
 #  notes@
 #
 #  @dependencies
 #  $PM_LAB_NOTEBOOKS_PATH
 #  $PM_LAB_REPOS_PATH
 #  $PM_LAB_REPO_FILE_NAME
 #  `cat`
 #  `git`
 #  `mkdir`
 #  `touch`
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - no arguments passed to function
 #  2 - notebook repo failed to clone
 #  4 - missing laboratory.repo file in notebook repo
 #  8 - laboratory repo failed to clone
 #  returns@
 #
 #  @file functions/pm_add_lab.sh
 ## */

function pm_add_lab {
    pm_debug "pm_add_lab( $@ )"

    local retVal=0

    if [ $# == 0 ]; then
        retVal=1

    else
        notebookRepoUrl="$@"
        notebookRepoName=${notebookRepoUrl##*/}
        notebookRepoName=${notebookRepoName%.git}
        notebookRepoPath="${PM_LAB_NOTEBOOKS_PATH}/${notebookRepoName}"
        labRepoFile="${notebookRepoPath}/${PM_LAB_REPO_FILE_NAME}"

        pm_debug "notebookRepoUrl = $notebookRepoUrl"
        pm_debug "notebookRepoName = $notebookRepoName"
        pm_debug "notebookRepoPath = $notebookRepoPath"

        # notebook repo clone attempt
        echo "Cloning notebook repository..."
        echo
        if ! git clone "$notebookRepoUrl" "$notebookRepoPath"; then
            pm_err "Unable to clone notebook repository."
            retVal=2

        # check for existence (and contents) of lab repo file
        elif [ ! -s "$labRepoFile" ]; then
            pm_err "Laboratory repository file ($labRepoFile) is missing or empty in notebook repository."
            # rm -rf "$notebookRepoPath"
            retVal=4
        fi
    fi

    if [ $retVal == 0 ]; then
        echo
        echo "Cloning laboratory repository..."
        echo
        labRepoUrl=$( cat "$labRepoFile" )
        labRepoName=${labRepoUrl##*/}
        labRepoName=${labRepoName%.git}
        labRepoPath="${PM_LAB_REPOS_PATH}/${labRepoName}"

        pm_debug "labRepoUrl  = $labRepoUrl"
        pm_debug "labRepoName = $labRepoName"
        pm_debug "labRepoPath = $labRepoPath"

        # lab repo clone attempt
        if ! git clone "$labRepoUrl" "$labRepoPath"; then
            echo
            pm_err "Unable to clone laboratory repository."
            rm -rf "$notebookRepoPath"
            retVal=8

        else
            # create empty file for this project's active polymer
            touch "${PM_VAR_PATH}/${labRepoName}${PM_ACTIVE_POLYMER_FILE_SUFFIX}"

            # create directory where polymers are located if it doesnt exist (and commit)
            polyDir="${notebookRepoPath}/${PM_POLYMERS_FOLDER_NAME}"
            if [ ! -d "$polyDir" ]; then
                echo
                echo " \`- Creating/Saving folder for polymers..."
                mkdir "$polyDir"
                touch "$polyDir/.gitkeep"
                pm_git --nb="$notebookRepoName" add --all .
                pm_git --nb="$notebookRepoName" commit -m "'(polymerge) Added polymers/ directory.'"
                pm_git --nb="$notebookRepoName" push origin HEAD
            fi

            echo
            echo "Laboratory added successfully!"
        fi
    fi

    pm_debug "pm_add_lab() -> ${retVal}"
    return $retVal
}
