## /* @function
 #  @usage pm_remerge_polymer_and_push_change
 #
 #  @output true
 #
 #  @description
 #  This function bundles the merge and lab repo operations from pm_remerge_monomers
 #  along with committing and pushing changes to the related notebook repo. All
 #  processing in this function relies on the value of $_pm_active_polymer.
 #  description@
 #
 #  @notes
 #  - If the active polymer can't be found, this function will exit immediately.
 #  notes@
 #
 #  @dependencies
 #  $_pm_active_polymer_styled
 #  functions/pm_debug.sh
 #  functions/pm_get_polymer_path.sh
 #  functions/pm_header.sh
 #  functions/pm_push_notebook.sh
 #  functions/pm_remerge_monomers.sh
 #  functions/pm_view_monomers.sh
 #  lib/functionsh/functions/__yes_no.sh
 #  dependencies@
 #
 #  @file functions/pm_remerge_polymer_and_push_change.sh
 ## */

function pm_remerge_polymer_and_push_change {
    pm_debug "pm_remerge_polymer_and_push_change( $@ )"

    local polyPath=$( pm_get_polymer_path )

    pm_debug "pm_remerge_polymer_and_push_change:  polyPath = ${polyPath}"
    [ ! -f "$polyPath" ] && return

    echo

    __yes_no --default=y "Re-merge \`${_pm_active_polymer_styled}\` and test for merge conflicts"
    if [ $_yes ]; then
        echo

        # this MUST be called to get access to the _push_updates variable
        # note that this function already includes a call to pm_continue
        pm_remerge_monomers

        pm_debug "after pm_remerge_monomers;  _push_updates = ${_push_updates}"

        if [ "$_push_updates" == true ]; then
            pm_header
            pm_view_monomers
            echo
            echo
            pm_push_notebook
        fi

    # we only need this warning if changes were actually made!
    else
        echo
        echo "${W}  WARNING!                                                            ${X}"
        echo "${W}    You need to re-merge the branches in this poly branch prior to    ${X}"
        echo "${W}    pushing the changes you have made in order to ensure there are no ${X}"
        echo "${W}    merge conflicts between the mono branches contained therein.      ${X}"
        echo
    fi
}
