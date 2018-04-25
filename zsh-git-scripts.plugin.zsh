local SCRIPTPATH="$(cd "$(dirname "$0")" && pwd -P)"

source $SCRIPTPATH/git-squash-branch.zsh

# Function to verify user wants to do something accepting "y" or "n" as a response
function verify()
{
    local PROMPT=${1:-"Are you sure? (y/n)"}
    
    while  true ; do
        echo $PROMPT
        read RESPONSE

        if [[ "$RESPONSE" -eq "y" ]]; then
            return 0
        elif [[ "$RESPONSE" -eq "n" ]]; then
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
