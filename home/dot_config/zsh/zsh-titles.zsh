autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats ' %r'
zstyle ':vcs_info:git:*' check-for-changes true

# https://stackoverflow.com/questions/73336178/shortened-path-relative-to-git-repository-in-terminal-prompt-with-zsh
function get_cwd_style() {
  vcs_info
  local title
  if [[ -n $(git rev-parse --git-dir 2> /dev/null) ]]; then
    if [ -d .git ]; then
      title="${vcs_info_msg_0_}"
    elif [ -d ../.git ]; then
      title="${vcs_info_msg_0_}/%c"
    elif [ -d ../../.git ]; then
      title="${vcs_info_msg_0_}/%2c"
    else
      title="${vcs_info_msg_0_}/…/%2c"
    fi
  else
    title="%(4~|%-1~/…/%2~|%3~)"
  fi
  echo "$title"
}

function update_title() {
  local a
  # escape '%' in $2, make nonprintables visible
  a=${(V)2//\%/\%\%}
  print -nz "%20>…>$a"
  read -rz a
  # remove newlines
  a=${a//$'\n'/}
  if [[ -n "$TMUX" ]] && [[ $TERM == screen* || $TERM == tmux* ]]; then
    print -n "\ek${(%)1}${(%)a}\e\\"
  elif [[ "$TERM" =~ "screen*" ]]; then
    print -n "\ek${(%)1}${(%)a}\e\\"
  elif [[ "$TERM" =~ "xterm*" || "$TERM" =~ "alacritty|wezterm" || "$TERM" =~ "st*" ]]; then
    print -n "\e]0;${(%)1}${(%)a}\a"
  elif [[ "$TERM" =~ "^rxvt-unicode.*" ]]; then
    printf '\33]2;%s%s\007' ${(%)1} " - ${(%)a}"
  fi
}

# called just before the prompt is printed
function _zsh_title__precmd() {
  tput cnorm
  update_title "$(get_cwd_style)" ""
}

# called just before a command is executed
function _zsh_title__preexec() {
  local -a cmd

  # Escape '\'
  1=${1//\\/\\\\\\\\}

  cmd=(${(z)1})             # Re-parse the command line

  # Construct a command that will output the desired job number.
  case $cmd[1] in
    fg)	cmd="${(z)jobtexts[${(Q)cmd[2]:-%+}]}" ;;
    %*)	cmd="${(z)jobtexts[${(Q)cmd[1]:-%+}]}" ;;
  esac

  if [[ "${cmd[1]}" == "exec" ]]; then
    return 0
  fi

  update_title "$(get_cwd_style)" " - $cmd"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsh_title__precmd
add-zsh-hook preexec _zsh_title__preexec
