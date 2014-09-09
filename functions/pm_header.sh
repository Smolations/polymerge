## /* @function
 #  @usage pm_header
 #
 #  @output true
 #
 #  @exports
 #  $menu_choice
 #  exports@
 #
 #  @description
 #  This function begins by clearing the screen. Then it displays the masthead and
 #  basic information about the state of the application. It indicates what polymer
 #  is the active polymer, and what lab/notebook polymerge is currently working
 #  with. Finally, it also displays the most recently chosen menu choice.
 #
 #  ASCII art from: http://patorjk.com/software/taag/
 #  description@
 #
 #  @dependencies
 #  $PM_MASTHEAD_PATH
 #  $_pm_active_lab
 #  $_pm_active_lab_styled
 #  $_pm_active_polymer_styled
 #  $menu_choice
 #  `printf`
 #  functions/pm_debug.sh
 #  dependencies@
 #
 #  @file functions/pm_header.sh
 ## */

function pm_header {
    pm_debug "pm_header( $@ )"

    local activeLab="${_pm_active_lab_styled}  (notebook: ${_pm_active_notebook})"
    [ -z "$_pm_active_lab" ] && activeLab=

    clear

    echo
    cat "$PM_MASTHEAD_PATH"
    echo
    echo $headerTop
    printf '  %18s  %-52s \n' 'Active Laboratory:' "$activeLab"
    printf '  %18s  %-52s \n' 'Active Polymer:' "${_pm_active_polymer_styled}"
    echo $headerBottom

    if [ -n "${menu_choice}" ];then
        export menu_choice="${menu_choice%%:*}:${X}"
        echo ${X}
        echo "${menu_choice}"
    fi
    echo
}
