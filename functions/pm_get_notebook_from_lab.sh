## /* @function
 #  @usage pm_get_notebook_from_lab <lab-name>
 #
 #  @output false
 #
 #  @description
 #  This function is responsible for parsing the lab repo file in a notebook repo,
 #  given a <lab-name>, in order to determine which notebook points at that
 #  particular repository.
 #  description@
 #
 #  @examples
 #  nb=$( pm_get_notebook_from_lab "my-lab-repo-name" )
 #  examples@
 #
 #  @dependencies
 #  $PM_LAB_NOTEBOOKS_PATH
 #  $PM_LAB_REPO_FILE_NAME
 #  $PM_LAB_REPOS_PATH
 #  `egrep`
 #  dependencies@
 #
 #  @returns
 #  0  - successful execution
 #  1  - no lab given
 #  2  - lab repo doesnt exist
 #  4  - notebook repo doesnt exist
 #  8  - name couldnt be parsed
 #  16 - name was parsed incorrectly
 #  returns@
 #
 #  @file functions/pm_get_notebook_from_lab.sh
 ## */

function pm_get_notebook_from_lab {
    pm_debug "pm_get_notebook_from_lab( $@ )"

    local retVal=0 lab="$@"

    if [ -z "$lab" ]; then
        retVal=1

    elif [ ! -d "${PM_LAB_REPOS_PATH}/${lab}" ]; then
        retVal=2

    else
        # recursively search notebooks for the lab repo url
        nb=$( egrep -Rl "/${lab}(\\.git)?$" "$PM_LAB_NOTEBOOKS_PATH" )

        if [ -z "$nb" ]; then
            retVal=4

        else
            nb=${nb%/${PM_LAB_REPO_FILE_NAME}}
            nb=${nb##*/}

            if [ -z "$nb" ]; then
                retVal=8

            elif [ ! -d "${PM_LAB_NOTEBOOKS_PATH}/${nb}" ]; then
                retVal=16

            else
                echo $nb
            fi
        fi
    fi

    pm_debug "pm_get_notebook_from_lab() -> ${retVal}"
    return $retVal
}
