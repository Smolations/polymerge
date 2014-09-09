## /* @function
 #  @usage pm_list_notebooks
 #
 #  @output true
 #
 #  @description
 #  Output all of the notebook folders polymerge currently knows about.
 #  description@
 #
 #  @examples
 #  for nb in `pm_list_notebooks`; do
 #      ...
 #  done
 #  examples@
 #
 #  @dependencies
 #  $PM_LAB_NOTEBOOKS_PATH
 #  `ls`
 #  functions/pm_debug.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  returns@
 #
 #  @file functions/pm_list_notebooks.sh
 ## */

 function pm_list_notebooks {
    pm_debug "pm_list_notebooks( $@ )"

    ls -1 "${PM_LAB_NOTEBOOKS_PATH}"
 }
