polymerge
=========

Simply put, *polymerge* is a branch management tool. This idea was spawned while working in a corporate environment (originally by a former colleague, [Chris McCulloh](https://github.com/cmcculloh), later maintained by yours truly) where rapid development/deployment required a way to easily add/remove/re-order branches in a parent wrapper branch for a single release. For example, when individual feature branches are tested, some will pass, and some will fail. However, it may be a requirement that a code release must happen on a given schedule. This necessitates the need for a build to leave out one branch that was previously included. A few keystrokes to polymerge and the wrapper branch is re-built without the offending branch. Keep reading to get a better feel for how *polymerge* works.


Glossary
--------

**_monomer (branch)_** - These are the building blocks of polymers in science. In polymerge, a **monomer** is simply a git branch within a **laboratory repository** (see below).

**_polymer (branch)_** - This is a sequential combination of **monomers**. That is, **monomer branches** are merged together to form a **polymer branch**. These branches also live inside a **laboratory repository**.

**_polymer definition (file)_** - This is a file managed by polymerge, living in the user's **laboratory notebook repository**. It defines a list of monomer branches which make up a polymer branch (in sequential order). Essentially, a **polymer definition file** is simply the on-disk representation of a **polymer branch**.

**_laboratory notebook (repository)_** - Sometimes referred to as a "lab notebook" or "notebook repo," this is a repository the user sets up to contain the **polymer definitions** which polymerge uses to manage git branches. This repo also contains a file to tell polymerge the location of its corresponding **laboratory repository**. The only content of that file is the **laboratory repository's** clone URL.

**_laboratory (repository)_** - Sometimes referred to as a "lab repo," this is the codebase for your team's application. The branches contained in that project are all of the **monomer branches** you will use to create **polymer branches**.

**_laboratory_** - Sometimes referred to as a "lab," a **laboratory** is the combination of a **laboratory notebook repository** and a **laboratory repository**. The name of a laboratory shares the name of its **laboratory repository**. This makes it easier for the user to identify the current repository being managed by polymerge.



How It Works
------------

A polymer has a 1-to-1 relationship with a git branch in a laboratory repo. If you name a polymer as "qa", polymerge will be managing the `qa` branch in the laboratory repo. The user can then add/remove/re-order individual branches to/in these polymers via the polymerge interface. polymerge then deletes the `qa` branch from the laboratory repo remote, re-creates that branch off of the `master` branch, and then sequentially merges in each monomer branch specified in the polymer. If one of those merges presents a conflict, the merge is backed out and the user is notified. polymerge also does a sort of "blame" on the conflict so the developer knows which branch is the culprit. If the very first merge fails, it is likely that the offending monomer branch (which would be the first defined in the polymer) is not up-to-date with `master`, and requires merging or rebasing.

Every laboratory encompasses exactly one lab repo and one notebook repo. Users may have multiple laboratories to manage multiple projects. These labs are mutually exclusive and do not interact with one another. It is the user's responsibility to choose the active laboratory for which operations are completed by polymerge. Luckily, the active laboratory and any active polymers are persisted, so users can pick up where they left off, even after a computer restart!


Requirements
------------

This project was developed on OS X, but _should_ be *nix compatible. I have yet to delve into the process of validating this software within the many *nix environments.

### Dependencies

[functionsh](https://github.com/Smolations/functionsh) - polymerge brings this library in on its own, but users should be aware of its existence

### Notebook Repository Structure

In order for the polymerge project to remain open-source and for teams to manage polymer branches in tandem, a standalone notebook repository is required. This repository should be created in such a way that all team members have read/write access and should have the following structure:

    notebook-repo/
        - polymers/
        - laboratory.repo

The contents of the `laboratory.repo` file should simply be a git clone URL pointing to the repository where polymer branches are to be managed. *polymerge* will then handle cloning and managing both repositories.

**NOTE:** The `polymers/` directory is _somewhat_ optional as it will be created when polymerge is integrated into your shell.


Installation
------------

Clone this repository somewhere on your machine.

    $ cd /path/to/wherever
    $ git clone git@github.com:Smolations/polymerge.git

Add a line to your `~/.bash_profile` or `~/.bashrc`, whichever is sourced for your interactive shell. Note that you must _source_ this file, **not** execute it:

    # ~/.bash_profile or ~/.bashrc

    source /path/to/wherever/polymerge/SOURCEME

To bring in polymerge functionality in your current shell, just run the same `source` command above. Otherwise, polymerge will be initialized and available for every subsequent shell you open.


Usage
-----

polymerge does not update itself automatically, but it _can_ be updated via a command:

    $ polymerge update

Because polymerge is simply a collection of functions, the project can be updated without the risk of replacing files which are currently in use. New functionality will be available immediately.


### Create a Notebook Repository

The first thing you will need to do is create a notebook repository (if a team member has not done so already) following the structure given in the *Requirements* section above. Make sure the `laboratory.repo` file contains the correct URL for the laboratory repository that polymerge will manage with your polymer definitions.


### Add a Laboratory

Once you have your notebook repository set up, you can now add the laboratory to polymerge. Starting polymerge is easy:

    $ polymerge

You will be presented with an initial menu:

                   /)
          __   ___//     ___    _  __  _    _
          /_)_(_)(/_ (_/_// (__(/_/ (_(_/__(/_
       .-/          .-/              .-/
      (_/          (_/              (_/

    ________________________________________________________________________
      Active Laboratory:
         Active Polymer:
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯


      Please make a selection (or press Enter to abort):

        1:  Add a new laboratory
        2:  See information about polymerge and its current state
        3:  Change masthead
        4:  Exit

      Please make a selection (or press Enter to abort):

While working with polymerge, the active laboratory, active notebook, and active polymer are always displayed for reference just under the masthead. Users may only manage one laboratory at a time, and almost all functions in polymerge utilize these active values when performing their operations. This also means that your polymerge menu is contextual, changing based on the configuration and state of each individual laboratory.

Choosing **See information about polymerge and its current state** will display the values of all global variables polymerge uses, as well as information about any laboratories currently added to polymerge. Choosing **Change masthead** will allow you to change the polymerge masthead at the top of the polymerge interface.

Choose the option to add a new laboratory. You will then be prompted for your **_notebook repository's_** URL. Specify the URL and press Enter. polymerge will clone all necessary repositories.


### Set an Active Laboratory

Once the laboratory has been added, you will need to set it as the active laboratory so that polymerge knows where to manage the various polymer branches. Once a laboratory has been added to polymerge, more menu options are "unlocked":

                   /)
          __   ___//     ___    _  __  _    _
          /_)_(_)(/_ (_/_// (__(/_/ (_(_/__(/_
       .-/          .-/              .-/
      (_/          (_/              (_/

    ________________________________________________________________________
      Active Laboratory:
         Active Polymer:
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯


      Please make a selection (or press Enter to abort):

        1:  Choose a new active laboratory
        2:  Add a new laboratory
        3:  Remove an existing laboratory
        4:  See information about polymerge and its current state
        5:  Change masthead
        6:  Exit

      Please make a selection (or press Enter to abort):

Select the option to choose a new active laboratory. You can then select the lab you just added and it will become active.


### Create a New Polymer Branch

Now that you have chosen an active laboratory, an additional menu option is displayed (note that I have created a dummy notebook repository which specifies another of my projects, [git-hug](https://github.com/Smolations/git-hug) as the laboratory repo):

                   /)
          __   ___//     ___    _  __  _    _
          /_)_(_)(/_ (_/_// (__(/_/ (_(_/__(/_
       .-/          .-/              .-/
      (_/          (_/              (_/

    ________________________________________________________________________
      Active Laboratory:  git-hug  (notebook: polymerge_notebook1)
         Active Polymer:
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯


      Please make a selection (or press Enter to abort):

        1:  Create a new polymer branch in your notebook
        2:  Choose a new active laboratory
        3:  Add a new laboratory
        4:  Remove an existing laboratory
        5:  See information about polymerge and its current state
        6:  Change masthead
        7:  Exit

      Please make a selection (or press Enter to abort):

You can now choose to create a new polymer branch. You will be prompted for a name to give to this wrapper branch. Once submitted and validated, your new polymer branch will be created. You will also be prompted to set the new polymer as the active polymer. If you decline, you will need to make sure an active polymer is set before you can add any monomers to it.


### Add a Monomer to a Polymer

Now that there is at least one polymer defined and an active polymer is set, another group of menu options appears:

                   /)
          __   ___//     ___    _  __  _    _
          /_)_(_)(/_ (_/_// (__(/_/ (_(_/__(/_
       .-/          .-/              .-/
      (_/          (_/              (_/

    ________________________________________________________________________
      Active Laboratory:  git-hug  (notebook: polymerge_notebook1)
         Active Polymer:  my-very-first-polymer
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯


      Please make a selection (or press Enter to abort):

        1:  View monomer branches in `my-very-first-polymer` (0)
        2:  Add a monomer branch to `my-very-first-polymer`
        3:  Create a new polymer branch in your notebook
        4:  Remove an existing polymer branch from your notebook
        5:  Push notebook changes out to team
        6:  Prune notebook (remove integrated polymer branches)
        7:  Choose a new active laboratory
        8:  Add a new laboratory
        9:  Remove an existing laboratory
       10:  See information about polymerge and its current state
       11:  Change masthead
       12:  Exit

      Please make a selection (or press Enter to abort):

As you can see, you now have a quick overview of the number of monomers in your active polymer. Once you have more than one polymer defined, you will get a similar overview for total number of polymers in your active notebook.

Since this document is emulating starting a laboratory from scratch, I should explain a couple of the newly available options.

* **Prune notebook (remove integrated polymer branches)** - This option appears when you have one or more polymers defined. Choosing this options sets polymerge into action, searching for any of your defined polymer branches which have already been merged into `master`. If found, you are prompted to remove them, one at a time.

* **Push notebook changes out to team** - This option appears any time that changes are made in the active notebook. In this case, we just added a new polymer, but it is an empty definition. Therefore, the polymer definition file would show up as "untracked" in the notebook repo managed by polymerge. Usually, you are prompted to re-merge a polymer once you've added/removed/re-ordered its monomers. After all, why prompt the user to submit notebook changes automatically at this point if the polymer is just an empty file?

Choosing the option to add a monomer branch will display a prompt for you to enter any part of the branch name you'd like to add. polymerge uses case-insensitive pattern matching to find candidates on the remote, allowing you to choose from that list. The branch is then added to the polymer definition, and you are given the opportunity to continue adding monomer branches. Once you are finished, you will be prompted to (re-)merge the polymer and push those changes out to the team. polymerge first performs the required branch operations within the laboratory repository, then performs operations in the notebook repository so that your team can share the new definition.

                   /)
          __   ___//     ___    _  __  _    _
          /_)_(_)(/_ (_/_// (__(/_/ (_(_/__(/_
       .-/          .-/              .-/
      (_/          (_/              (_/

    ________________________________________________________________________
      Active Laboratory:  git-hug  (notebook: polymerge_notebook1)
         Active Polymer:  my-very-first-polymer
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Add a monomer branch to `my-very-first-polymer`:

    The laboratory repository has been fetched, so you can choose from
    all available branches on the remote. `polymerge` uses pattern
    matching to find available branches to add, so you don't need to
    enter the full branch name when choosing a branch to add.

    Current monomers:
    -----------------
    branch3
    branch2
    branch1



      Enter ANY part of a branch name to add (or press Enter to abort):

      Re-merge `my-very-first-polymer` and test for merge conflicts [Y/n]?

There is one crucial part of polymerge that needs to be addressed here. In this example, I added the branches in lexigraphical order (`branch1` followed by `branch2` followed by `branch3`). However, they are in reverse order in the polymer definition file. The reason for this is that polymerge adds a monomer to the _top_ of the polymer definition file each time the user adds one. When a new monomer is added to a cleanly merged polymer, it MUST be added to the top in order for polymerge to determine which existing monomers are conflicting with the monomer which was just added during a polymer merge operation. You should *always* re-merge after modifying a polymer in order to weed out merge conflicts as soon as possible.

                   /)
          __   ___//     ___    _  __  _    _
          /_)_(_)(/_ (_/_// (__(/_/ (_(_/__(/_
       .-/          .-/              .-/
      (_/          (_/              (_/

    ________________________________________________________________________
      Active Laboratory:  git-hug  (notebook: polymerge_notebook1)
         Active Polymer:  my-very-first-polymer
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Add a monomer branch to `my-very-first-polymer`:


    Attempting to merge (3) branches:


    [OK]  branch3
    [OK]  branch2
    [OK]  branch1


    Sweet! No merge conflicts!

      Commit and push new polymer branch to git-hug [Y/n]?

    Pushing `my-very-first-polymer` to git-hug...done.

    Successfully pushed `my-very-first-polymer`!

After committing the updated polymer branch to your lab repo, you are then prompted to push the notebook repo changes out to the remote. This makes other team members aware of changes very quickly:

                   /)
          __   ___//     ___    _  __  _    _
          /_)_(_)(/_ (_/_// (__(/_/ (_(_/__(/_
       .-/          .-/              .-/
      (_/          (_/              (_/

    ________________________________________________________________________
      Active Laboratory:  git-hug  (notebook: polymerge_notebook1)
         Active Polymer:  my-very-first-polymer
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    Add a monomer branch to `my-very-first-polymer`:

    Monomer branches in `my-very-first-polymer`:
    ---------------------------------------------
    branch3
    branch2
    branch1
    ---------------------------------------------


    Preparing to push notebook changes out to team:

    $ git status --porcelain -- "polymers/"
    ?? polymers/my-very-first-polymer


      Commit notebook changes listed above [Y/n]?


### All Your Menu Are Belong to Us

The last group of menu options is displayed once you have an active polymer definition which contains one or more monomers:

                   /)
          __   ___//     ___    _  __  _    _
          /_)_(_)(/_ (_/_// (__(/_/ (_(_/__(/_
       .-/          .-/              .-/
      (_/          (_/              (_/

    ________________________________________________________________________
      Active Laboratory:  git-hug  (notebook: polymerge_notebook1)
         Active Polymer:  my-very-first-polymer
    ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯


      Please make a selection (or press Enter to abort):

        1:  View monomer branches in `my-very-first-polymer` (3)
        2:  Add a monomer branch to `my-very-first-polymer`
        3:  Remove a monomer branch from `my-very-first-polymer`
        4:  Re-Order monomer branches in `my-very-first-polymer`
        5:  Re-Merge the monomer branches in `my-very-first-polymer`
        6:  Prune monomer branches in `my-very-first-polymer`
        7:  Create a new polymer branch in your notebook
        8:  Remove an existing polymer branch from your notebook
        9:  Prune notebook (remove integrated polymer branches)
       10:  Choose a new active laboratory
       11:  Add a new laboratory
       12:  Remove an existing laboratory
       13:  See information about polymerge and its current state
       14:  Change masthead
       15:  Exit

      Please make a selection (or press Enter to abort):

A few short explanations for some of the new options:

* **Re-Order monomer branches in \`...\`** - This is useful when attempting to troubleshoot merge conflicts. The most common operation is to move a monomer to the top of the polymer definition, re-merge, and observe which branches create conflicts.
* **Re-Merge the monomer branches in \`...\`** - This is a standalone merging operation for the active polymer. The same thing happens whenever you modify a polymer definition. This is most useful when an update to a monomer branch is pushed by a developer and the changes need to be brought in to the polymer wrapper branch.
* **Prune monomer branches in \`...\`** - Similar to the polymer pruning operation, this option will tell polymerge to determine if any monomers in the active polymer have been merged into `master`. If they have, they are removed, and you are prompted to re-merge the pruned polymer branch.


### Notebook Reset

Any time there are multiple people working within a repository at the same time, there is a risk of Git history diverging. For this reason, polymerge will perform a `$ git reset` on the active notebook repo every time you exit polymerge.


Miscellany
----------
* To turn on debug logging, you will need to set a global variable: `export PM_DEBUG=true`
* Sometimes there are delays when switching to certain menu options or performing various operations. This is due to the fact that polymerge often performs git operations in the background for various purposes.
* The following is an example of what you would see for a merge conflict while merging a polymer branch (in OS X, the pass/fail indicators are pretty little glyphs). Note that `conflicting-branch2` would be the most recent monomer branch added to the polymer, so this output indicates that `conflicting-branch1` may have merged well with `branch1` and `branch2`, but it does not play nicely with the newly added monomer branch:

                       /)
              __   ___//     ___    _  __  _    _
              /_)_(_)(/_ (_/_// (__(/_/ (_(_/__(/_
           .-/          .-/              .-/
          (_/          (_/              (_/

        ________________________________________________________________________
          Active Laboratory:  git-hug  (notebook: polymerge_notebook1)
             Active Polymer:  i-have-conflicts
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

        Add a monomer branch to `i-have-conflicts`:


        Attempting to merge (4) branches:


        [OK]  conflicting-branch2
        [OK]  branch2
        [XX]  conflicting-branch1
        [OK]  branch1


        There was a merge conflict. More information for each conflicted branch:
        ----------------------------------------------------------------------------------------
        89a33fe  conflicting-branch1             Chris Smola       (2014-08-22 14:46:37 -0600)
        ----------------------------------------------------------------------------------------

          WARNING!
            Due to merge conflicts, you will be unable to push your changes.
            You will need to resolve the conflict(s) and try again.


        Press any key to continue...


Conclusion
----------

And that's it! There are some subtle nuances not mentioned in this README, but all of the basics you need to get started are included here.

If you find any bugs or have suggestions, feel free to create an issue here in the GitHub project. Pull requests may also be accepted if the requests include comprehensive descriptions of what they are trying to accomplish.

Happy merging!
