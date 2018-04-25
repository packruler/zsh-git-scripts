#! /bin/zsh

function git-remove-merged() {
    local BASE_BRANCH=${${1}:-master}
    echo $BASE_BRANCH
    return
    EXCLUDE_STRING="master"
    if [ "$BASE_BRANCH" != "master" ]; then
        # Add the base branch to exclude pattern with master
        EXCLUDE_STRING="master\|$BASE_BRANCH"
    fi

    # Build the command to get the names of branches that have been merged into the base, excluding those in the EXCLUDE_STRING
    COMMAND="git branch --merged $BASE_BRANCH | grep -v '^[ *]*$EXCLUDE_STRING$'"

    # Get branches from running COMMAND
    BRANCHES_TO_DELETE=$(eval $COMMAND)
    if [ ! "$BRANCHES_TO_DELETE" ]; then 
        echo "No branches to delete"
        return
    fi

    # Parse branches to array of values and print them for the user
    BRANCHES_TO_DELETE=(${BRANCHES_TO_DELETE// / })
    echo "Branches to be deleted:"
    print -l $BRANCHES_TO_DELETE
    # for i in "${!BRANCHES_TO_DELETE[@]}"
    # do
    #     echo "$i => $BRANCHES_TO_DELETE[i]"
    # done

    # if ! verify "Are you sure you would like to delete these? (y/n)" ; then
    #     return
    # fi

    # # Convert array back to " " seperated string
    # BRANCHES_TO_DELETE=${BRANCHES_TO_DELETE[@]}

    # if verify "Would you like to delete both LOCAL and REMOTE versions, THIS CANNOT BE UNDONE? (y/n)" ; then
    #     deleteLocal $BRANCHES_TO_DELETE
    #     deleteRemote $BRANCHES_TO_DELETE
    #     return
    # fi

    # if verify "Would you like to delete LOCAL versions? (y/n)" ; then
    #     deleteLocal $BRANCHES_TO_DELETE
    # fi

    # if verify "Would you like to delete REMOTE versions? (y/n)" ; then
    #     deleteRemote $BRANCHES_TO_DELETE
    # fi
}
