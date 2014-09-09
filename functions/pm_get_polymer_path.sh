## /* @function
 #  @usage pm_get_polymer_path [<polymer-name>]
 #
 #  @output true
 #
 #  @description
 #  In order to avoid the construction of polymer paths in multiple functions, this
 #  function will serve has a polymer path constructor. It relies on having a
 #  $_pm_active_notebook, but will return a path to any polymer in that notebook
 #  depending on what is passed as the <polymer-name> to this function. If this
 #  argument is omitted, the default polymer used is the $_pm_active_polymer.
 #  description@
 #
 #  @notes
 #  - This function does NOT check to see if the path exists before outputting it.
 #  notes@
 #
 #  @examples
 #  local newPoly=$( pm_get_polymer_path new-poly )
 #  [ -f "$newPoly" ] && echo "This polymer exists!"
 #  examples@
 #
 #  @dependencies
 #  $PM_LAB_NOTEBOOKS_PATH
 #  $PM_POLYMERS_FOLDER_NAME
 #  $_pm_active_notebook
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  returns@
 #
 #  @file functions/pm_get_polymer_path.sh
 ## */

function pm_get_polymer_path {
    pm_debug "pm_get_polymer_path( $@ )"

    local poly="${@-$_pm_active_polymer}"

    echo "${PM_LAB_NOTEBOOKS_PATH}/${_pm_active_notebook}/${PM_POLYMERS_FOLDER_NAME}/${poly}"
}
