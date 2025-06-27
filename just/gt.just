sync:
    git fetch origin master
    git rebase origin/master

set positional-arguments

create branch comment:
    git checkout -b {{ branch }}
    git add .
    git commit -m "{{ comment }}"

submit merge="--auto":
    git commit --amend --no-edit
    git push --force
    (gh pr create --fill-verbose && gh pr view --web) || (gh pr view)
    gh pr merge --squash --delete-branch {{ if merge == "--auto" { "--auto" } else { "" } }}
