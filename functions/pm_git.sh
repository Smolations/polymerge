## /* @function
 #  @usage pm_git [-v] --pm <native-git-command>
 #  @usage pm_git [-v] --nb=<notebook-name> <native-git-command>
 #  @usage pm_git [-v] --lab=<lab-name> <native-git-command>
 #
 #  @output false (unless -v option given)
 #
 #  @description
 #  This is a wrapper for git commands which can be targeted at three types of
 #  repositories: lab repos, notebook repos, and the polymerge project itself.
 #  It responds to any native git command. If in debug mode, polymerge will send
 #  the output of all git commands sent through this function to pm_log. By default,
 #  all output is hidden from the user, but it will be shown if the -v option is
 #  passed. If a valid command is given, the exit value of the command is returned
 #  as the return value of *this* function.
 #
 #  In addition to native git commands, some custom commands have been included for
 #  convenience:
 #      is-branch-valid
 #      get-current-branch
 #
 #  These custom commands should be self explanatory.
 #  description@
 #
 #  @options
 #  --lab=<lab-name>        Target the <lab-name> repo.
 #  --nb=<notebook-name>    Target the <notebook-name> repo.
 #  --pm                    Target the polymerge repo.
 #  -v                      Send output to stdout.
 #  options@
 #
 #  @notes
 #  - This function does not work for `git submodule` and its subcommands. This is
 #  an issue with git itself, not polymerge.
 #  notes@
 #
 #  @examples
 #  $ pm_git --pm fetch
 #  $ pm_git --lab="my-lab" checkout my-polymer-name
 #  $ currentNbBranch=$( pm_git -v --nb="my-notebook" get-current-branch )
 #  examples@
 #
 #  @dependencies
 #  $PM_LAB_NOTEBOOKS_PATH
 #  $PM_LAB_REPOS_PATH
 #  $POLYMERGE_PATH
 #  `eval`
 #  `git`
 #  `tee`
 #  functions/pm_debug.sh
 #  functions/pm_log.sh
 #  lib/functionsh/functions/__in_args.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  -1 - no arguments passed
 #  -2 - no git command found from input
 #  * - exit code from git command
 #  returns@
 #
 #  @file functions/pm_git.sh
 ## */

function pm_git {
    pm_debug "pm_git( $@ )"

    [ $# == 0 ] && return -1

    # commands that support --quiet: push, pull, checkout, fetch, merge
    # save the command, then remove it from the args list so that we can simply
    # pass $@ to the parsed commands
    declare -a toEval=( "git" )
    local verbose= gitCmd repoPath

    # user may specify for output to be shown in terminal
    __in_args v "$@" && verbose=true

    # should this operation be targeted at a notebook or lab repo?
    if __in_args nb "${_args_clipped[@]}"; then
        repoPath="${PM_LAB_NOTEBOOKS_PATH}/${_arg_val}"

    elif __in_args lab "${_args_clipped[@]}"; then
        repoPath="${PM_LAB_REPOS_PATH}/${_arg_val}"

    elif __in_args pm "${_args_clipped[@]}"; then
        repoPath="${POLYMERGE_PATH}"
    fi

    if [ -n "$repoPath" ]; then
        toEval+=( "--git-dir=\"${repoPath}/.git\"" )
        toEval+=( "--work-tree=\"${repoPath}\"" )
    fi

    # pm_debug "after nb/lab filtering:"
    # pm_debug "--  repoPath         = ${repoPath}"
    # pm_debug "--  toEval           = ${toEval[@]}"
    # pm_debug "--  _args_clipped[@] = ${_args_clipped[@]}"

    (( ${#_args_clipped} == 0 )) && return -2

    gitCmd=${_args_clipped[0]}
    toEval+=( $gitCmd )

    case $gitCmd in
        # add)
        #     toEval="git add $@";;

        # branch)
        #     toEval="git branch $@";;

        # checkout)
        #     toEval="git checkout $@";;

        # clean)
        #     toEval="git clean $@";;

        # commit)
        #     toEval="git commit $@";;

        # Use on-demand to only recurse into a populated submodule
        # when the superproject retrieves a commit that updates the
        # submodule's reference to a commit that isn't already in the local
        # submodule clone.
        fetch)
            toEval+=( "--all --recurse-submodules=on-demand" );;

        # merge)
        #     toEval="git merge $@";;

        # pull)
        #     toEval="git pull $@";;

        # push)
        #     toEval="git push $@";;

        # reset)
        #     toEval="git reset $@";;

        # stash)
        #     toEval="git stash $@";;


        ## the following are custom, non-git commands which are required in
        ## multiple areas of polymerge

        is-branch-valid)
            toEval[$(( ${#toEval[@]} - 1 ))]=check-ref-format
            _args_clipped[1]="'refs/heads/${_args_clipped[1]}'";;

        # pm_git -v $repoArg symbolic-ref --short HEAD
        get-current-branch)
            toEval[$(( ${#toEval[@]} - 1 ))]=symbolic-ref
            _args_clipped+=( '--short' )
            _args_clipped+=( 'HEAD' );;

        # *)
        #     return 1
        #     ;;
    esac

    toEval+=( "${_args_clipped[@]:1}" )   # elements following _args_clipped[0]

    pm_debug "(FINAL) toEval (${#toEval[@]} elements) = ${toEval[@]}"

    pm_log -n
    if [ $verbose ]; then
        eval "${toEval[@]}" 2>&1 | tee -a "$PM_LOG_FILE_PATH"
        evalReturn=${PIPESTATUS[0]}

    else
        eval "${toEval[@]}" 2>&1 | pm_log -n
        evalReturn=${PIPESTATUS[0]}
    fi
    pm_log -n

    pm_debug "pm_git() -> ${evalReturn}"
    return $evalReturn
}
