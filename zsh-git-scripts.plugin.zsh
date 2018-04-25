compdef _git-squash-branch git-squash-branch

__command_successful () {
  if (( ${#pipestatus:#0} > 0 )); then
    _message 'not a git repository'
    return 1
  fi
  return 0
}

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

    local count_commits=$(git rev-list --count HEAD ^${branch})
    echo "Number of commits since '$branch': $count_commits"

    git reset --soft HEAD~$count_commits
    git commit
}
