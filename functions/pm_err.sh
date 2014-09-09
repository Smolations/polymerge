## /* @function
 #  @usage pm_err [-q] <input>
 #
 #  @output true (without -q option)
 #
 #  @description
 #  This function provides an easy way to send error information to the polymerge
 #  log file. Any <input> passed to this function will be prepended with "[ERROR]"
 #  in the log file in order to differentiate it from other levels of logging. In
 #  addition, the error message is displayed to the user unless otherwise specified
 #  via the -q option.
 #  description@
 #
 #  @options
 #  -q      Suppress output to stdout (quiet).
 #  options@
 #
 #  @notes
 #  - Output is sent to stderr instead of stdout.
 #  notes@
 #
 #  @examples
 #  pm_err "The user needs to see this. Frildo."
 #  pm_err -q "There was an error, but the user doesn't need to see it."
 #  examples@
 #
 #  @dependencies
 #  functions/pm_log.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  returns@
 #
 #  @file functions/pm_err.sh
 ## */

function pm_err {
    local quiet=

    [ "$1" == "-q" ] && quiet=true && shift

    pm_log "[ERROR]  $@"
    [ ! $quiet ] && echo "${E} ERROR: ${X} $@" 1>&2
}
