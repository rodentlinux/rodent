# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

if command -v curl >/dev/null 2>&1; then
  eval 'download() { echo "Downloading $1"; curl -#Lo "$2" "$1"; }'
elif command -v wget >/dev/null 2>&1; then
  eval "download() { wget -O "\$2" "\$1"; }"
else
  echo 'No download command found.'
  echo 'Please install curl or wget.'
  exit 1
fi

check_or_download() {
  local prefix="$1"
  local file="$2"
  local sha1="$3"
  local url="$4"
  local path="$ROOT/$prefix/$file"

  if [[ -f "$path" ]]; then
    if [[ "$sha1" != SKIP && "$sha1" != "$(sha1sum "$path" | head -c40)" ]]; then
      echo "$file already exists in $prefix, but it's SHA1 doesn't match!"
      return 1
    fi
    #echo "$file already exists in $prefix"
    return 0
  fi
  download "$url" "$path"
  if [[ "$sha1" != SKIP && "$sha1" != "$(sha1sum "$path" | head -c40)" ]]; then
    echo "The SHA1 of downloaded file $prefix/$file doesn't match!"
    return 1
  fi
  return 0
}

# vim: set ts=2 sw=2 et:
