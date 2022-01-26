Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt -Theme honukai

$_git_log_medium_format='%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B'
$_git_log_oneline_format='%C(green)%h%C(reset) %s%C(red)%d%C(reset)%n'
$_git_log_brief_format='%C(green)%h%C(reset) %s%n%C(blue)(%ar by %an)%C(red)%d%C(reset)%n'

$_git_status_ignore_submodules='none'

# Git
Set-Alias -Name g -Value git

# Branch (b)
function gb { git branch $args }
function gba { git branch --all --verbose $args }
function gbc { git checkout -b $args }
function gbd { git branch --delete $args }
# function gbD { git branch --delete --force $args }
function gbl { git branch --verbose $args }
# function gbL { git branch --all --verbose $args }
function gbm { git branch --move $args }
# function gbM { git branch --move --force $args }
function gbr { git branch --move $args }
# function gbR { git branch --move --force $args }
function gbs { git show-branch $args }
# function gbS { git show-branch --all $args }
function gbv { git branch --verbose $args }
# function gbV { git branch --verbose --verbose $args }
function gbx { git branch --delete $args }
# function gbX { git branch --delete --force $args }

# Commit (c)
function gc { git commit --verbose $args }
# function gcS { git commit --verbose --gpg-sign $args }
function gca { git commit --verbose --all $args }
function gcaS { git commit --verbose --all --gpg-sign $args }
function gcm { git commit --message $args }
function gcmS { git commit --message --gpg-sign $args }
function gcam { git commit --all --message $args }
function gco { git checkout $args }
# function gcO { git checkout --patch $args }
function gcf { git commit --amend --reuse-message HEAD $args }
function gcfS { git commit --amend --reuse-message HEAD --gpg-sign $args }
# function gcF { git commit --verbose --amend $args }
# function gcFS { git commit --verbose --amend --gpg-sign $args }
function gcp { git cherry-pick --ff $args }
# function gcP { git cherry-pick --no-commit $args }
function gcr { git revert $args }
# function gcR { git reset "HEAD^" $args }
function gcs { git show $args }
function gcsS { git show --pretty=short --show-signature $args }
function gcl { git-commit-lost $args }
function gcy { git cherry --verbose --abbrev $args }
# function gcY { git cherry --verbose $args }

# Conflict (C)
# function gCl { git --no-pager diff --name-only --diff-filter=U $args }
# function gCa { git add $(gCl) $args }
# function gCe { git mergetool $(gCl) $args }
# function gCo { git checkout --ours -- $args }
# function gCO { gCo $(gCl) $args }
# function gCt { git checkout --theirs -- $args }
# function gCT { gCt $(gCl) $args }

# Data (d)
function gd { git ls-files $args }
function gdc { git ls-files --cached $args }
function gdx { git ls-files --deleted $args }
function gdm { git ls-files --modified $args }
function gdu { git ls-files --other --exclude-standard $args }
function gdk { git ls-files --killed $args }
function gdi { git status --porcelain --short --ignored | sed -n "s/^!! //p" $args }

# Fetch (f)
function gf { git fetch $args }
function gfa { git fetch --all $args }
function gfc { git clone $args }
function gfcr { git clone --recurse-submodules $args }
function gfm { git pull $args }
function gfma { git pull --autostash $args }
function gfr { git pull --rebase $args }
function gfra { git pull --rebase --autostash $args }

# Flow (F)
# function gFi { git flow init $args }
# function gFf { git flow feature $args }
# function gFb { git flow bugfix $args }
# function gFl { git flow release $args }
# function gFh { git flow hotfix $args }
# function gFs { git flow support $args }

# function gFfl { git flow feature list $args }
# function gFfs { git flow feature start $args }
# function gFff { git flow feature finish $args }
# function gFfp { git flow feature publish $args }
# function gFft { git flow feature track $args }
# function gFfd { git flow feature diff $args }
# function gFfr { git flow feature rebase $args }
# function gFfc { git flow feature checkout $args }
# function gFfm { git flow feature pull $args }
# function gFfx { git flow feature delete $args }

# function gFbl { git flow bugfix list $args }
# function gFbs { git flow bugfix start $args }
# function gFbf { git flow bugfix finish }
# function gFbp { git flow bugfix publish }
# function gFbt { git flow bugfix track }
# function gFbd { git flow bugfix diff }
# function gFbr { git flow bugfix rebase }
# function gFbc { git flow bugfix checkout }
# function gFbm { git flow bugfix pull }
# function gFbx { git flow bugfix delete }

# function gFll { git flow release list }
# function gFls { git flow release start }
# function gFlf { git flow release finish }
# function gFlp { git flow release publish }
# function gFlt { git flow release track }
# function gFld { git flow release diff }
# function gFlr { git flow release rebase }
# function gFlc { git flow release checkout }
# function gFlm { git flow release pull }
# function gFlx { git flow release delete }

