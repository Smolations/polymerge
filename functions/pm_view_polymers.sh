## /* @function
 #  @usage pm_view_polymers
 #
 #  @output true
 #
 #  @description
 #  Use this function to view all of the polymers for the active notebook.
 #  description@
 #
 #  @dependencies
 #  functions/pm_debug.sh
 #  functions/pm_list_polymers.sh
 #  dependencies@
 #
 #  @file functions/pm_view_polymers.sh
 ## */

function pm_view_polymers {
    pm_debug "pm_view_polymers( $@ )"

    echo "Polys in ${_pm_active_notebook}:"
    echo "-----------------------------------"
    pm_list_polymers
    echo "-----------------------------------"
}
