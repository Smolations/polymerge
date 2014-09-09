## /* @function
 #  @usage polymerge
 #  @usage polymerge update
 #
 #  @output true
 #
 #  @description
 #  This function is the main driver for functionality in polymerge. This function
 #  starts the polymerge interface, as well as provides some quick functionality
 #  on the command line.
 #  description@
 #
 #  @options
 #  options@
 #
 #  @notes
 #  This function is under active development. Currently, there is only one
 #  subcommand when using polymerge on the command line, while the GUI interface
 #  works.
 #  notes@
 #
 #  @dependencies
 #  $PM_ACTIVE_LAB_FILE_PATH
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_get_active_lab.sh
 #  functions/pm_header.sh
 #  functions/pm_init_log.sh
 #  functions/pm_main_menu.sh
 #  functions/pm_reset_notebook.sh
 #  functions/pm_update_polymerge.sh
 #  functions/pm_update_repo.sh
 #  lib/functionsh/functions/__str_repeat.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  returns@
 #
 #  @file functions/polymerge.sh
 ## */

function polymerge {
    pm_init_log

    pm_debug "polymerge( $@ )"

    local headerTop=$( __str_repeat '_' 72 )
    local headerBottom=$( __str_repeat '¯' 72 )
    local menuFlag=

    touch "$PM_ACTIVE_LAB_FILE_PATH"


    # pm_main_menu runs these, but it should also be run for one-off commands
    pm_get_active_lab
    # pm_get_active_polymer

    # need to add a --quiet option for pm_update_repo
    [ -n "$_pm_active_notebook" ] && pm_update_repo --nb="$_pm_active_notebook"

    if [ $# == 0 ]; then
        # start polymerge main menu
        until [ $menuFlag ]; do
            pm_main_menu || menuFlag=true
        done

        if [ -n "$_pm_active_notebook" ]; then
            pm_header
            echo "In order to prevent divergence of your local notebook when compared to"
            echo "the remote, your active notebook will now be reset, erasing any unsaved"
            echo "changes."

            if ! pm_reset_notebook "$_pm_active_notebook"; then
                echo
                pm_err "There was a problem when attempting to reset ${_pm_active_notebook}."
                pm_err "You may need to troubleshoot this issue manually by inspecting polymerge's"
                pm_err "copy of your laboratory. You can find the path by choosing to view polymerge"
                pm_err "information from the main menu (third-to-last option)."
            fi
        fi

    else
        case "$1" in
            add-project)
                :
            ;;

            reinstall)
                :
            ;;

            see-list)
                :
            ;;

            update)
                pm_update_polymerge;;

            *)
                echo "Your choice was not understood. Valid options are:"
                echo "  update"
        esac
    fi
}
