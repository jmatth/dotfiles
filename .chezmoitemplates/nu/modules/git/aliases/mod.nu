#
# Git Aliases
#

## Status
# zstyle -s ':prezto:module:git:status:ignore' submodules '_git_status_ignore_submodules' \
#     || _git_status_ignore_submodules='none'
const _git_status_ignore_submodules = 'none'

# Git
export alias g = git

# Branch (b)
export alias gb  = git branch
export alias gba = git branch --all --verbose
export alias gbc = git checkout -b
export alias gbd = git branch --delete
export alias gbD = git branch --delete --force
export alias gbl = git branch --verbose
export alias gbL = git branch --all --verbose
export alias gbm = git branch --move
export alias gbM = git branch --move --force
export alias gbr = git branch --move
export alias gbR = git branch --move --force
export alias gbs = git show-branch
export alias gbS = git show-branch --all
export alias gbv = git branch --verbose
export alias gbV = git branch --verbose --verbose
export alias gbx = git branch --delete
export alias gbX = git branch --delete --force

# Commit (c)
export alias gc = git commit --verbose
export alias gcS = git commit --verbose --gpg-sign
export alias gca = git commit --verbose --all
export alias gcaS = git commit --verbose --all --gpg-sign
export alias gcm = git commit --message
export alias gcmS = git commit --message --gpg-sign
export alias gcam = git commit --all --message
export alias gco = git checkout
export alias gcO = git checkout --patch
export alias gcf = git commit --amend --reuse-message HEAD
export alias gcfS = git commit --amend --reuse-message HEAD --gpg-sign
export alias gcF = git commit --verbose --amend
export alias gcFS = git commit --verbose --amend --gpg-sign
export alias gcp = git cherry-pick --ff
export alias gcP = git cherry-pick --no-commit
export alias gcr = git revert
export alias gcR = git reset "HEAD^"
export alias gcs = git show
export alias gcsS = git show --pretty=short --show-signature
export alias gcl = git-commit-lost
export alias gcy = git cherry --verbose --abbrev
export alias gcY = git cherry --verbose

# Conflict (C)
export alias gCl = git --no-pager diff --name-only --diff-filter=U
# alias gCa = git add $(gCl)
# alias gCe = git mergetool $(gCl)
export alias gCo = git checkout --ours --
# alias gCO = gCo $(gCl)
export alias gCt = git checkout --theirs --
# alias gCT = gCt $(gCl)

# Data (d)

export alias gd  = git ls-files
export alias gdc = git ls-files --cached
export alias gdx = git ls-files --deleted
export alias gdm = git ls-files --modified
export alias gdu = git ls-files --other --exclude-standard
export alias gdk = git ls-files --killed
export alias gdi = git status --porcelain --short --ignored | sed -n "s/^!! //p"

# Fetch (f)
export alias gf   = git fetch
export alias gfa  = git fetch --all
export alias gfc  = git clone
export alias gfcr = git clone --recurse-submodules
export alias gfm  = git pull
export alias gfma = git pull --autostash
export alias gfr  = git pull --rebase
export alias gfra = git pull --rebase --autostash

# Grep (g)
export alias gg  = git grep
export alias ggi = git grep --ignore-case
export alias ggl = git grep --files-with-matches
export alias ggL = git grep --files-without-matches
export alias ggv = git grep --invert-match
export alias ggw = git grep --word-regexp

# Index (i)
export alias gia = git add
export alias giA = git add --patch
export alias giu = git add --update
export alias gid = git diff --no-ext-diff --cached
export alias giD = git diff --no-ext-diff --cached --word-diff
export alias gii = git update-index --assume-unchanged
export alias giI = git update-index --no-assume-unchanged
export alias gir = git reset
export alias giR = git reset --patch
export alias gix = git rm -r --cached
export alias giX = git rm -r --force --cached

# Log (l)
export alias gl  = git log --topo-order --pretty=med
export alias gls = git log --topo-order --stat --pretty=med
export alias gld = git log --topo-order --stat --patch --full-diff --pretty=med
export alias glo = git log --topo-order --pretty=ol
export alias glg = git log --topo-order --graph --pretty=ol
export alias glb = git log --topo-order --pretty=br
export alias glc = git shortlog --summary --numbered
export alias glS = git log --show-signature

# Merge (m)
export alias gm  = git merge
export alias gmC = git merge --no-commit
export alias gmF = git merge --no-ff
export alias gma = git merge --abort
export alias gmt = git mergetool

# Push (p)
export alias gp  = git push
export alias gpf = git push --force-with-lease
export alias gpF = git push --force
export alias gpa = git push --all
export alias gpA = git push --all and git push --tags
export alias gpt = git push --tags
# alias gpc = git push --set-upstream origin "$(git-branch-current 2> /dev/null)"
# alias gpp = git pull origin "$(git-branch-current 2> /dev/null)" and git push origin "$(git-branch-current 2> /dev/null)"

# Rebase (r)
export alias gr  = git rebase
export alias gra = git rebase --abort
export alias grc = git rebase --continue
export alias gri = git rebase --interactive
export alias grs = git rebase --skip

# Remote (R)
export alias gR  = git remote
export alias gRl = git remote --verbose
# List git remotes.
export alias gRa = git remote add
export alias gRx = git remote rm
export alias gRm = git remote rename
export alias gRu = git remote update
export alias gRp = git remote prune
export alias gRs = git remote show
export alias gRb = git-hub-browse

# Stash (s)
export alias gs  = git stash
export alias gsa = git stash apply
export alias gsx = git stash drop
export alias gsX = git-stash-clear-interactive
export alias gsl = git stash list
export alias gsL = git-stash-dropped
export alias gsd = git stash show --patch --stat
export alias gsp = git stash pop
export alias gsr = git-stash-recover
export alias gss = git stash save --include-untracked
export alias gsS = git stash save --patch --no-keep-index
export alias gsw = git stash save --include-untracked --keep-index

# Submodule (S)
export alias gS  = git submodule
export alias gSa = git submodule add
export alias gSf = git submodule foreach
export alias gSi = git submodule init
export alias gSI = git submodule update --init --recursive
export alias gSl = git submodule status
export alias gSm = git-submodule-move
export alias gSs = git submodule sync
export alias gSu = git submodule update --remote --recursive
export alias gSx = git-submodule-remove

# Tag (t)
export alias gt  = git tag
export alias gtl = git tag --list
export alias gts = git tag --sign
export alias gtv = git verify-tag

# Working Copy (w)

export alias gwS = git status --ignore-submodules=$"($_git_status_ignore_submodules)" --short
export alias gws = git status --ignore-submodules=$"($_git_status_ignore_submodules)"
export alias gwd = git diff --no-ext-diff
export alias gwD = git diff --no-ext-diff --word-diff
export alias gwr = git reset --soft
export alias gwR = git reset --hard
export alias gwc = git clean --dry-run
export alias gwC = git clean --force
export alias gwx = git rm -r
export alias gwX = git rm -r --force

# cd to the root of the current git directory.
def --env gwt [] {
    let path_to_root = git rev-parse --show-cdup | str trim
    if (path_to_root | is-empty) { return }
    cd $path_to_root
}

