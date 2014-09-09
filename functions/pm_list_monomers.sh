## /* @function
 #  @usage pm_list_monomers
 #
 #  @output true
 #
 #  @description
 #  Output all of the monomers in the $_pm_active_polymer.
 #  description@
 #
 #  @examples
 #  for monomer in `pm_list_monomers`; do
 #      ...
 #  done
 #  examples@
 #
 #  @dependencies
 #  $_pm_active_polymer
 #  `cat`
 #  functions/pm_debug.sh
 #  functions/pm_get_polymer_path.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - $_pm_active_polymer isn't defined
 #  returns@
 #
 #  @file functions/pm_list_monomers.sh
 ## */

 function pm_list_monomers {
    pm_debug "pm_list_monomers( $@ )"

    [ -z "$_pm_active_polymer" ] && return 1

    cat "$( pm_get_polymer_path )"
 }
