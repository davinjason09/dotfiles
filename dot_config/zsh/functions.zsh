show_file_or_dir_preview="
  if [ -d {} ]; then
    eza --tree --level 1 --icons=always --color=always {} | head -200;
  else
    bat -n --color=always --line-range :500 {};
  fi
"

last_repository=
check_directory_for_new_repository() {
  current_repository=$(git rev-parse --show-toplevel 2> /dev/null)

  if [ "$current_repository" ] && \
     [ "$current_repository" != "$last_repository" ]; then
    onefetch
  fi
  last_repository=$current_repository
}

has() {
  command -v "$1" > /dev/null
}

cd() {
  if has zoxide; then
    __zoxide_z "$@"
  else
    builtin cd "$@"
  fi

  check_directory_for_new_repository
}

fortune() {
  quotetoprint=$(jq -r '.[] | "\(.quoteText) -- \(.quoteAuthor)"' $HOME/.config/fortune/fortune.json | shuf -n 1 | sed 's/ -- /\n\n-- /')

  echo "$quotetoprint"
}

cc() {
  g++ -std=c++20 -Wall -O3 -mtune=native -march=native -DDEBUG -o "$1" "$1.cpp"
}

rs() {
  cp D:/UGM/Programming/Comprog/sol.cpp "$1.cpp"
}

gen() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: gen <number of files> <contest number>"
    return 1
  fi

  for i in $(seq 0 $(( $1 - 1 ))); do
    letter=$(printf "\x$(printf %x $((65 + i % 26)))")
    cp D:/UGM/Programming/Comprog/sol.cpp "$2${letter}.cpp"
  done
}

_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1" --color always
}

_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1" --color always
}

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --level 1 --icons --color=always {} | head -200' "$@" --preview-window 'right:50%:border-left' ;;
    export|unset) fzf --preview "eval 'echo $'{}" "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" --preview-window 'right:50%:border-left' ;;
  esac
}
