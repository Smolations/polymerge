## /* @function
 #  @usage pm_view_monomers
 #
 #  @output true
 #
 #  @description
 #  Use this function to view the contents of the currently active polymer.
 #  description@
 #
 #  @dependencies
 #  $_pm_active_polymer_styled
 #  functions/pm_debug.sh
 #  functions/pm_get_polymer_path.sh
 #  functions/pm_list_monomers.sh
 #  dependencies@
 #
 #  @file functions/pm_view_monomers.sh
 ## */

function pm_view_monomers {
    pm_debug "pm_view_monomers( $@ )"

    local polyPath=$( pm_get_polymer_path )
    pm_debug "  looking for poly: ${polyPath}"

    echo "Mono branches in \`${_pm_active_polymer_styled}\`:"
    echo "---------------------------------------------"
    pm_list_monomers
    echo "---------------------------------------------"
}
