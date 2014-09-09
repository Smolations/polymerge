## /* @function
 #  @usage __main_menu
 #
 #  @output true
 #
 #  @exports
 #  $menu_choice
 #  exports@
 #
 #  @description
 #  This function kicks off the main functionality of the application. If run in a
 #  loop, it mimics and menu-driven application. All of the menu options and their
 #  main implementations are here in this function.
 #  description@
 #
 #  @dependencies
 #  $PM_POLYMERS_FOLDER_NAME
 #  $PM_LAB_NOTEBOOKS_PATH
 #  $_pm_active_notebook
 #  $_pm_active_lab_styled
 #  $_pm_active_polymer_styled
 #  functions/pm_add_lab.sh
 #  functions/pm_add_monomer.sh
 #  functions/pm_build_menu_options.sh
 #  functions/pm_choose_lab.sh
 #  functions/pm_choose_monomer.sh
 #  functions/pm_choose_polymer.sh
 #  functions/pm_choose_remote_monomer.sh
 #  functions/pm_continue.sh
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_header.sh
 #  functions/pm_info.sh
 #  functions/pm_list_monomers.sh
 #  functions/pm_list_polymers.sh
 #  functions/pm_polymers_changed.sh
 #  functions/pm_prune_monomers.sh
 #  functions/pm_prune_polymers.sh
 #  functions/pm_push_notebook.sh
 #  functions/pm_remerge_polymer_and_push_change.sh
 #  functions/pm_remove_lab.sh
 #  functions/pm_remove_monomer.sh
 #  functions/pm_remove_polymer.sh
 #  functions/pm_reorder_monomers.sh
 #  functions/pm_set_active_lab.sh
 #  functions/pm_set_active_polymer.sh
 #  functions/pm_set_masthead.sh
 #  functions/pm_update_repo.sh
 #  functions/pm_view_monomers.sh
 #  functions/pm_view_polymers.sh
 #  lib/functionsh/functions/__menu.sh
 #  lib/functionsh/functions/__short_ans.sh
 #  lib/functionsh/functions/__yes_no.sh
 #  dependencies@
 #
 #  @file functions/__main_menu.sh
 ## */

