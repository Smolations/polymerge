## /* @function
 #  @usage pm_init_log
 #
 #  @output true
 #
 #  @description
 #  This function manages a single log file in such a way that file size informs
 #  processing. It also inserts a few lines of details and separators to discern
 #  separate logging sessions.
 #  description@
 #
 #  @dependencies
 #  $PM_LOG_FILE_NAME
 #  $PM_LOG_MAX_SIZE
 #  $PM_LOG_PATH
 #  `cat`
 #  `cut`
 #  `du`
 #  `touch`
 #  functions/pm_debug.sh
 #  functions/pm_log.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  returns@
 #
 #  @file functions/pm_init_log.sh
 ## */

function pm_init_log {
    pm_debug "pm_init_log( $@ )"

    echo "Initializing log file session..."

    # this will get the log size in kb. truncate it if oversized.
    # TODO: pass these values in
    local maxSize=$PM_LOG_MAX_SIZE logFile="${PM_LOG_PATH}/${PM_LOG_FILE_NAME}" logSize
    local sysLogBr='----------------------------------------------------------------'

    touch "$logFile"

    logSize=$( du -sk "$logFile" | cut -f 1 )

    if [ $logSize ] && (( $logSize > $maxSize )); then
        echo -n "  \`- Log file over ${maxSize}kb. Truncating..."
        : > "$logFile"
        pm_log "File truncated on $(date). File size was over ${maxSize}kb  (${logSize}kb)."
        pm_log ""
        echo 'done.'
    fi

    cat >> "$logFile" <<LOGSTART


    ${sysLogBr}
                  Polymerge Session  -  $(date)
    ${sysLogBr}
    Log Size     = ${logSize}kb"
    Log Max Size = ${maxSize}kb"

LOGSTART

    echo "  \`- Log file location: ${Q}${logFile}${X}" && echo
}
