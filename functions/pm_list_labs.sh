## /* @function
 #  @usage pm_list_labs
 #
 #  @output true
 #
 #  @description
 #  Output all of the lab folders polymerge currently knows about.
 #  description@
 #
 #  @examples
 #  for lab in `pm_list_labs`; do
 #      ...
 #  done
 #  examples@
 #
 #  @dependencies
 #  $PM_LAB_REPOS_PATH
 #  `ls`
 #  functions/pm_debug.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  returns@
 #
 #  @file functions/pm_list_labs.sh
 ## */

 function pm_list_labs {
    pm_debug "pm_list_labs( $@ )"

    ls -1 "${PM_LAB_REPOS_PATH}"
 }
