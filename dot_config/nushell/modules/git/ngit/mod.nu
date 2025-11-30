# List all files in repo.
export def "ls-files" [] {
    (
        git ls-files -tcdmo |
        parse '{status} {name}'|
        update status {|r|
            match $r.status {
            H => 'unmodified',           # tracked file that is not either unmerged or skip-worktree
            S => 'skip-worktree',        # tracked file that is skip-worktree
            M => 'unmerged',             # tracked file that is unmerged
            R => 'removed',              # tracked file with unstaged removal/deletion
            C => 'modified',             # tracked file with unstaged modification/change
            K => 'untracked conflicting' # untracked paths which are part of file/directory conflicts which prevent checking out tracked files
            ? => 'untracked'             # untracked file
            U => 'resolve-undo'          # file with resolve-undo information
            _ => 'UNKNOWN',
        }} |
        metadata set -l
    )
}

# List git remotes.
export def "remote" [] {
    git remote -v | lines | parse "{name}\t{url} ({type})"
}

# Show working tree status.
export def "status" [] {
    (
        git status --porcelain=v1 |
        parse --regex '(?<status>..) (?<name>.*)' |
        move name --first |
        upsert staged false |
        update staged {|r|
            if $r.status == '??' {
                return false
            }
            let stchars = $r.status | split chars
            let staged = $stchars.0 != ' '
            let unstaged = $stchars.1 != ' '
            if $staged and $unstaged {
                return 'mixed'
            } else if $staged {
                return true
            } else {
                return false
            }
        } |
        update status {|r|
            match $r.status {
            '??' => 'untracked',
            'A ' => 'added'
            ' M' | 'M ' | 'MM' => 'modified',
            'D ' => 'deleted',
            _ => 'UNKNOWN',
        }} |
        metadata set -l
    )
}

export module aliases {
    export alias ngd = ls-files
    export alias ngRl = remote
    export alias ngws = status
}

