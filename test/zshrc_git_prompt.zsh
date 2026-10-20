#!/usr/bin/env zsh
# Table-driven test for _git_prompt_format (extracted from zshrc, not sourced).
# Usage: zsh test/zshrc_git_prompt.zsh

zshrc=${0:A:h:h}/zshrc
src=$(sed -n '/^# >>> git-prompt-format$/,/^# <<< git-prompt-format$/p' "$zshrc")
# Require both markers, else sed prints to EOF and eval runs the rest of zshrc.
if [[ "$src" != '# >>> git-prompt-format'*'# <<< git-prompt-format' ]]; then
  print -u2 "git-prompt-format markers not found in $zshrc"
  exit 1
fi
eval "$src"

fail=0
# Usage: check <case name> <expected GIT_PS1> <porcelain text>
check() {
  _git_prompt_format "$3"
  if [[ "$GIT_PS1" != "$2" ]]; then
    print -u2 "FAIL $1: expected '$2', got '$GIT_PS1'"
    (( ++fail ))
  fi
}

check "not a repo"          ""                          ""
check "no upstream"         " [main]"                   "## main"
check "in sync"             " [main =]"                 "## main...origin/main"
check "ahead"               " [main >]"                 "## main...origin/main [ahead 1]"
check "behind"              " [main <]"                 "## main...origin/main [behind 2]"
check "ahead and behind"    " [main <>]"                "## main...origin/main [ahead 1, behind 2]"
check "gone"                " [main !]"                 "## main...origin/main [gone]"
check "branch named behind" " [feature/behind-fix >]"   "## feature/behind-fix...origin/feature/behind-fix [ahead 1]"
check "percent in branch"   " [feat/50%%-off]"          "## feat/50%-off"
check "unborn branch"       " [main]"                   "## No commits yet on main"
check "detached HEAD"       " [HEAD (no branch)]"       "## HEAD (no branch)"
check "branch named ahead"  " [ahead-fix <]"            "## ahead-fix...origin/ahead-fix [behind 1]"
check "branch named gone"   " [gone-fix >]"             "## gone-fix...origin/gone-fix [ahead 1]"
check "upstream named behind" " [main =]"               "## main...origin/behind-x"
check "renamed"             " [main +]"                 $'## main\nR  a -> b'
check "conflict"            " [main +*]"                $'## main\nUU f'
check "dirty"               " [main *]"                 $'## main\n M f'
check "staged"              " [main +]"                 $'## main\nM  f'
check "staged and dirty"    " [main +*]"                $'## main\nMM f'
check "untracked"           " [main ?]"                 $'## main\n?? f'
check "all working tree"    " [main +*?]"               $'## main\nM  a\n M b\n?? c'
check "ahead and dirty"     " [main >*]"                $'## main...origin/main [ahead 1]\n M f'
check "clean in sync"       " [main =]"                 $'## main...origin/main\n'

if (( fail )); then
  print -u2 "$fail case(s) failed"
  exit 1
fi
print "all cases passed"
