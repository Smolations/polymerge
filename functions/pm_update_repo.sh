## /* @function
 #  @usage pm_update_repo --nb=<notebook-repo>
 #  @usage pm_update_repo --lab=<laboratory-repo>
 #
 #  @output true
 #
 #  @description
 #  Given that there are two distinct types of repositories in polymerge, and that
 #  there can be multiple repos of each type, a way to target each type is
 #  necessary. This function allows the user to do just that. Git operations
 #  performed on the target repo:
 #
 #      status, remote, fetch, checkout, pull, submodule
 #  description@
 #
 #  @options
 #  --nb=<notebook-repo>        Specify the notebook repo to update.
 #  --lab=<laboratory-repo>     Specify the lab repo to update.
 #  options@
 #
 #  @notes
 #  - If, for some reason, both the --nb and --lab options are passed, only the
 #  notebook repo will be targeted. The --lab option will be ignored. It does not
 #  matter which order they are specified in.
 #  notes@
 #
 #  @examples
 #  pm_update_repo --nb="my-notebook-repo-name"
 #  examples@
 #
 #  @dependencies
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  lib/functionsh/functions/__in_args.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - no arguments passed to function
 #  2 - neither notebook nor lab specified
 #  4 - specified repo can't be found
 #  8 - repo work-tree is dirty
 #  16 - `git pull` operation failed
 #  32 - `git submodule` operation failed
 #  returns@
 #
 #  @file functions/pm_update_repo.sh
 ## */

function pm_update_repo {
    pm_debug "pm_update_repo( $@ )"

    local retVal=0 baseBranch=master
    local nb lab curBranch remote repoArg repoPath repo cwd

    if [ $# == 0 ]; then
        retVal=1

    else
        if __in_args nb "$@"; then
            nb="$_arg_val"
            repoPath="${PM_LAB_NOTEBOOKS_PATH}/${nb}"
            repoArg="--nb=${nb}"

        elif __in_args lab "${_args_clipped[@]}"; then
            lab="$_arg_val"
            repoPath="${PM_LAB_REPOS_PATH}/${lab}"
            repoArg="--lab=${lab}"

        else
            retVal=2
        fi

        if [ $retVal == 0 ]; then
            # pm_debug "repoArg = ${repoArg}"
            # pm_debug ".git path: ${repoPath}/.git"
            if [ ! -d "${repoPath}/.git" ]; then
                retVal=4

            else
                [ -n "$nb" ] && repo="$nb" || repo="$lab"

                if pm_git -v $repoArg status --porcelain | egrep -q '.+'; then
                    retVal=8
                    pm_err "Unable to update repository (${repo}). Work-tree is dirty."

                else
                    remote=$( pm_git -v $repoArg remote )

                    if [ -n "$remote" ]; then
                        # echo "Fetching and pulling:  ${repoPath/$PM_HOME_PATH/}"
                        echo "Fetching and pulling:  ${repo}"

                        pm_git $repoArg fetch

                        # update should occur on mainline
                        curBranch=$( pm_git -v $repoArg get-current-branch )
                        if [ "$curBranch" != "$baseBranch" ]; then
                            pm_git $repoArg checkout "$baseBranch"
                        fi

                        # check to see if the local mainline is behind its remote counterpart
                        if pm_git -v $repoArg rev-list --left-right ..@{u} | egrep -q '.+'; then
                            # [ -n "$curBranch" ] && pm_git $repoArg pull origin "$curBranch"
                            if ! pm_git $repoArg pull origin "$baseBranch"; then
                                retVal=16

                            # there appears to be a bug when trying to run submodule commands using [OS X] git's
                            # --git-dir and --work-tree arguments, so we'll do directory switching instead
                            elif [ -s "${repoPath}/.gitmodules" ]; then
                                echo "Submodules found. Initializing and updating..."
                                cwd=$( pwd )
                                cd "$repoPath"
                                git submodule update --init --recursive 2>&1 | pm_debug -n
                                if [ ${PIPESTATUS[0]} != 0 ]; then
                                    retVal=32
                                    pm_debug "\`git submodule update\` returned:  ${PIPESTATUS[0]}"
                                    pm_err "Error updating submodule(s)."
                                fi
                                cd "$cwd"
                            fi
                        fi

                        # return to whatever branch was checked out
                        if [ "$curBranch" != "$baseBranch" ]; then
                            pm_git $repoArg checkout "$curBranch"
                        fi
                    fi
                fi
            fi
        fi
    fi

    pm_debug "pm_update_repo() -> ${retVal}"
    return $retVal
}
