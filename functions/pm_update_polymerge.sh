## /* @function
 #  @usage pm_update_polymerge
 #
 #  @output true
 #
 #  @description
 #  This function encapsulates the functionality required to update the polymerge
 #  project itself.
 #  description@
 #
 #  @dependencies
 #  $PM_UPDATE_BRANCH
 #  $POLYMERGE_PATH
 #  `egrep`
 #  `git`
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_git.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - unable to find $POLYMERGE_PATH
 #  2 - polymerge project working tree is dirty
 #  4 - cannot find remote
 #  8 - git pull operation failed
 #  16 - git submodule operation failed
 #  returns@
 #
 #  @file functions/pm_update_polymerge.sh
 ## */

function pm_update_polymerge {
    pm_debug "pm_update_polymerge( $@ )"

    local retVal=0 updateBranch="$PM_UPDATE_BRANCH" remote cwd

    echo "${A}Updating polymerge${X}..."

    if [ -d "$POLYMERGE_PATH" ]; then
        if pm_git -v --pm status --porcelain | egrep -q '.+'; then
            pm_err "Unable to update. polymerge project working tree is dirty."
            retVal=2

        else
            echo "- Fetching updates"
            remote=$( pm_git -v --pm remote )

            if [ -z "$remote" ]; then
                retVal=4
                pm_err "For some reason, polymerge's remote cannot be found."

            else
                pm_git --pm fetch
                pm_git --pm checkout $updateBranch

                echo "- Pulling in updates"
                if ! pm_git --pm pull "$remote" $updateBranch; then
                    retVal=8
                    pm_err "There was an error when pulling down updates. Make sure the"
                    pm_err "polymerge project directory has a clean work-tree and try again."

                else
                    # submodule commands have issues when using --git-dir and --work-tree
                    # git options, so we have to be in the actual directory
                    echo "- Updating submodules"
                    cwd=$( pwd )
                    cd "$POLYMERGE_PATH"

                    git submodule update --init --recursive 2>&1 | pm_debug -n
                    if [ ${PIPESTATUS[0]} != 0 ]; then
                        retVal=16
                        pm_debug "\`git submodule update\` returned:  ${PIPESTATUS[0]}"
                        pm_err "Unable to update polymerge submodule libraries. See log for details."

                    else
                        echo "- Applying changes"
                        source SOURCEME | pm_debug -n
                    fi

                    cd "$cwd"
                fi
            fi

            echo "Update complete$( [ $retVal != 0 ] && echo ", but with errors" )."
        fi

    else
        pm_err "Unable to find polymerge project. \$POLYMERGE_PATH is not a directory."
        retVal=1
    fi

    pm_debug "pm_update_polymerge() -> ${retVal}"
    return $retVal
}
