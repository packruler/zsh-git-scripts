local SCRIPTPATH="$(cd "$(dirname "$0")" && pwd -P)"

source $SCRIPTPATH/git-squash-branch.zsh
source $SCRIPTPATH/git-remove-merged.zsh

# Function to verify user wants to do something accepting "y" or "n" as a response
verify()
{
    local PROMPT=${1:-"Are you sure? (y/n)"}
    
    while  true ; do
        echo $PROMPT
        read RESPONSE
        if [ "$RESPONSE" = "y" ]; then
            return 0
        elif [ "$RESPONSE" = "n" ]; then
            return 1
        else
            echo "Please enter valid response."
        fi
    done
}

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
