#!/usr/bin/env bash

set -euo pipefail

if [ -n "$FZF_PREVIEW_LINES" ]; then
  C=$((FZF_PREVIEW_COLUMNS - 2))
  L=$FZF_PREVIEW_LINES
else
  [ -z $COLUMNS ] && COLUMNS="$(tput cols)"
  [ -z $LINES ] && LINES="$(tput lines)"
  C=$COLUMNS
  L=$LINES
fi

has_cmd() {
  for opt in "$@"; do
    if command -v "$opt" >/dev/null; then
      continue
    else
      return $?
    fi
  done
}

if ! has_cmd eza chafa pdftotext exiftool jq bat glow; then
  echo "Required commands are not available." >&2
  exit 1
fi

mime=$(file -Lbs --mime-type "$1")
category=${mime%%/*}
kind=${mime##*/}

if [[ -d "$1" ]]; then
  eza -lAXhT -L 1 --group-directories-first --color=always --icons --git --no-user "$1"
elif [[ $category == image ]]; then
  chafa -f sixel -s ${C}x${L} "$1"
  exiftool "$1" | bat --color=always -plyaml
elif [[ $kind == pdf ]]; then
  pdftotext -q "$1" - | sed "s/\f/$(printf '─%.0s' $(seq 1 $C))\n/g"
elif [[ $kind == rfc822 ]]; then
  bat --color=always -plEmail "$1"
elif [[ $kind == json ]]; then
  jq -r . "$1" | bat --color=always -pljson
elif [[ $category == text ]]; then
  case $1 in
    *.md) CLICOLOR_FORCE=1 COLORTERM=truecolor glow -s dark "$1" ;;
    *) bat --color=always -p "$1" ;;
  esac
else
  echo "Unsupported file type: $mime" >&2
  exit 1
fi

