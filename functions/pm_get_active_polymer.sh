## /* @function
 #  @usage pm_get_active_polymer
 #
 #  @output false
 #
 #  @exports
 #  $_pm_active_polymer
 #  $_pm_active_polymer_styled
 #  exports@
 #
 #  @description
 #  The only thing this function does is figure out what the active polymer is and
 #  save that string to the specified exported variables.
 #  description@
 #
 #  @examples
 #  $ pm_get_active_polymer
 #  $ echo $_pm_active_polymer
 #  examples@
 #
 #  @dependencies
 #  $PM_ACTIVE_POLYMER_FILE_SUFFIX
 #  $PM_VAR_PATH
 #  $_pm_active_lab
 #  `cat`
 #  functions/pm_debug.sh
 #  dependencies@
 #
 #  @file functions/pm_get_active_polymer.sh
 ## */

function pm_get_active_polymer {
    pm_debug "pm_get_active_polymer( $@ )"

    local aPoly= apFile

    if [ -n "$_pm_active_lab" ]; then
        apFile="${PM_VAR_PATH}/${_pm_active_lab}${PM_ACTIVE_POLYMER_FILE_SUFFIX}"

        [ -f "$apFile" ] && aPoly=$( cat "$apFile" )
    fi

    export _pm_active_polymer="$aPoly"
    export _pm_active_polymer_styled="${STYLE_BRIGHT}${COL_YELLOW}${_pm_active_polymer}${X}"

    pm_debug "--  _pm_active_polymer = ${_pm_active_polymer}"
}
