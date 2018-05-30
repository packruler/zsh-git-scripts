#! /bin/zsh

compdef _git-squash-branch git-squash-branch

_git-squash-branch() {
    _arguments \
        ':Name of Source Branch:__branch_names'
}

zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'

function git-squash-branch() {
    if [[  $# -ne 1 ]]; then
        echo "Usage: $0 (branch built from)"
        exit -1
    fi
    local branch=$1

    local commit=$(git rev-parse HEAD)

    local count_commits=$(git rev-list --count HEAD ^${branch})
    if [[ $count_commits -le 1 ]]; then
        echo "No commits to squash"
        return
    fi
    echo "Number of commits since '$branch': $count_commits"

    commits=($(git rev-list HEAD ^$branch))
    messages=$(git log HEAD ^${commits[-1]} --pretty=%s)

    git reset --soft HEAD~$count_commits

    if verify "Would you like to include commit messages? (y/n)" ; then
        git commit -e -m "Squashed messages:" -m "$messages"
    else
        if git commit ; then
            echo Done
        else

            if verify "Would you like to reset? (y/n)"; then
                git reset --soft $commit
                echo "Reset to commit $commit: $(git log --format=%B -n 1 ${commit})"
            fi
        fi
    fi
}
