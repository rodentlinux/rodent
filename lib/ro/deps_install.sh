# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

. "$ROOT/settings"
. "$ROOT/lib/ro/download.sh"

yesno() {
  if [[ -n "$YES" ]]; then
    return 0
  fi
  local yn
  while true; do
    read -p "$1 [y/n] " yn
    case $yn in
    [Yy]*) echo; return 0;;
    [Nn]*) echo; return 1;;
    *) echo "Please answer yes or no.";;
    esac
  done
}

deps_install() {
  local DEPS="$*"
  if [[ -z "$DEPS" ]]; then
    return 0
  fi

  if [[ ! -d "$SYSROOT" ]]; then
    install -dm755 "$SYSROOT/#"
    touch "$SYSROOT/#/installed"
  fi

  local pkgs=()
  local repo=()
  local base=()
  local url=()
  local sha1=()
  local rest=()
  local n=0
  local i
  local file
  while read -r line; do
    pkgs[$n]="$line"; read -r line
    repo[$n]="$line"; read -r line
    base[$n]="$line"; read -r line
    url[$n]="$line";  read -r line
    sha1[$n]="$line"; read -r line
    rest[$n]="$line"
    n=$n+1
  done < <(
    export DEPS
    for i in "${REPOS[@]}"; do
      file="$ROOT/cache/${i%%:*}/repo.${ARCH}.xz"
      [[ ! -f "$file" ]] || xz -cd "$file" | sed "s|^|${i%%:*}\\t${i#*:}\\t|"
    done | awk \
      -f "$ROOT/lib/ro/graphlib.awk" \
      -f "$ROOT/lib/ro/dependencies.awk" \
      - "$SYSROOT/#/installed"
  )

  if [[ $n = 0 ]]; then
    return 0
  fi

  if [[ "${pkgs[0]}" = 'notfound' ]]; then
    echo "Couldn't find package providing ${repo[0]}."
    return 1
  fi

  if [[ "${pkgs[0]}" = 'choice' ]]; then
    echo "Which of these do you want? ${repo[0]}."
    return 1
  fi

  for ((i=0;i<n;i++)); do
    echo "${repo[$i]}/${pkgs[$i]}"
  done

  if ! yesno 'Install?'; then
    return 1
  fi

  for ((i=0;i<n;i++)); do
    file="${base[$i]}"
    if [[ "${base[$i+1]}" != "$file" ]]; then
      check_or_download "cache/${repo[$i]}" "${file/=/-}.${ARCH}.tar.xz" "${sha1[$i]}" "${url[$i]}/${file/=/-}.${ARCH}.tar.xz"
    fi
  done

  cd "$SYSROOT"
  local list=()
  for ((i=0;i<n;i++)); do
    file="${pkgs[$i]}"
    file="./#/${file/=/-}.files"
    list+=("$file")
    file="${base[$i]}"
    echo -n "${pkgs[$i]}.. "
    if [[ "${base[$i+1]}" != "$file" ]]; then
      file="$ROOT/cache/${repo[$i]}/${file/=/-}.${ARCH}.tar.xz"
      tar -x --no-same-owner -f "$file" --null --no-recursion -T <(
        for j in "${list[@]}"; do
          echo -ne "$j\0"
        done
        tar -x --to-stdout --occurrence=1 -f "$file" "${list[@]}" \
          | awk -F'\t' '$2=="d"||$2=="f"||$2=="l"{print "./" $1}' \
          | sort -u | tr '\n' '\0'
      )
      list=()
      echo 'done.'
    else
      echo
    fi
  done

  {
    for ((i=0;i<n;i++)); do
      file="${rest[$i]}"
      printf '%s\t%s\t%s\n' "${pkgs[$i]}" "${base[$i]}" "${file#x}"
    done
    cat '#/installed'
  } | sort > '#/installed.new'
  mv '#/installed.new' '#/installed'
}

# vim: set ft=sh ts=2 sw=2 et:
