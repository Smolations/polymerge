## /* @function
 #  @usage pm_validate_lab <lab-name>[ <lab-name> [...]]
 #
 #  @output true (on error)
 #
 #  @description
 #  When working with labs, polymerge needs a way to determine if a given lab is
 #  valid. This function will take the given <lab-name> and determine if both a
 #  lab repo and a notebook repo exist for that name. A failure exit code is
 #  returned if no argumewnts are passed or if some part of the validation fails.
 #
 #  It should be evident from the @usage that multiple labs can be validated at
 #  the same time. In this case, if even ONE of the given labs is invalid, this
 #  function will return failure.
 #  description@
 #
 #  @dependencies
 #  functions/pm_debug.sh
 #  functions/pm_err.sh
 #  functions/pm_get_notebook_from_lab.sh
 #  dependencies@
 #
 #  @returns
 #  0 - successful execution
 #  1 - no arguments passed to function
 #  2 - unable to locate lab repo with given <lab-name>
 #  4 - unable to locate notebook repo associated with given <lab-name>
 #  returns@
 #
 #  @file functions/pm_validate_lab.sh
 ## */

function pm_validate_lab {
    pm_debug "pm_validate_lab( $@ )"

    local retVal=0 lab nb labRepoPath

    if [ $# == 0 ]; then
        pm_err -q "pm_validate_lab() expects at least one argument."
        retVal=1

    else
        for lab in $@; do

            labRepoPath="${PM_LAB_REPOS_PATH}/${lab}/.git"
            if [ ! -d "$labRepoPath" ]; then
                pm_err -q "pm_validate_lab(): No lab repo found with name '${lab}'."
                retVal=2
                continue
            fi

            # lab repo passed validation. now look for notebook repo
            nb=$( pm_get_notebook_from_lab "$lab" )
            if [ -z "$nb" ]; then
                pm_err -q "pm_validate_lab(): No notebook found for lab '${lab}'."
                retVal=4
            fi

        done
    fi

    pm_debug "pm_validate_lab() -> ${retVal}"
    return $retVal
}
