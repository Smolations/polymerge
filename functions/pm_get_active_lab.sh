## /* @function
 #  @usage pm_get_active_lab
 #
 #  @output false
 #
 #  @exports
 #  $_pm_active_lab
 #  $_pm_active_lab_styled
 #  $_pm_active_notebook
 #  exports@
 #
 #  @description
 #  This function looks for the file which contains the name of the most recent
 #  active lab and extracts that name for exporting in a variable. It also
 #  determines the associated notebook of the active lab and exports it in a
 #  variable as well.
 #  description@
 #
 #  @examples
 #  $ pm_get_active_lab && echo $_pm_active_lab
 #  examples@
 #
 #  @dependencies
 #  $PM_ACTIVE_LAB_FILE_PATH
 #  `cat`
 #  functions/pm_debug.sh
 #  functions/pm_get_notebook_from_lab.sh
 #  dependencies@
 #
 #  @file functions/pm_get_active_lab.sh
 ## */

function pm_get_active_lab {
    pm_debug "pm_get_active_lab( $@ )"

    local alFile="${PM_ACTIVE_LAB_FILE_PATH}" aLab= nb=

    [ -s "$alFile" ] && aLab=$( cat "$alFile" ) && nb=$( pm_get_notebook_from_lab "$aLab" )

    export _pm_active_lab="$aLab"
    export _pm_active_lab_styled="${STYLE_BRIGHT}${COL_YELLOW}${_pm_active_lab}${X}"
    export _pm_active_notebook="$nb"

    pm_debug "--  _pm_active_lab = ${_pm_active_lab}"
    pm_debug "--  _pm_active_notebook = ${_pm_active_notebook}"
}
