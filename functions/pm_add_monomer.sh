## /* @function
 #  @usage pm_add_monomer <branch-name>
 #
 #  @output true (on error)
 #
 #  @description
 #  The purpose of this function is to add a single monomer branch to the currently
 #  active polymer. When a <branch-name> is passed to this function, it is added to
 #  the top of the active polymer definition (as long as it isn't already there).
 #  description@
 #
 #  @dependencies
 #  `cat`
 #  `grep`
 #  `rm`
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_get_polymer_path.sh
 #  functions/pm_mktemp.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - no arguments passed to function
 #  2 - could not locate containing polymer definition file
 #  4 - monomer already exists in polymer
 #  8 - failed to create temporary file for operation
 #  returns@
 #
 #  @file functions/pm_add_monomer.sh
 ## */

function pm_add_monomer {
    pm_debug "pm_add_monomer( $@ )"

    local retVal=0 polyPath=$( pm_get_polymer_path ) monomer="$@"

    if [ $# == 0 ]; then
        pm_err "I'm sorry, what mono branch are you trying to add?"
        retVal=1

    elif [ ! -f "$polyPath" ]; then
        pm_err "Unable to locate poly at: ${polyPath}"
        retVal=2

    elif grep -q "^$@$" "$polyPath"; then
        pm_err "Cannot add mono because it has already been added."
        retVal=4

    elif pm_mktemp; then
        # add the branch to the list
        echo "$monomer" > "$_pm_temp_file"
        cat "$polyPath" >> "$_pm_temp_file"
        cat "$_pm_temp_file" > "$polyPath"
        rm -f "$_pm_temp_file"

    else
        pm_err "Unable to add mono branch to polymer. Could not create temporary file."
        retVal=8
    fi

    pm_debug "pm_add_monomer() -> ${retVal}"
    return $retVal
}
