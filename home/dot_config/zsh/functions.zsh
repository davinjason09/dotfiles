# ╾╼ Custom cd implementation ╾────────────────────────────────────────╼

# Check last repository, if it differs from the current, execute onefetch
LAST_REPO=$(git rev-parse --show-toplevel 2>/dev/null) || echo ""
check_repository() {
  git rev-parse 2>/dev/null
  if [ $? -eq 0 ]; then
    CURRENT_REPO=$(git rev-parse --show-toplevel)
    if [ "$CURRENT_REPO" != "$LAST_REPO" ]; then
      onefetch 2>/dev/null
      LAST_REPO=$CURRENT_REPO
    fi
  fi
}

# Use builtin cd for some basic cases such as:
# - go to home without any args
# - if a directory exist
# - `cd .` and `cd ..`
#
# If the args doesnt satisfy all 3, use zoxide and fallback to builtin cd if it fails
cd() {
  # Go to home without arguments
  [ -z "$*" ] && builtin cd && return
  # If directory exists, change to it
  [ -d "$*" ] && builtin cd "$*" && return
  [ "$*" = "-" ] && builtin cd "$*" && return
  # Catch cd . and cd ..
  case "$*" in
    ..) builtin cd ..; return;;
    .) builtin cd .; return;;
  esac
  # Try using zoxide and fallback to builtin cd
  z "$@" || builtin cd "$*"

  # Execute if there is no error code
  if [ $? -eq 0 ]; then
    check_repository
  fi
}

# ╾╼ Connect Discord IPC to WSL when running nvim ╾────────────────────╼
nvim() {
  if ! pidof socat > /dev/null 2>&1; then
    [ -e /tmp/discord-ipc-0 ] && rm -f /tmp/discord-ipc-0
    socat UNIX-LISTEN:/tmp/discord-ipc-0,fork \
      EXEC:"${WIN_HOME}/bin/npiperelay.exe //./pipe/discord-ipc-0" 2>/dev/null &
    echo "Started socat for Discord IPC"
  fi

  if [ $# -eq 0 ]; then
    command nvim
  else
    command nvim "$@"
  fi
}

# ╾╼ Fix corrupt histfile ╾────────────────────────────────────────────╼
fix_hist() {
  mv ~/.histfile ~/histfile_bad
  strings ~/histfile_bad > ~/.histfile
  fc -R ~/.histfile
  rm ~/histfile_bad
}

# ╾╼ Sharing files ╾───────────────────────────────────────────────────╼
0file() {
  curl -F "file=@$1" https://envs.sh
}

0short() {
  curl -F "shorten=$1" https://envs.sh
}

# ╾╼ Competitive Programming ╾─────────────────────────────────────────╼

# compile to its name without extension
cc() {
  clang++ -std=c++20 -Wall -O3 -mtune=native -march=native -DDEBUG -o "${1%.*}" "$1"
}

# compile, execute, then delete
cc_once() {
  echo "Compiling $1..."
  clang++ -std=c++20 -Wall -O3 -mtune=native -march=native -DDEBUG -o "${1%.*}" "$1" && \
  if [ $# -eq 1 ]; then
    ./"${1%.*}"
  else
    ./"${1%.*}" "${@:2}"
  fi && rm -f "${1%.*}"
}

# compile to its name with .out extension
cc_out() {
  clang++ -std=c++20 -Wall -O3 -mtune=native -march=native -DDEBUG -o "${1%.*}.out" "$1"
}

# copy solution template
rs() {
  cp $SOL "$1.cpp"
}

# generate multiple templates
gen() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: gen <number of files> <contest number>"
    return 1
  fi

  for i in $(seq 0 $(( $1 - 1 ))); do
    letter=$(printf "\x$(printf %x $((65 + i % 26)))")
    cp $SOL "$2${letter}.cpp"
  done
}

# ╾╼ Package removal ╾─────────────────────────────────────────────────╼
yeet() {
  installed_pkgs=$(yay -Q)
  if [ $# -eq 0 ]; then
    removed_pkgs=$(echo "$installed_pkgs" | awk '{print $1}' | fzf --height 15 --multi --preview "yay -Qi {}" | paste -sd' ')
    if [ -z "$removed_pkgs" ]; then
      gum log --level info "No packages selected, exiting..."
      return 0
    fi
  else
    removed_pkgs="$*"
  fi

  pkgs_array=(${(@s: :)removed_pkgs})
  filtered_array=()
  for pkg in $pkgs_array; do
    if ! echo "$installed_pkgs" | grep -q "^$pkg "; then
      gum log --level warn "$pkg is not installed, removing from list..."
      continue
    fi
    filtered_array+=("$pkg")
  done

  if [ ${#filtered_array[@]} -eq 0 ]; then
    gum log --level info "No packages to remove, exiting..."
    return 1
  fi

  formatted_pkgs=$(printf '- %s\n' "${filtered_array[@]}")

  output="# Package to remove:\n$formatted_pkgs"
  echo $output | gum format
  echo "\n"

  gum confirm "Do you want to remove these packages?" && yay -Rns $filtered_array || echo "Cancelled"
}

# ╾╼ Avtivate conda environment ╾──────────────────────────────────────╼
activate_conda() {
  source ~/miniconda3/bin/activate
}

# ╾╼ Extract archives based on file extension ╾────────────────────────╼
extract() {
  case $1 in
    *.tar.gz|*.tgz) tar -xzf "$1";;
    *.tar.bz2|*.tbz2) tar -xjf "$1";;
    *.zip) unzip "$1";;
    *.rar) unrar x "$1";;
    *) echo "Unknown archive format";;
  esac
}
