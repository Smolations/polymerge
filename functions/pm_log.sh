## /* @function
 #  @usage pm_log [-n] [<input>]
 #  @usage `some-command` | pm_log [-n]
 #
 #  @output false
 #
 #  @description
 #  This function wraps the __log function brought in by the functionsh project (see
 #  github.com/Smolations/functionsh). This allows polymerge to use a pre-defined
 #  logging function pointing to its own log file. This function takes on almost all
 #  of the properties of __log.
 #  description@
 #
 #  @options
 #  -n      Omit associated timestamp in the log for <input>.
 #  options@
 #
 #  @notes
 #  - Piping output into this function is possible because of the nature of stdin
 #  and the way __log is implemented.
 #  - Empty strings may be passed to this function in order to create blank lines in
 #  the log.
 #  notes@
 #
 #  @examples
 #  pm_log -n
 #  pm_log "-- Starting file read..."
 #  cat myfile.txt | pm_log -n
 #  pm_log "-- File read complete."
 #  pm_log -n
 #  examples@
 #
 #  @dependencies
 #  $PM_LOG_FILE_PATH
 #  lib/functionsh/functions/__log.sh
 #  dependencies@
 #
 #  @returns
 #  Exit code from __log
 #  returns@
 #
 #  @file functions/pm_log.sh
 ## */

function pm_log {
    __log --file="$PM_LOG_FILE_PATH" $@
}
