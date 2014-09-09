## /* @function
 #  @usage pm_set_active_polymer <polymer-name>
 #
 #  @output false
 #
 #  @exports
 #  $_pm_active_polymer
 #  $_pm_active_polymer_styled
 #  exports@
 #
 #  @description
 #  This function takes care of setting the active build list. The list name is passed
 #  as the first argument and, if the list exists, the application is made aware of
 #  the change.
 #  description@
 #
 #  @notes
 #  - While the <polymer-name> is required, it *may* be an empty string. This
 #  effectively "resets" the value of the exported variables.
 #  notes@
 #
 #  @examples
 #  pm_set_active_polymer qa
 #  pm_set_active_polymer ''
 #  examples@
 #
 #  @dependencies
 #  $PM_ACTIVE_POLYMER_FILE_SUFFIX
 #  $PM_VAR_PATH
 #  $_pm_active_lab
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_get_polymer_path.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - no arguments passed to function
 #  2 - invalid <polymer-name> given (path not found)
 #  returns@
 #
 #  @file functions/pm_set_active_polymer.sh
 ## */

function pm_set_active_polymer {
    pm_debug "pm_set_active_polymer( $@ )"

    local retVal=0 poly="$@"
    local polymerPath=$( pm_get_polymer_path "$poly" )
    local activePolymerFile="${PM_VAR_PATH}/${_pm_active_lab}${PM_ACTIVE_POLYMER_FILE_SUFFIX}"

    if [ $# == 0 ]; then
        retVal=1

    elif [ ! -f "$polymerPath" ]; then
        retVal=2
        pm_err -q "pm_set_active_polymer() - Cannot set active polymer to: ${poly}"
        pm_err -q "pm_set_active_polymer() - The polymer does not exist!"
        poly="$_pm_active_polymer"

    else
        echo "$poly" > "$activePolymerFile"
    fi

    export _pm_active_polymer="$poly"
    export _pm_active_polymer_styled="${STYLE_BRIGHT}${COL_YELLOW}${_pm_active_polymer}${X}"

    pm_debug "--  _pm_active_polymer = ${_pm_active_polymer}"

    pm_debug "pm_set_active_polymer() -> ${retVal}"
    return $retVal
}
