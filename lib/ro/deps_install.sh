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
  local repo
  local file
  if ! for ((i=0;i<n;i++)); do
    repo="${REPOS[$i]}"
    file="$RODENT/cache/${repo%%:*}/repo.${arch}.xz"
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
  local repo
  local pkg
  while read -r repo; do
    read -r pkg
    repo="${REPOS[$repo]}"
    echo "${repo%%:*}/$pkg"
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
  local repo
  local base
  local sha1
  while read -r repo; do
    read -r base
    read -r sha1
    repo="${REPOS[$repo]}"
    base="${base/=/-}.${arch}.tar.xz"
    check_or_download "$RODENT/cache/${repo%%:*}" "$base" "$sha1" "${repo#*:}/$base"
  done < <(
    awk -F'\t' \
      '{repo[$3]=$1;sha1[$3]=$6} END{for (i in repo) {print repo[i];print i;print sha1[i]}}' \
      '#/installed.tmp'
  )
}

deps_install() {
  local repo
  local base
  local -a pkgs

  while read -r repo; do
    read -r base
    read -a pkgs
    repo="${REPOS[$repo]}"
    base="$RODENT/cache/${repo%%:*}/${base/=/-}.${arch}.tar.xz"
    tar -xf "$base" --no-same-owner --occurrence=1 "${pkgs[@]}"
  done < <(awk -f "$RODENT/lib/ro/install-baseparts.awk" '#/installed.tmp')

  awk 'BEGIN{FS="\t";OFS="\t"} {print $2,$3,$4,$5,$6}' '#/installed.tmp' \
    | sort '#/installed' - \
    > '#/installed.new'
  if ! awk -f "$RODENT/lib/ro/path-conflicts.awk" '#/installed.new'; then
    echo 'Aborting.' >&2
    while read -r base; do
      rm "#/${base/=/-}.files"
    done < <(awk -F'\t' '{print $2}' '#/installed.tmp')
    rm '#/installed.new' '#/installed.tmp'
    return 1
  fi

  while read -r repo; do
    read -r base
    read -a pkgs
    repo="${REPOS[$repo]}"
    base="${repo%%:*}/${base/=/-}.${arch}.tar.xz"
    echo -n "Extracting from ${base}.. "
    tar -xf "$RODENT/cache/$base" --no-same-owner --no-recursion --null -T <(
      awk -F'\t' '$2=="d"||$2=="f"||$2=="l"{printf "./%s%c",$1,0}' "${pkgs[@]}" | sort -zu
    )
    echo
  done < <(awk -f "$RODENT/lib/ro/install-baseparts.awk" '#/installed.tmp')

  mv -f '#/installed.new' '#/installed'
  rm -f '#/installed.tmp'
}

# vim: set ft=sh ts=2 sw=2 et:
