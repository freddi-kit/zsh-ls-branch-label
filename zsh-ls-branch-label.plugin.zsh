# zsh-ls-branch-label
#
# Show the current git branch next to repository directories in plain `ls` output.
#   e.g.  app (main)    docs    tools (feature/foo)
#
# - Only plain `ls` / `ls <dir>` on a terminal is decorated. With any option
#   (ls -a, ls -l, ...), or when piped / redirected, the real ls runs unchanged.
# - The `-G` added by oh-my-zsh's `alias ls='ls -G'` is not treated as an option.
# - Reads .git/HEAD directly instead of running git (supports the .git file
#   used by worktrees and submodules).
# - On a detached HEAD, the first 7 characters of the commit hash are shown.
#
# Configuration:
#   LS_BRANCH_LABEL_COLOR  SGR color code for the label (default: 35 = magenta,
#                          empty = no color)
#
# https://github.com/freddi-kit/zsh-ls-branch-label
# MIT License

: ${LS_BRANCH_LABEL_COLOR=35}

# If $1 is the root of a git repository, set REPLY to its branch (or short hash)
_ls_branch_label_read() {
  local dir=$1 gitdir head
  if [[ -d $dir/.git ]]; then
    gitdir=$dir/.git
  elif [[ -f $dir/.git ]]; then
    read -r head < $dir/.git
    [[ $head == 'gitdir: '* ]] || return 1
    gitdir=${head#gitdir: }
    [[ $gitdir == /* ]] || gitdir=$dir/$gitdir
  else
    return 1
  fi
  [[ -r $gitdir/HEAD ]] || return 1
  head=
  read -r head < $gitdir/HEAD
  [[ -n $head ]] || return 1
  if [[ $head == 'ref: refs/heads/'* ]]; then
    REPLY=${head#ref: refs/heads/}
  else
    REPLY=${head[1,7]}
  fi
}

# The `function ls` form keeps an existing `alias ls=...` from being expanded
# in the definition itself
function ls {
  emulate -L zsh
  setopt extendedglob

  local -a gopt=(${(M)@:#-G}) args=(${@:#-G})

  # Not a terminal / has options / multiple arguments -> plain ls
  if [[ ! -t 1 ]] || (( $#args > 1 )) || [[ $args[1] == -* ]]; then
    command ls "$@"
    return
  fi

  local dir=${args[1]:-.}
  if [[ ! -d $dir ]]; then
    command ls "$@"
    return
  fi

  local -A branch
  local d
  for d in $dir/*(N/); do
    _ls_branch_label_read $d && branch[${d:t}]=$REPLY
  done
  if (( ! $#branch )); then
    command ls "$@"
    return
  fi

  # Get one entry per line to keep ls's own order and colors, then lay out columns ourselves
  local out st
  out=$(CLICOLOR_FORCE=1 command ls $gopt -1 -- $args)
  st=$?
  [[ -n $out ]] || return st

  local line plain w
  local -a items widths
  for line in "${(@f)out}"; do
    plain=${line//$'\e'\[[0-9;]#m/}
    if (( ${+branch[$plain]} )); then
      if [[ -n $LS_BRANCH_LABEL_COLOR ]]; then
        line+=" "$'\e'"[${LS_BRANCH_LABEL_COLOR}m(${branch[$plain]})"$'\e'"[0m"
      else
        line+=" (${branch[$plain]})"
      fi
      plain+=" (${branch[$plain]})"
    fi
    w=${(m)#plain}
    items+=("$line")
    widths+=($w)
  done

  # Per-column widths (like GNU ls): use the most columns that fit the terminal, filled top to bottom
  local n=$#items termw=${COLUMNS:-80} gap=2 rows cols total r c i row pad=
  local -a colw
  for (( cols = n < termw / 3 ? n : termw / 3; cols >= 1; cols-- )); do
    rows=$(( (n + cols - 1) / cols ))
    colw=()
    total=$(( gap * (cols - 1) ))
    for (( c = 0; c < cols; c++ )); do
      w=0
      for (( i = c * rows + 1; i <= n && i <= (c + 1) * rows; i++ )); do
        (( widths[i] > w )) && w=$widths[i]
      done
      colw+=($w)
      (( total += w ))
    done
    (( total <= termw || cols == 1 )) && break
  done
  for (( r = 1; r <= rows; r++ )); do
    row=
    for (( c = 0; c < cols; c++ )); do
      i=$(( c * rows + r ))
      (( i > n )) && break
      row+=$items[i]
      (( i + rows <= n )) && row+=${(l:colw[c + 1] - widths[i] + gap:: :)pad}
    done
    print -r -- "$row"
  done
  return st
}
