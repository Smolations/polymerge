## /* @function
 #  @usage __continue
 #
 #  @output true
 #
 #  @description
 #  The sole purpose of this function is to insert a pause in application execution.
 #  It is most often used after all of the processing for a specific menu selection
 #  has completed.
 #  description@
 #
 #  @dependencies
 #  functions/pm_debug.sh
 #  dependencies@
 #
 #  @file functions/pm_continue.sh
 ## */

function pm_continue {
    pm_debug "pm_continue( $@ )"

    echo ${X}
    echo
    echo -n "Press any key to continue..."
    read
}
