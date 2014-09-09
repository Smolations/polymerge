## /* @function
 #  @usage pm_prune_monomers
 #
 #  @output true
 #
 #  @description
 #  This function will cycle through the monomers in the active polymer and remove
 #  any monomer branches that are currently merged into `master`. Each monomer and
 #  the resultant action for that monomer are displayed for the user to see.
 #  description@
 #
 #  @dependencies
 #  $_pm_active_lab
 #  `cat`
 #  `grep`
 #  `rm`
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_get_polymer_path.sh
 #  functions/pm_git.sh
 #  functions/pm_mktemp.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - cannot find active polymer
 #  2 - active polymer contains no monomers
 #  4 - unable to create temp file for operation
 #  returns@
 #
 #  @file functions/pm_prune_monomers.sh
 ## */

function pm_prune_monomers {
    pm_debug "pm_prune_monomers( $@ )"

    declare -a pieces remoteBranches
    local retVal=0 target=master targetHash branch
    local polyPath=$( pm_get_polymer_path )

    if [ ! -f "$polyPath" ]; then
        pm_err "Cannot locate polymer:  ${polyPath}"
        retVal=1

    elif [ ! -s "$polyPath" ]; then
        pm_err "Active polymer contains no monomer branches."
        retVal=2

    else
        # get target branch hash for display/comparison purposes
        targetHash=$( pm_git -v --lab="$_pm_active_lab" log --oneline -1 "origin/${target}" )
        pm_debug "raw targetHash = $targetHash"
        targetHash="${targetHash:0:7}"
        pm_debug "  \`${target}\` current targetHash: ${targetHash}"

        local symKeep="K${X}"
        local symMrgd="R${X}"
        local symDupe="S${X}"

        if pm_mktemp; then
            # legend for output
            echo "  Output Legend:"
            echo "  --------------------------------------------------------------------------------"
            echo "    ${symKeep}  -  Branch not merged into master. It will remain on the build list."
            echo "    ${symMrgd}  -  Branch has been merged into master. Remove from the polymer."
            echo "    ${symDupe}  -  Branch on build list more than once. Remove the duplicate."
            echo "  --------------------------------------------------------------------------------"
            echo

            # loop through the monomer list, checking to see if each branch is contained
            # in $target (usually master). Save those branches that are NOT in master
            # into the temp list, copying the temp list to the build list when finished.
            while read -u 3 branch; do
                pm_debug "evaluating branch: ${branch}"
                if [ -n "$branch" ]; then

                    if pm_git -v --lab="$_pm_active_lab" branch -r --no-color --contains "origin/${branch}" | grep -q "origin/${target}$"; then
                        pm_debug "MERGED"
                        echo "  ${symMrgd}  ${B}${branch}${X}"

                    else
                        pm_debug "UNMERGED"
                        if ! grep -q "$branch" "${_pm_temp_file}"; then
                            pm_debug "adding to temp file..."
                            echo "  ${symKeep}  ${B}${branch}${X}"
                            echo "$branch" >> "${_pm_temp_file}"
                        else
                            pm_debug "DUPE"
                            echo "  ${symDupe}  ${B}${branch}${X}"
                        fi
                    fi

                else
                    pm_debug "WARNING: empty branch in active polymer: ${branch}"
                fi
            done 3< "$polyPath"

            cat "$_pm_temp_file" > "$polyPath"
            rm -f "$_pm_temp_file"

        else
            pm_err "Could not complete operation because temp file couldn't be created."
            retVal=4
        fi
    fi

    pm_debug "pm_prune_monomers() -> ${retVal}"
    return $retVal
}
