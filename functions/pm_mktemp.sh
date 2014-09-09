## /* @function
 #  @usage pm_mktemp [<file-prefix>]
 #
 #  @output false
 #
 #  @exports
 #  $_pm_temp_file
 #  exports@
 #
 #  @description
 #  Creates a temporary file for polymerge use. If a <file-prefix> is given, it will
 #  be used as the file name. If not, "polymerge" will be the name of the file.
 #  description@
 #
 #  @examples
 #  if pm_mktemp; then
 #      cat file.txt > $_pm_temp_file
 #      less $_pm_temp_file
 #      rm -f $_pm_temp_file
 #  fi
 #  examples@
 #
 #  @dependencies
 #  `mktemp`
 #  functions/pm_debug.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - temp file was not created
 #  returns@
 #
 #  @file functions/pm_mktemp.sh
 ## */

function pm_mktemp {
    pm_debug "pm_mktemp( $@ )"

    local retVal=0 tmpFile="${@:-polymerge}"
    _pm_temp_file=

    if [ -z "$TMPDIR" ]; then
        tmpFile=$( mktemp -q "/tmp/${tmpFile}.XXX" )
    else
        tmpFile=$( mktemp -q -t "${tmpFile}" )
    fi

    [ -f "$tmpFile" ] && _pm_temp_file="$tmpFile" || retVal=1

    export _pm_temp_file

    pm_debug "_pm_temp_file = ${_pm_temp_file}"

    pm_debug "pm_mktemp() -> ${retVal}"
    return $retVal
}
