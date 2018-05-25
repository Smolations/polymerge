## /* @function
 #  @usage pm_remerge_monomers [<polymer-name>]
 #
 #  @output true
 #
 #  @exports
 #  $_push_updates
 #  exports@
 #
 #  @description
 #  This function performs all of the merging operations required in order to
 #  combine changes in monomer branches into a single polymer branch which
 #  eventually makes its way to the remote. If a branch fails to merge, it is
 #  backed out and details about the conflict are presented to the user so that any
 #  conflicts can be resolved much easier.
 #
 #  Once the merge operation is complete, the user is prompted to commit and push
 #  those changes to the lab repo's remote.
 #
 #  If a <polymer-name> is not passed as an argument, the current
 #  $_pm_active_polymer is used.
 #  description@
 #
 #  @notes
 #  - While a polymer name can be passed to this function, it still relies on having
 #  $_pm_active_notebook set so that it knows to look for the polymer definition.
 #  notes@
 #
 #  @dependencies
 #  $_ENV_OSX (from lib/functionsh/functions/__get_env.sh)
 #  $_pm_active_polymer
 #  $_pm_active_lab
 #  `cat`
 #  `grep`
 #  `printf`
 #  `rm`
 #  `sed`
 #  `tr`
 #  `wc`
 #  functions/pm_continue.sh
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_get_polymer_path.sh
 #  functions/pm_git.sh
 #  functions/pm_header.sh
 #  functions/pm_mktemp.sh
 #  functions/pm_update_repo.sh
 #  lib/functionsh/functions/__yes_no.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - polymer definition file could not be found
 #  2 - could not make lab repo work-tree clean
 #  4 - failed to checkout polymer branch
 #  8 - failed to push changes to lab repo remote
 #  returns@
 #
 #  @file functions/pm_remerge_monomers.sh
 ## */

