compdef _git-squash-branch git-squash-branch

__command_successful () {
  if (( ${#pipestatus:#0} > 0 )); then
    _message 'not a git repository'
    return 1
  fi
  return 0
}


# Pulled function from https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/git-extras/git-extras.plugin.zsh
__branch_names() {
    local expl
    declare -a branch_names
    branch_names=(${${(f)"$(_call_program branchrefs git for-each-ref --format='"%(refname)"' refs/heads 2>/dev/null)"}#refs/heads/})
    __command_successful || return
    _wanted branch-names expl branch-name compadd $* - $branch_names
}

_git-squash-branch() {
    _arguments \
        ':branch-name:__branch_names'
}

function git-squash-branch() {
    if (( ! $# == 1 )); then
        echo "Usage: $0 (branch built from)"
        exit -1
    fi
    local branch=$1
    
    local commit=$(git rev-parse HEAD)

    local count_commits=$(git rev-list --count HEAD ^${branch})
    echo "Number of commits since '$branch': $count_commits"

    git reset --soft HEAD~$count_commits
    
    if (( ! $(git commit) )); then
        if (( verify "Would you like to reset? (y/n)" )); then
            git reset --soft $commit
        fi
    fi
        
}

function git-remove-merged() {
    echo "What branch would you like to use as base: (Default: master)"
    read  BASE_BRANCH

    BASE_BRANCH=${BASE_BRANCH:-master}
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
    for i in "${!BRANCHES_TO_DELETE[@]}"
    do
        echo "${i}=>${BRANCHES_TO_DELETE[i]}"
    done

    if ! verify "Are you sure you would like to delete these? (y/n)" ; then
        return
    fi

    # Convert array back to " " seperated string
    BRANCHES_TO_DELETE=${BRANCHES_TO_DELETE[@]}

    if verify "Would you like to delete both LOCAL and REMOTE versions, THIS CANNOT BE UNDONE? (y/n)" ; then
        deleteLocal $BRANCHES_TO_DELETE
        deleteRemote $BRANCHES_TO_DELETE
        return
    fi

    if verify "Would you like to delete LOCAL versions? (y/n)" ; then
        deleteLocal $BRANCHES_TO_DELETE
    fi

    if verify "Would you like to delete REMOTE versions? (y/n)" ; then
        deleteRemote $BRANCHES_TO_DELETE
    fi
}

# Function to verify user wants to do something accepting "y" or "n" as a response
function verify()
{
    local PROMPT=${1:-"Are you sure? (y/n)"}
    
    while [[ true ]]; do
        echo $PROMPT
        read RESPONSE

        if [ "$RESPONSE" == "y" ]; then
            return 0
        elif [ "$RESPONSE" == "n" ]; then
            return 1
        else
            echo "Please enter valid response."
        fi
    done
}

function deleteLocal()
{
    local COMMAND="git branch -d $@"
    eval $COMMAND
}

function deleteRemote()
{
    local COMMAND="git push origin -d $@"
    eval $COMMAND
}
