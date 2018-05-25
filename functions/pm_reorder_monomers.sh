## /* @function
 #  @usage pm_reorder_monomers
 #
 #  @output true
 #
 #  @description
 #  This function presents an easy-to-use menu system to reorder branches in the
 #  active polymer. Users can move branches up or down in the list. If the user
 #  specifies a position outside the range of each branch position, the branch is
 #  moved to either the first or last position depending on which "side" of the
 #  range was chosen. For example, if there are 5 branches in the active polymer,
 #  and the user chooses to move a branch to position 10, that branch will be moved
 #  to position 5 instead.
 #  description@
 #
 #  @dependencies
 #  `cat`
 #  `egrep`
 #  `tr`
 #  `rm`
 #  `wc`
 #  functions/pm_choose_monomer.sh
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_get_polymer_path.sh
 #  functions/pm_header.sh
 #  functions/pm_list_monomers.sh
 #  functions/pm_mktemp.sh
 #  lib/functionsh/functions/__in_array.sh
 #  lib/functionsh/functions/__short_ans.sh
 #  lib/functionsh/functions/__yes_no.sh
 #  dependencies@
 #
 #  @returns
 #  -1 - user aborted pm_choose_monomer
 #  0 - successful execution
 #  1 - active polymer definition file cannot be found
 #  2 - less than 2 monomers in polymer
 #  4 - pm_choose_monomer failed
 #  8 - user chosen invalid destination position # for monomer
 #  16 - unable to create temp file for operation
 #  returns@
 #
 #  @file functions/pm_reorder_monomers.sh
 ## */

function pm_reorder_monomers {
    pm_debug "pm_reorder_monomers( $@ )"

    local retVal=0 monomers orderedMonomers=( ) position i
    local polyPath=$( pm_get_polymer_path )

    if [ ! -f "$polyPath" ]; then
        retVal=1

    elif [ $( cat  "$polyPath" | wc -l | tr -d ' ' ) -lt 2 ]; then
        echo
        pm_err "A poly needs to contain two or more mono branches to be re-ordered."
        retVal=2

    else
        if pm_choose_monomer --prompt="Select a mono branch to move" || [ $? == 4 ]; then
            # failure $retVal if user aborts menu. trying to keep this value
            # consistent through any code re-factoring, the return value is -1
            # so calling script can detect when user aborts.
            [ -n "$_pm_monomer_choice" ] && branch="$_pm_monomer_choice" || retVal=-1
        else
            retVal=4
        fi

        if [ $retVal == 0 ]; then
            echo
            __short_ans "Using the menu above, which (#) position would you like to move \`${branch}\` to?"
            position="$_ans"
            echo

            if ! egrep -q '^[1-9][0-9]*$' <<< "$position"; then
                pm_err "Invalid position chosen!"
                retVal=8

            elif pm_mktemp; then
                # use array operations to build a new, re-ordered array of desired monomers

                # if $position is greater than the length of the list, set it
                # to be the length of the monomer array (i.e. the last position)
                monomers=( `pm_list_monomers` )
                (( position > ${#monomers[@]} )) && position=${#monomers[@]}

                # remove the branch that is changing position in the list
                __in_array "$branch" "${monomers[@]}"
                unset monomers[$_in_array_index]
                monomers=( "${monomers[@]}" )
                pm_debug "new monos = ( ${orderedMonomers[@]} )"

                # use array parameter expansion to build new, ordered array
                [ $position != 0 ] && orderedMonomers+=( "${monomers[@]:0:$(( position - 1 ))}" )
                orderedMonomers+=( "$branch" )
                [ $position != $(( ${#monomers[@]} + 1 )) ] && orderedMonomers+=( "${monomers[@]:$(( position - 1 ))}" )
                pm_debug "orderedMonomers = ( ${orderedMonomers[@]} )"

                for (( i = 0; i < ${#orderedMonomers[@]}; i++ )); do
                    echo "${orderedMonomers[$i]}" >> "${_pm_temp_file}"
                done

                # copy the new polymer and cleanup
                cat "$_pm_temp_file" > "$polyPath"
                rm -f "${_pm_temp_file}"

                pm_header
                echo "New active poly definition:"
                echo "---------------------------"
                pm_list_monomers

            else
                retVal=16
            fi
        fi
    fi

    pm_debug "pm_reorder_monomers() -> ${retVal}"
    return $retVal
}
