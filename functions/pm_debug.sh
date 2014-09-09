## /* @function
 #  @usage pm_debug [-n] [<input>]
 #  @usage `some-command` | pm_debug [-n]
 #
 #  @output false
 #
 #  @description
 #  This function provides an easy way to send debugging information to the
 #  polymerge log file. Any <input> passed to this function will be prepended with
 #  "[DEBUG]" in order to differentiate it from other levels of logging.
 #  description@
 #
 #  @options
 #  -n      Omit associated timestamp in the log for <input>.
 #  options@
 #
 #  @notes
 #  - This function passes input through to pm_log, which, in turn, passes data to
 #  __log. Piping output into this function is possible because of the nature of
 #  stdin and the way __log is implemented.
 #  - Empty strings may be passed to this function in order to create blank lines in
 #  the log.
 #  notes@
 #
 #  @examples
 #  # remove timestamp from log so some separation is present
 #  pm_debug -n "$ git status"
 #  git status | pm_debug
 #  examples@
 #
 #  @dependencies
 #  functions/pm_log.sh
 #  dependencies@
 #
 #  @returns
 #  Exit code from pm_log
 #  returns@
 #
 #  @file functions/pm_debug.sh
 ## */

function pm_debug {
    if [ "$PM_DEBUG" == "true" ]; then
        if [ "$1" == "-n" ]; then
            shift
            pm_log -n "[DEBUG]  $@"
        else
            pm_log "[DEBUG]  $@"
        fi
    fi
}
