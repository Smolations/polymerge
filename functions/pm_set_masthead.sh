## /* @function
 #  @usage pm_set_masthead <masthead-name>
 #
 #  @output false
 #
 #  @description
 #  This function provides a mechanism for the user to change the masthead for
 #  his/her own preference. The <masthead-name> corresponds to each file name in
 #  $POLYMERGE_PATH/mastheads.
 #  description@
 #
 #  @dependencies
 #  $PM_MASTHEAD_PATH
 #  $POLYMERGE_PATH
 #  functions/pm_debug.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - no argument passed to function
 #  2 - masthead with <masthead-name> could not be found
 #  returns@
 #
 #  @file functions/pm_set_masthead.sh
 ## */

function pm_set_masthead {
    pm_debug "pm_set_masthead( $@ )"

    local retVal=0 mh="$@" line
    local mhSource="${POLYMERGE_PATH}/mastheads/${mh}"

    if [ $# == 0 ]; then
        retVal=1

    elif [ -f "${mhSource}" ]; then
        : > "$PM_MASTHEAD_PATH"
        while IFS= read -u 3 -r line; do
            echo "  ${line} ${X}" >> "$PM_MASTHEAD_PATH"
        done 3< "${mhSource}"

    else
        retVal=2
    fi

    pm_debug "pm_set_masthead() -> ${retVal}"
    return $retVal
}
