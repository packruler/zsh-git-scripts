#! /bin/zsh

compdef _git-remove-merged git-remove-merged

_git-remove-merged() {
    _arguments \
        '*:Branch to ignore:__branch_names'
}

zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'

function git-remove-merged() {
    # Define functions that will only be used here locally
    local function deleteLocal()
    {
        local COMMAND="git branch -d $@"
        eval $COMMAND
    }

    local function deleteRemote()
    {
        local COMMAND="git push origin -d $@"
        eval $COMMAND
    }
    
    # Do actual work
    local CURRENT_BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
    
    local EXCLUDE_STRING="master"
    if [[ "$CURRENT_BRANCH" -ne "master" ]]; then
        # Add the base branch to exclude pattern with master
        EXCLUDE_STRING="master\|$CURRENT_BRANCH"
    fi
    
    
    for i in $@
    do
        EXCLUDE_STRING="$EXCLUDE_STRING\|$i"
    done

    # Build the command to get the names of branches that have been merged into the base, excluding those in the EXCLUDE_STRING
    local COMMAND="git branch --merged $CURRENT_BRANCH | grep -v '^[ *]*$EXCLUDE_STRING$'"

    # Get branches from running COMMAND
    local BRANCHES_TO_DELETE=($(eval $COMMAND))
    if [ ! "$BRANCHES_TO_DELETE" ]; then 
        echo "No branches to delete"
        return
    fi

    # Parse branches to array of values and print them for the user
    echo "Branches to be deleted:"
    print -l ${BRANCHES_TO_DELETE[*]}
    
    verify "Are you sure you would like to delete these? (y/n)"
    if [[ $? -eq 1 ]]; then
        return
    fi

    # Convert array back to " " seperated string
    BRANCHES_TO_DELETE=${BRANCHES_TO_DELETE[*]}
    verify "Would you like to delete both LOCAL and REMOTE versions, THIS CANNOT BE UNDONE? (y/n)"
    if [[ $? -eq 0 ]] ; then
        deleteLocal $BRANCHES_TO_DELETE
        deleteRemote $BRANCHES_TO_DELETE
        return
    fi

    verify "Would you like to delete LOCAL versions? (y/n)"
    if [[ $? -eq 0 ]] ; then
        deleteLocal $BRANCHES_TO_DELETE
    fi

    verify "Would you like to delete REMOTE versions? (y/n)"
    if [[ $? -eq 0 ]] ; then
        deleteRemote $BRANCHES_TO_DELETE
    fi
}
