#!/usr/bin/env zsh
# PATH contract test for zshenv + zprofile, in non-login and login shells.
# Uses a fake HOME/ZDOTDIR; Homebrew dirs are the real ones (hardcoded in zshenv).
# Usage: zsh test/zshenv_path.zsh

root=${0:A:h:h}
home=$(mktemp -d) || exit 1
trap 'rm -rf "$home"' EXIT
ln -s $root/zshenv   $home/.zshenv
ln -s $root/zprofile $home/.zprofile

fail=0
fail() { print -u2 "FAIL $1"; (( ++fail )) }

# Usage: path_of <zsh flags> -> prints one PATH entry per line
path_of() {
  env -i HOME=$home ZDOTDIR=$home PATH=/usr/bin:/bin:/usr/sbin:/sbin \
    /bin/zsh $1 'print -l $path'
}

# Usage: index_of <entry> <entries...> -> 1-based index, 0 when absent
index_of() {
  local want=$1; shift
  local -a list=("$@")
  print ${list[(i)$want]}
}

for mode in -c -lc; do
  entries=("${(@f)$(path_of $mode)}")
  label="zsh $mode"
  system=$(index_of /usr/bin $entries)

  for want in $home/go/bin $home/bin; do
    (( $(index_of $want $entries) < system )) || fail "$label: $want must precede /usr/bin"
  done

  prefix=
  [[ -d /opt/homebrew ]] && prefix=/opt/homebrew
  [[ -z $prefix && -d /usr/local/Homebrew ]] && prefix=/usr/local
  if [[ -n $prefix ]]; then
    ruby=$(index_of $prefix/opt/ruby/bin $entries)
    (( ruby > 0 && ruby < system )) || fail "$label: $prefix/opt/ruby/bin must precede /usr/bin"
  fi

  dupes=$(print -l $entries | sort | uniq -d)
  [[ -z $dupes ]] || fail "$label: duplicate entries: $dupes"
done

# Optional rc files absent: no stderr output from sourcing zshenv.
err=$(env -i HOME=$home ZDOTDIR=$home PATH=/usr/bin:/bin /bin/zsh -c : 2>&1 >/dev/null)
[[ -z $err ]] || fail "missing rc files: unexpected stderr: $err"

lc_all=$(env -i HOME=$home ZDOTDIR=$home PATH=/usr/bin:/bin /bin/zsh -c 'print -r -- ${LC_ALL-unset}')
[[ $lc_all == unset ]] || fail "LC_ALL must not be set, got '$lc_all'"

if (( fail )); then
  print -u2 "$fail check(s) failed"
  exit 1
fi
print "all checks passed"