# function gFhl { git flow hotfix list }
# function gFhs { git flow hotfix start }
# function gFhf { git flow hotfix finish }
# function gFhp { git flow hotfix publish }
# function gFht { git flow hotfix track }
# function gFhd { git flow hotfix diff }
# function gFhr { git flow hotfix rebase }
# function gFhc { git flow hotfix checkout }
# function gFhm { git flow hotfix pull }
# function gFhx { git flow hotfix delete }

# function gFsl { git flow support list }
# function gFss { git flow support start }
# function gFsf { git flow support finish }
# function gFsp { git flow support publish }
# function gFst { git flow support track }
# function gFsd { git flow support diff }
# function gFsr { git flow support rebase }
# function gFsc { git flow support checkout }
# function gFsm { git flow support pull }
# function gFsx { git flow support delete }

# Grep (g)
function gg { git grep }
function ggi { git grep --ignore-case }
function ggl { git grep --files-with-matches }
# function ggL { git grep --files-without-matches }
function ggv { git grep --invert-match }
function ggw { git grep --word-regexp }

# Index (i)
function gia { git add }
# function giA { git add --patch }
function giu { git add --update }
function gid { git diff --no-ext-diff --cached }
# function giD { git diff --no-ext-diff --cached --word-diff }
function gii { git update-index --assume-unchanged }
# function giI { git update-index --no-assume-unchanged }
function gir { git reset }
# function giR { git reset --patch }
function gix { git rm -r --cached }
# function giX { git rm -r --force --cached }

# Log (l)
function gl { git log --topo-order --pretty=format:"$_git_log_medium_format" }
function gls { git log --topo-order --stat --pretty=format:"$_git_log_medium_format" }
function gld { git log --topo-order --stat --patch --full-diff --pretty=format:"$_git_log_medium_format" }
function glo { git log --topo-order --pretty=format:"$_git_log_oneline_format" }
function glg { git log --topo-order --graph --pretty=format:"$_git_log_oneline_format" }
function glb { git log --topo-order --pretty=format:"$_git_log_brief_format" }
function glc { git shortlog --summary --numbered }
# function glS { git log --show-signature }

# Merge (m)
function gm { git merge }
function gmC { git merge --no-commit }
function gmF { git merge --no-ff }
function gma { git merge --abort }
function gmt { git mergetool }

# Push (p)
function gp { git push }
function gpf { git push --force-with-lease }
# function gpF { git push --force }
function gpa { git push --all }
# function gpA { git push --all && git push --tags }
function gpt { git push --tags }
function gpc { git push --set-upstream origin "$(git-branch-current 2> /dev/null)" }
function gpp { git pull origin "$(git-branch-current 2> /dev/null)" && git push origin "$(git-branch-current 2> /dev/null)" }

# Rebase (r)
function gr { git rebase }
function gra { git rebase --abort }
function grc { git rebase --continue }
function gri { git rebase --interactive }
function grs { git rebase --skip }

# Remote (R)
# function gR { git remote }
# function gRl { git remote --verbose }
# function gRa { git remote add }
# function gRx { git remote rm }
# function gRm { git remote rename }
# function gRu { git remote update }
# function gRp { git remote prune }
# function gRs { git remote show }
# function gRb { git-hub-browse }

# Stash (s)
function gs { git stash }
function gsa { git stash apply }
function gsx { git stash drop }
# function gsX { git-stash-clear-interactive }
function gsl { git stash list }
# function gsL { git-stash-dropped }
function gsd { git stash show --patch --stat }
function gsp { git stash pop }
function gsr { git-stash-recover }
function gss { git stash save --include-untracked }
# function gsS { git stash save --patch --no-keep-index }
function gsw { git stash save --include-untracked --keep-index }

# Submodule (S)
# function gS { git submodule }
# function gSa { git submodule add }
# function gSf { git submodule foreach }
# function gSi { git submodule init }
# function gSI { git submodule update --init --recursive }
# function gSl { git submodule status }
# function gSm { git-submodule-move }
# function gSs { git submodule sync }
# function gSu { git submodule update --remote --recursive }
# function gSx { git-submodule-remove }

# Tag (t)
function gt { git tag }
function gtl { git tag --list }
function gts { git tag --sign }
function gtv { git verify-tag }

# Working Copy (w)
# function gws { git status --ignore-submodules=$_git_status_ignore_submodules --short }
function gws { git status --ignore-submodules=$_git_status_ignore_submodules }
# function gwS { git status --ignore-submodules=$_git_status_ignore_submodules }
function gwd { git diff --no-ext-diff }
# function gwD { git diff --no-ext-diff --word-diff }
function gwr { git reset --soft }
# function gwR { git reset --hard }
function gwc { git clean --dry-run }
# function gwC { git clean --force }
function gwx { git rm -r }
# function gwX { git rm -r --force }
