# This file is part of Rodent Linux
# Copyright 2015-2016 Emil Renner Berthing

sysroot_init() {
  if [[ ! -d "$SYSROOT" ]]; then
    install -dm755 "$SYSROOT/#"
    touch "$SYSROOT/#/installed"
  fi
  SYSROOT="$(readlink -f "$SYSROOT")"
  cd "$SYSROOT"
}

deps_calculate() {
  local n=${#REPOS[@]}
  local i
  local rep
  local file
  if ! for ((i=0;i<n;i++)); do
    rep="${REPOS[$i]}"
    rep="${rep%%:*}"
    file="$RODENT/cache/$rep/repo.${arch}.xz"
    [[ ! -f "$file" ]] || xz -cd "$file" | awk "{print \"$i\\t\" \$0}"
  done | DEPS="$*" awk \
    -f "$RODENT/lib/ro/graphlib.awk" \
    -f "$RODENT/lib/ro/dependencies.awk" \
    - '#/installed' \
    > '#/installed.tmp'; then
    cat '#/installed.tmp'
    rm '#/installed.tmp'
    return 1
  fi
}

deps_ask() {
  local rep
  local pkg
  while read -r rep; do
    read -r pkg
    rep="${REPOS[$rep]}"
    rep="${rep%%:*}"
    echo "$rep/$pkg"
  done < <(awk -F'\t' '{print $1;print $2}' '#/installed.tmp')
  local yn
  while true; do
    read -p 'Install? [y/n] ' yn
    case $yn in
    [Yy]*)
      echo
      return 0
      ;;
    [Nn]*)
      echo
      rm -f '#/installed.tmp'
      return 1
      ;;
    *)
      echo 'Please answer yes or no.'
      ;;
    esac
  done
}

deps_download() {
  local rep
  local file
  local sha1
  while read -r rep; do
    read -r file
    read -r sha1
    rep="${REPOS[$rep]}"
    file="${file/=/-}.${arch}.tar.xz"
    check_or_download "$RODENT/cache/${rep%%:*}" "$file" "$sha1" "${rep#*:}/$file"
  done < <(
    awk -F'\t' \
      '{repo[$3]=$1;sha1[$3]=$6} END{for (i in repo) {print repo[i];print i;print sha1[i]}}' \
      '#/installed.tmp'
  )
}

deps_install_from_tarball() {
  local tarball="$1"
  shift
  local n=$#
  local i
  for ((i=1;i<n;i++)); do
    echo "${!i}.."
  done
  echo -n "${!n}.. "
  tar -x --no-same-owner -f "$tarball" --null --no-recursion -T <(
    list=()
    for i in "$@"; do
      files="./#/${i/=/-}.files"
      echo -ne "$files\0"
      list+=("$files")
    done
    tar -x --to-stdout --occurrence=1 -f "$tarball" "${list[@]}" \
      | awk -F'\t' '$2=="d"||$2=="f"||$2=="l"{print "./" $1}' \
      | sort -u | tr '\n' '\0'
  )
  echo 'done.'
}

deps_install() {
  local rep
  local file
  local list

  while read -r rep; do
    read -r file
    read -r list
    rep="${REPOS[$rep]}"
    rep="${rep%%:*}"
    file="$RODENT/cache/$rep/${file/=/-}.${arch}.tar.xz"
    deps_install_from_tarball "$file" $list
  done < <(awk -F'\t' \
    '{repo[$3]=$1;pkgs[$3]=pkgs[$3] " " $2} END {for (i in pkgs) {print repo[i];print i;print pkgs[i]}}' \
    '#/installed.tmp'
  )

  awk 'BEGIN{FS="\t";OFS="\t"} {print $2,$3,$4,$5,$6}' '#/installed.tmp' | sort '#/installed' - > '#/installed.new'
  mv -f '#/installed.new' '#/installed'
  rm -f '#/installed.tmp'
}

# vim: set ft=sh ts=2 sw=2 et:
