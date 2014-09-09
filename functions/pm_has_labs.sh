## /* @function
 #  @usage pm_has_labs
 #
 #  @output true (on error)
 #
 #  @description
 #  This function determines if there are any existing labs that polymerge knows
 #  about.
 #  description@
 #
 #  @examples
 #  if pm_has_labs; then
 #      # ...
 #  fi
 #  examples@
 #
 #  @dependencies
 #  $PM_LAB_NOTEBOOKS_PATH
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_list_notebooks.sh
 #  functions/pm_validate_lab_from_notebook.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution; labs exist
 #  1 - $PM_LAB_NOTEBOOKS_PATH could not be found
 #  2 - could not find any existing notebooks
 #  4 - no valid labs found
 #  returns@
 #
 #  @file functions/pm_has_labs.sh
 ## */

function pm_has_labs {
    pm_debug "pm_has_labs( $@ )"

    local retVal=0 notebooks=$( pm_list_notebooks ) nb

    if [ ! -d "$PM_LAB_NOTEBOOKS_PATH" ]; then
        # echo "${E} ERROR: ${X} \$PM_LAB_NOTEBOOKS_PATH is not a directory. Try executing \`polymerge reinstall\`"
        # echo "on the command line and try this operation again."
        pm_err -q "pm_has_labs(): \$PM_LAB_NOTEBOOKS_PATH is not a directory:  ${PM_LAB_NOTEBOOKS_PATH}"
        retVal=1

    elif [ -z "$notebooks" ]; then
        retVal=2

    else
        retVal=4
        for nb in $notebooks; do pm_validate_lab_from_notebook "$nb" && retVal=0; done
    fi

    pm_debug "pm_has_labs() -> ${retVal}"
    return $retVal
}
