## /* @function
 #  @usage pm_remove_monomer <monomer-name>
 #
 #  @output true
 #
 #  @description
 #  This function makes it easy to remove a branch from the active polymer. As
 #  always, the delete operation includes a confirmation prompt for the user.
 #  description@
 #
 #  @dependencies
 #  `cat`
 #  `egrep`
 #  `grep`
 #  `rm`
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_get_polymer_path.sh
 #  functions/pm_mktemp.sh
 #  lib/functionsh/functions/__yes_no.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution OR user asserts negative for removal confirmation
 #  1 - no arguments passed to function
 #  2 - path to active polymer not found
 #  4 - monomer is not in active polymer definition
 #  8 - unable to create temp file for removal operation
 #  returns@
 #
 #  @file functions/pm_remove_monomer.sh
 ## */

function pm_remove_monomer {
    pm_debug "pm_remove_monomer( $@ )"

    local retVal=0 monomer="$@" branch
    local polyPath=$( pm_get_polymer_path )

    if [ $# == 0 ]; then
        pm_err "Pssst! Which mono, bro? See log for details."
        retVal=1

    elif [ ! -f "$polyPath" ]; then
        pm_err "Unable to locate active poly at: ${polyPath}"
        retVal=2

    elif ! grep -q "$monomer" "$polyPath"; then
        pm_err "Cannot remove mono because it is not in the poly definition."
        retVal=4

    else
        __yes_no --default=n "Are you sure you want to remove \`${monomer}\`"

        if [ $_yes ]; then
            if pm_mktemp; then
                while read -u 3 branch; do
                    [ -z "$branch" ] && continue
                    ! egrep -q "^${monomer}$" <<< "$branch" && echo "$branch" >> "$_pm_temp_file"
                done 3< "$polyPath"

                # pm_debug "  copy _pm_temp_file into build list"
                cat "$_pm_temp_file" > "$polyPath"
                rm -f "$_pm_temp_file"

            else
                pm_err "I am Locutus of Borg. See log for details."
                retVal=8
            fi
        fi
    fi

    pm_debug "pm_remove_polymer() -> ${retVal}"
    return $retVal
}
