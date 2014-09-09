## /* @function
 #  @usage pm_build_menu_options
 #
 #  @output false
 #
 #  @description
 #  The purpose of this function is purely to remove the logic contained herein from
 #  pm_main_menu. This process needs to be refactored in the future.
 #
 #  The logic defined in this function determines which menu options should be
 #  displayed to the user at any given time. It works heavily on the values for
 #  $_pm_active_lab, $_pm_active_notebook, and $_pm_active_polymer.
 #  description@
 #
 #  @options
 #  options@
 #
 #  @notes
 #  - This function assumes the values of variables defined in pm_main_menu, so it
 #  is quite unstable. Keep this in mind when menu option variable names are
 #  modified in pm_main_menu.
 #  notes@
 #
 #  @dependencies
 #  [all menu option vars from pm_main_menu]
 #  [vars from lib/functionsh/functions/__get_env.sh]
 #  $PM_LOG_FILE_PATH
 #  $PM_NOTEBOOK_FETCH_DELAY
 #  $_pm_active_lab
 #  $_pm_active_notebook
 #  $_pm_active_polymer
 #  `cat`
 #  `date`
 #  `grep`
 #  `ls`
 #  `stat`
 #  `tr`
 #  `wc`
 #  functions/pm_debug.sh
 #  functions/pm_git.sh
 #  functions/pm_get_active_lab.sh
 #  functions/pm_get_active_polymer.sh
 #  functions/pm_has_labs.sh
 #  functions/pm_notebook_has_remote.sh
 #  functions/pm_polymers_changed.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  returns@
 #
 #  @file functions/pm_build_menu_options.sh
 ## */

function pm_build_menu_options {
    pm_debug "pm_build_menu_options( $@ )"

    ## filter menu items based on certain conditions. attempt to build up the
    ## menu sequentially, from top to bottom

    local fetchTime localTime polys numMonomers numPolymers

    # make sure we have fresh references
    pm_get_active_lab
    pm_get_active_polymer


    # monomer opts require active polymer/lab
    if [ -n "$_pm_active_lab" ] && [ -n "$_pm_active_polymer" ]; then
        # some options only valid depending on the number of monomers in a polymer definition
        numMonomers=$( cat  "${polymersPath}/${_pm_active_polymer}" | wc -l | tr -d ' ' )
        pm_debug "numMonomers = [$numMonomers]"

        optMonomerView+=" (${numMonomers})"

        case $numMonomers in
            # 0 - view, add
            0)
                menuOpts+=( "$optMonomerView" "$optMonomerAdd" );;

            # 1 - view, add, remove, remerge, clean
            1)
                menuOpts+=( "$optMonomerView" "$optMonomerAdd" "$optMonomerRemove" )
                menuOpts+=( "$optMonomerRemerge" "$optMonomerPrune" );;

            # 2+ - all
            *)
                menuOpts+=( "$optMonomerView" "$optMonomerAdd" "$optMonomerRemove" )
                menuOpts+=( "$optMonomerReorder" "$optMonomerRemerge" "$optMonomerPrune" )
        esac
    fi

    # polymer opts require active lab
    # notebook opts require active lab
    if [ -n "$_pm_active_lab" ]; then
        # some options only valid when there are 1+ polymer definitions
        numPolymers=$( ls -1 "$polymersPath" | wc -l | tr -d ' ' )
        pm_debug "numPolymers = [${numPolymers}]"

        optPolymerChoose+=" (${numPolymers})"  # might have to ditch the arrays holding all options to make this work..

        case $numPolymers in
            # 0 - create
            0)
                menuOpts+=( "$optPolymerCreate" );;

            # 1 - if no active polymer, user can access all options.
            #     if active polymer, user only sees create/remove (not choose)
            1)
                if [ -z "$_pm_active_polymer" ]; then
                    menuOpts+=( "$optPolymerChoose" "$optPolymerCreate" "$optPolymerRemove" )
                else
                    menuOpts+=( "$optPolymerCreate" "$optPolymerRemove" )
                fi;;

            # 2+ - all
            *)
                menuOpts+=( "$optPolymerChoose" "$optPolymerCreate" "$optPolymerRemove" )
        esac

        # push/pull for a notebook repo requires a remote
        if pm_notebook_has_remote "$_pm_active_notebook"; then
            localTime=$( date +%s 2>/dev/null )

            # look for updates for an active lab's notebook based on
            # unix timestamp since last fetch
            if [ $_ENV_OSX ]; then
                fetchTime=$( stat -f '%m' "${nbPath}/.git/FETCH_HEAD" 2>"$PM_LOG_FILE_PATH" || echo 0 )

            elif [ $_ENV_LINUX ]; then
                fetchTime=$( stat -c %Y "${nbPath}/.git/FETCH_HEAD" 2>"$PM_LOG_FILE_PATH" || echo 0 )

            else
                # if there was an issue with environments, just spoof automatic fetching
                fetchTime=0
                localTime=1
            fi

            pm_debug "localTime(${localTime}) - fetchTime(${fetchTime})"
            pm_debug "$(( localTime - fetchTime )) >? PM_NOTEBOOK_FETCH_DELAY(${PM_NOTEBOOK_FETCH_DELAY})"

            if (( localTime - fetchTime > PM_NOTEBOOK_FETCH_DELAY )); then
                pm_git --nb="${_pm_active_notebook}" fetch
            fi

            if pm_polymers_changed "${_pm_active_notebook}"; then
                menuOpts+=( "$optNotebookPush" )
            fi

            # local repo is behind
            if pm_git -v --nb="${_pm_active_notebook}" rev-list --left-right ..@{u} | grep -q '>'; then
                menuOpts+=( "$optNotebookPull" )
            fi
        fi

        [ $numPolymers -gt 0 ] && menuOpts+=( "$optNotebookAudit" )
    fi

    # lab opts are independent
    # labOpts+=( "$optLabSwitch" "$optLabAdd" "$optLabRemove" )
    if [ -z "$_pm_active_lab" ]; then
        # we dont have an active lab. do we have any labs?
        if pm_has_labs; then
            pm_debug "labs exist"
            menuOpts+=( "$optLabSwitch" "$optLabAdd" "$optLabRemove" )

        else
            # no labs. only give user option to add
            pm_debug "no labs"
            menuOpts+=( "$optLabAdd" )
        fi

    else
        menuOpts+=( "$optLabSwitch" "$optLabAdd" "$optLabRemove" )
    fi

    # these options are present in the menu at all times
    menuOpts+=( "$optInfo" "$optMasthead" "$optExit" )
}