function pm_remerge_monomers {
    pm_debug "pm_remerge_monomers( $@ )"

    declare -a blames
    local retVal=0 count=1 baseBranch=master polyName="${@-$_pm_active_polymer}"
    local polyPath=$( pm_get_polymer_path "${polyName}" )
    local tmpList tmpListResult numLines branch blame line escapedLine ICO_PASS ICO_FAIL i

    # script vars
    pm_mktemp && tmpList="$_pm_temp_file"
    pm_mktemp && tmpListResult="$_pm_temp_file"
    # TODO: check that files exist
    export _push_updates=false


    # must have a polymer
    if [ ! -f "$polyPath" ]; then
        pm_err "Could not locate polymer to re-merge:  ${polyPath}"
        retVal=1
    fi

    pm_update_repo --lab="$_pm_active_lab"
    if [ $? == 4 ]; then
        pm_debug "lab work-tree is dirty..."
        pm_git --lab="$_pm_active_lab" reset --hard HEAD
        if ! pm_update_repo --lab="$_pm_active_lab"; then
            pm_err "After trying to clean laboratory repo, it is still dirty."
            retVal=2
        fi
    fi


    ##
    # checkout master to base new build branch from
    ##
    pm_git --lab="$_pm_active_lab" checkout $baseBranch


    # delete build branch locally if it exists, then recreate it from master
    pm_debug "Delete build branch locally if it exists, then recreate it from ${baseBranch}..."
    if pm_git -v --lab="$_pm_active_lab" branch | grep -q "$polyName"; then
        pm_debug "deleting poly branch since it exists..."
        pm_git --lab="$_pm_active_lab" branch -D "$polyName"
    fi

    # we dont want states returned in git status (ahead/behind) to be determined by the list's
    # relationship to origin/$baseBranch, so we turn off tracking. We turn it on when pushing the branch up
    # a little further down the script
    if ! pm_git --lab="$_pm_active_lab" checkout --no-track -b "$polyName" "origin/${baseBranch}"; then
        pm_err "Failed to switch to poly branch [${polyName}] before merging. Aborting..."
        retVal=4
    fi


    # set up temp list with default progress indicators
    # pm_debug "  setting up temp progress list..."
    for branch in `cat "$polyPath"`; do
        echo "[..]  ${branch}" >> "$tmpList"
    done
    # pm_debug "finished temp progress list:"
    # cat "$tmpList" | pm_log -n


    # get number of branches to merge for convenience
    # cut out path/spaces in output
    numLines=$( cat "$tmpList" | wc -l | tr -d ' ' )
    pm_debug "tmpList has ${numLines} lines"

    # set a count here so that we can tell sed which line to operate on
    count=1

    # indicators should be OS-specific
    if [ $_ENV_OSX ]; then
        ICO_PASS="✅ "
        ICO_FAIL="❌ "
    else
        ICO_PASS="${COL_BG_GREEN}${COL_WHITE}OK${X}"
        ICO_FAIL="${COL_BG_RED}${COL_WHITE}XX${X}"
    fi

    # actually go through and process build list.
    # pm_debug statements were commented out to try and improve processing speed
    pm_debug "  loop through progress list and merge (${numLines}) branches"
    cat "$tmpList" > "$tmpListResult"

    while read -u 3 line; do
        pm_debug "  line:  [${line}]"
        branch="${line##* }"
        # pm_debug "  branch:  [${B}${branch}${X}]"
        escapedLine="${line//\./\\.}"
        escapedLine="${escapedLine//\[/\\[}"
        escapedLine="${escapedLine//\]/\\]}"
        # branches arent really allowed to have these characters anyway...
        # branch="${branch//(/\\(}"
        # branch="${branch//)/\\)}"
        # branch="${branch//\{/\\\{}"
        # branch="${branch//\}/\\\}}"
        # pm_debug "  escapedLine (post processing):  [${BY}${escapedLine}${X}]"

        # the icons do something funky with the layout in terminal, so the trailing space is needed
        # the -Xignore-all-space option means conflicts will not arise for pure whitespace changes.
        # if __git merge -Xignore-all-space "${_remote}/${branch}"; then
        if pm_git --lab="$_pm_active_lab" merge -Xignore-all-space "origin/${branch}"; then
            # pm_debug "$(sed "${count}s:${escapedLine}:[${ICO_PASS}]  ${branch}:" <<< "$(cat "$tmpListResult")" > "${tmpListResult}")"
            sed "${count}s:${escapedLine}:[${ICO_PASS}]  ${branch}:" <<< "$( cat "$tmpListResult" )" > "${tmpListResult}"

        else
            pm_git --lab="$_pm_active_lab" reset --merge
            sed "${count}s:${escapedLine}:[${ICO_FAIL}]  ${branch}:" <<< "$( cat "$tmpListResult" )" > "${tmpListResult}"

            # parse last log entry for an estimation of the owner of the conflicting branch
            theBlame=$( pm_git -v --lab="$_pm_active_lab" log -1 --pretty="'format:%an|%h|%ai'" "origin/${branch}" )
            authorName="${theBlame%%|*}"
            commitHash="${theBlame#*|}" && commitHash="${commitHash%|*}"
            dateString="${theBlame##*|}"

            blames+=( "`printf "${COL_YELLOW}%7s${X}  ${B}%-30s${X}  ${Q}%-16s${X}  (%-s)" "$commitHash" "$branch" "$authorName" "$dateString"`" )
        fi

        (( count++ ))

        pm_header
        echo
        echo "Attempting to merge (${STYLE_BRIGHT}${COL_CYAN}${numLines}${X}) branches:"
        echo
        echo
        cat "$tmpListResult"

        # so user has a chance to see the actual progress
        sleep 1
    done 3< "$tmpList"

    echo
    echo

    # display results, prompting for a push if necessary.
    # the calling script should use the exported $_push_updates variable
    # upon completion of this script.
    if [ ${#blames[@]} -gt 0 ]; then
        if [ ${#blames[@]} -eq 1 ]; then
            echo -n "There was a ${COL_RED}merge conflict${X}."
        else
            echo -n "There were ${#blames[@]} ${COL_RED}merge conflicts${X}."
        fi
        echo " More information for each conflicted branch:"
        echo "${COL_RED}----------------------------------------------------------------------------------------${X}"
        for (( i = 0; i < ${#blames[@]}; i++ )); do echo "${blames[i]}"; done
        echo "${COL_RED}----------------------------------------------------------------------------------------${X}"
        echo
        echo "${W}  WARNING!                                                            ${X}"
        echo "${W}    Due to merge conflicts, you will be unable to push your changes.  ${X}"
        echo "${W}    You will need to resolve the conflict(s) and try again.           ${X}"
        # output the no-push warning?

    else
        echo "Sweet! ${S}No merge conflicts!${X}"
        echo

        # prompt for pushing changes
        __yes_no --default=y "${A}Commit${Q} and ${A}push${Q} new poly branch to ${_pm_active_lab}"
        echo

        if [ $_yes ]; then
            _push_updates=true

            # push new branch up. force the push so theres no need to worry if
            # the remote branch exists or not.
            # also, turn on remote tracking so ahead/behind states are accurate.
            echo -n "${A}Pushing${X} \`${polyName}\` ${A}to ${_pm_active_lab}${X}..."
            if pm_git --lab="$_pm_active_lab" push --force --set-upstream origin "${polyName}"; then
                echo "done."
                echo
                echo "Successfully ${A}pushed${X} \`${polyName}${X}\`!"

            else
                echo && echo
                pm_err "Failed to push \`${polyName}\` to ${_pm_active_lab}. See log for details."
                retVal=8
            fi

            pm_continue

        else
            echo "No problem. Just be sure you push the newly-merged poly branch"
            echo "to the remote BEFORE you push any notebook changes out to the team."
            echo "Branches on the remote should ALWAYS match their corresponding"
            echo "poly branch."
        fi
    fi

    # cleanup
    rm -f "$tmpList"
    rm -f "$tmpListResult"

    export _push_updates

    pm_debug "pm_remerge_monomers() -> ${retVal}"
    return $retVal
}
