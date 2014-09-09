## /* @function
 #  @usage pm_list_polymers
 #
 #  @output true
 #
 #  @description
 #  Output all of the polymers in the $_pm_active_notebook.
 #  description@
 #
 #  @examples
 #  for poly in `pm_list_polymers`; do
 #      ...
 #  done
 #  examples@
 #
 #  @dependencies
 #  $PM_LAB_NOTEBOOKS_PATH
 #  $PM_POLYMERS_FOLDER_NAME
 #  $_pm_active_notebook
 #  `ls`
 #  functions/pm_debug.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - $_pm_active_notebook isn't defined
 #  returns@
 #
 #  @file functions/pm_list_polymers.sh
 ## */

 function pm_list_polymers {
    pm_debug "pm_list_polymers( $@ )"

    [ -z "$_pm_active_notebook" ] && return 1

    ls -1 "${PM_LAB_NOTEBOOKS_PATH}/${_pm_active_notebook}/${PM_POLYMERS_FOLDER_NAME}"
 }