function pm_main_menu {
    pm_debug "pm_main_menu( $@ )"

    declare -a menuOpts monomerOpts polymerOpts notebookOpts labOpts
    local polymersPath numMonomers numPolymers lab poly rmActivePoly=

    local curLab="\`${_pm_active_lab_styled}\`${STYLE_MENU_OPTION}"
    local curPoly="\`${_pm_active_polymer_styled}\`${STYLE_MENU_OPTION}"

    local optMonomerView="${A}View${X}${STYLE_MENU_OPTION} monomer branches in ${curPoly}"
    local optMonomerAdd="${A}Add${X}${STYLE_MENU_OPTION} a monomer branch to ${curPoly}"
    local optMonomerRemove="${A}Remove${X}${STYLE_MENU_OPTION} a monomer branch from ${curPoly}"
    local optMonomerReorder="${A}Re-Order${X}${STYLE_MENU_OPTION} monomer branches in ${curPoly}"
    local optMonomerRemerge="${A}Re-Merge${X}${STYLE_MENU_OPTION} the monomer branches in ${curPoly}"
    local optMonomerPrune="${A}Prune${X}${STYLE_MENU_OPTION} monomer branches in ${curPoly}"

    local optPolymerChoose="${A}Choose${X}${STYLE_MENU_OPTION} a new active polymer branch"
    local optPolymerCreate="${A}Create${X}${STYLE_MENU_OPTION} a new polymer branch in your notebook"
    local optPolymerRemove="${A}Remove${X}${STYLE_MENU_OPTION} an existing polymer branch from your notebook"

    local optNotebookPull="${A}Pull${X}${STYLE_MENU_OPTION} notebook changes down from team"
    local optNotebookPush="${A}Push${X}${STYLE_MENU_OPTION} notebook changes out to team"
    local optNotebookAudit="${A}Prune${X}${STYLE_MENU_OPTION} notebook (remove integrated polymer branches)"

    local optLabSwitch="${A}Choose${X}${STYLE_MENU_OPTION} a new active laboratory"
    local optLabAdd="${A}Add${X}${STYLE_MENU_OPTION} a new laboratory"
    local optLabRemove="${A}Remove${X}${STYLE_MENU_OPTION} an existing laboratory"

    local optInfo="See information about polymerge and its current state"
    local optMasthead="Change masthead"
    local optExit="Exit"


    local nbPath="${PM_LAB_NOTEBOOKS_PATH}/${_pm_active_notebook}"
    local polymersPath="${nbPath}/${PM_POLYMERS_FOLDER_NAME}"



    ## here we go! build menu options, show header, and then main menu
    export menu_choice=
    pm_build_menu_options
    pm_header

    # pm_debug "\${#menuOpts[@]} = ${#menuOpts[@]}"
    __menu "${menuOpts[@]}"

    # if user chooses a non-exit action, re-display the header with the
    # action, ready for processing the action itself
    if [ -n "$_menu_sel_value" ]; then
        export menu_choice="$_menu_sel_value"
        pm_header
    fi
    pm_debug "pm_main_menu() - user chose:  ${menu_choice}"


    case "$_menu_sel_value" in
        # view all monomer branches in active polymer branch
        "$optMonomerView")
            # omitting notebook update here...
            pm_view_monomers
            pm_continue;;


        # add a monomer branch to active polymer branch
        "$optMonomerAdd")
            pm_update_repo --lab="$_pm_active_lab"
            until [ $snarf ]; do
                pm_header
                echo "The laboratory repository has been fetched, so you can choose from"
                echo "all available branches on the remote. \`polymerge\` uses pattern"
                echo "matching to find available branches to add, so you don't need to"
                echo "enter the full branch name when choosing a branch to add."
                echo
                echo "Current monomers:"
                echo "-----------------"
                pm_list_monomers || echo "(Unable to retrieve current monomers)"
                echo
                echo
                echo
                __short_ans "Enter ANY part of a branch name to add (or press Enter to abort):"
                [ -z "$_ans" ] && break

                pm_header
                if ! pm_choose_remote_monomer "$_ans"; then
                    pm_continue
                    continue

                elif [ -z "$_pm_remote_monomer_choice" ]; then
                    continue
                fi

                echo
                pm_add_monomer "$_pm_remote_monomer_choice" || pm_continue
            done

            if pm_polymers_changed "$_pm_active_notebook"; then
                pm_remerge_polymer_and_push_change
                pm_continue
            fi;;


        # remove a monomer branch from active polymer branch
        "$optMonomerRemove")
            until [ $snarf ]; do
                pm_header
                pm_choose_monomer || break
                if [ -n "$_pm_monomer_choice" ]; then
                    echo
                    pm_remove_monomer "$_pm_monomer_choice" || pm_continue
                fi
            done

            if pm_polymers_changed "$_pm_active_notebook"; then
                pm_remerge_polymer_and_push_change
                pm_continue
            fi;;


        # reorder monomer branches in active polymer branch
        "$optMonomerReorder")
            _no=
            until [ $_no ]; do
                pm_header
                pm_reorder_monomers
                # user aborted operation
                [ $? == -1 ] && break
                echo
                echo
                __yes_no --default=n "Would you like to re-order monomer branches again"
            done

            if pm_polymers_changed "$_pm_active_notebook"; then
                pm_remerge_polymer_and_push_change
                pm_continue
            fi;;


        # re-merge monomer branches in active polymer branch
        "$optMonomerRemerge")
            pm_view_monomers
            pm_remerge_polymer_and_push_change
            pm_continue
            ;;


        # remove integrated monomer branches from active polymer branch
        "$optMonomerPrune")
            pm_update_repo --lab="$_pm_active_lab"
            echo

            if pm_prune_monomers && pm_polymers_changed "$_pm_active_notebook"; then
                echo
                pm_remerge_polymer_and_push_change
            fi

            pm_continue;;


        # set new active polymer
        "$optPolymerChoose")
            if pm_choose_polymer && [ -n "$_pm_polymer_choice" ]; then
                pm_set_active_polymer "$_pm_polymer_choice"
            fi;;


        # create new polymer
        "$optPolymerCreate")
            export _no=
            until [ $_no ]; do
                pm_header

                echo "Polymer branches are meant to contain various monomer branches which will"
                echo "be merged together sequentially. The name of a polymer branch must be unique,"
                echo "adhere to git's branch-naming requirements, and must NOT be named \`master\`."
                echo
                echo "Current polymers:"
                echo "-----------------"
                pm_list_polymers || echo "(Unable to retrieve current polymers)"
                echo
                echo
                echo
                __short_ans "Enter new polymer branch name (or press Enter to abort):"
                if [ -n "$_ans" ]; then
                    # validate branch name. thanks git!
                    # TODO: should the remote be checked for this branch name to warn the user?
                    if [ ! -f "${polymersPath}/${_ans}" ] && [ "$_ans" != 'master' ] && pm_git --pm is-branch-valid "${_ans}"; then
                        touch "${polymersPath}/${_ans}"
                        echo
                        __yes_no --default=y "Make \`${_ans}\` the current active polymer"
                        [ $_yes ] && pm_set_active_polymer "$_ans" || _no=

                    else
                        echo
                        pm_err "You've entered an invalid branch name. If the branch name you entered"
                        pm_err "is well-formed, it may already exist."
                        echo
                        __yes_no --default=y "Try again"
                    fi

                else
                    _no=true
                fi
            done;;


        # remove a polymer
        "$optPolymerRemove")
            # just need a loop here. will break from within when a user chooses
            # to abort, makes a selection, or if functions within functions below fail.
            until [ $snarf ]; do
                pm_header
                echo "Alternatively, you could choose \"${optNotebookAudit}\""
                echo "from the main menu. Choosing that option will remove any polymer branches already"
                echo "merged into your active lab repository's mainline branch (usually \`master\`)."
                echo
                pm_choose_polymer || break
                if [ -n "$_pm_polymer_choice" ]; then
                    echo
                    pm_remove_polymer "$_pm_polymer_choice" || pm_continue
                fi
            done;;


        # pull notebook changes down from team
        "$optNotebookPull")
            pm_update_repo --nb="$_pm_active_notebook";;


        # push notebook changes out to team (if polymers have changed)
        "$optNotebookPush")
            pm_push_notebook
            pm_continue;;


        # TODO: remove integrated polymers from notebook
        "$optNotebookAudit")
            pm_prune_polymers
            pm_continue

            pm_header
            pm_view_polymers
            echo

            if pm_polymers_changed "$_pm_active_notebook"; then
                pm_push_notebook
            else
                echo "Either no branches have been merged into \`master\` or no"
                echo "changes were made."
            fi

            pm_continue;;


        # switch to a different laboratory
        "$optLabSwitch")
            pm_choose_lab --filter="$_pm_active_lab"

            if [ -n "$_pm_lab_choice" ]; then
                pm_set_active_lab "$_pm_lab_choice"
            fi;;


        # add a laboratory
        "$optLabAdd")
            __short_ans "Enter the git clone URL for the notebook repository in your laboratory:"
            echo

            if [ -z "$_ans" ]; then
                pm_err "Invalid URL (${_ans}). Back to menu..."

            else
                pm_add_lab "$_ans"
            fi

            pm_continue;;


        # remove a laboratory
        "$optLabRemove")
            pm_choose_lab

            if [ -n "$_pm_lab_choice" ]; then
                echo
                if [ "${_pm_lab_choice%% *}" == "$_pm_active_lab" ]; then
                    echo "You have chosen a laboratory which is currently active. You will"
                    echo "need to set a new active laboratory after this operation is complete."
                    echo
                fi

                pm_remove_lab "${_pm_lab_choice%% *}"
                pm_continue

            else
                pm_debug "pm_remove_lab() empty _pm_lab_choice"
            fi;;


        # information! log file location, files being maintained by polymerge, etc
        "$optInfo")
            pm_info;;


        # change masthead
        "$optMasthead")
            local mhs=( `ls "${POLYMERGE_PATH}/mastheads"` )
            __menu ${mhs[@]}
            if [ -n "$_menu_sel_value" ]; then
                if ! pm_set_masthead $_menu_sel_value; then
                    pm_err "Sorry, unable to set new masthead."
                    pm_continue
                fi
            fi;;

        *)
            # TODO: pm_reset and explanation
            echo "Choice didn't match any menu option. Now exiting."
            return 1
    esac

    return 0
}
