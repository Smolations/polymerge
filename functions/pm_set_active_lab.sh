## /* @function
 #  @usage pm_set_active_lab <lab-name>
 #
 #  @output true (on error)
 #
 #  @exports
 #  $_pm_active_lab
 #  $_pm_active_lab_styled
 #  $_pm_active_notebook
 #  exports@
 #
 #  @description
 #  This function takes care of setting the active laboratory. The <lab-name> is
 #  passed as the first argument and, if the lab exists, the application is made
 #  aware of the change(s).
 #  description@
 #
 #  @notes
 #  - While the <lab-name> is required, it *may* be an empty string. This
 #  effectively "resets" the value of the exported variables.
 #  notes@
 #
 #  @examples
 #  pm_set_active_lab personal-projects
 #  pm_set_active_lab ''
 #  examples@
 #
 #  @dependencies
 #  $PM_ACTIVE_LAB_FILE_PATH
 #  functions/pm_err.sh
 #  functions/pm_debug.sh
 #  functions/pm_get_notebook_from_lab.sh
 #  functions/pm_set_active_polymer.sh
 #  functions/pm_validate_lab.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - no arguments passed to function
 #  2 - invalid <lab-name> given (pm_validate_lab failed)
 #  returns@
 #
 #  @file functions/pm_set_active_lab.sh
 ## */

function pm_set_active_lab {
    pm_debug "pm_set_active_lab( $@ )"

    local retVal=0 lab="$@" nb=

    if [ $# == 0 ]; then
        retVal=1

    # usually this will be intentional
    elif [ -z "$lab" ]; then
        pm_set_active_polymer ''

    else
        if ! pm_validate_lab "$lab"; then
            retVal=2
            pm_err -q "Cannot set active laboratory to: ${lab}"
            pm_err -q "Lab failed validation!"

            # leave current active lab/notebook in place
            lab="$_pm_active_lab"
            nb="$_pm_active_notebook"

        else
            nb=$( pm_get_notebook_from_lab "$lab" )
        fi
    fi

    echo "$lab" > "$PM_ACTIVE_LAB_FILE_PATH"

    export _pm_active_lab="$lab"
    export _pm_active_lab_styled="${STYLE_BRIGHT}${COL_YELLOW}${_pm_active_lab}${X}"
    export _pm_active_notebook="$nb"

    pm_debug "  _pm_active_lab      = ${_pm_active_lab}"
    pm_debug "  _pm_active_notebook = ${_pm_active_notebook}"

    pm_debug "pm_set_active_lab() -> ${retVal}"
    return $retVal
}
