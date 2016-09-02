# This file is part of Rodent Linux
# Copyright 2015-2016 Emil Renner Berthing

remove_files() {
  local i

  awk -F'\t' '$2=="f"||$2=="d"||$2=="l"{print $1}' \#/*.files | sort -u > '#/allfiles'
  for i in "$@"; do
    #echo "- rm    $i"
    rm "$i"
  done
  awk -F'\t' '$2=="f"||$2=="d"||$2=="l"{print $1}' \#/*.files \
    | sort -u \
    | comm -23 '#/allfiles' - \
    | sort -r \
    | while read -r i; do
    if [[ -d "$i" ]]; then
      #echo "- rmdir $i"
      rmdir "$i"
    else
      #echo "- rm    $i"
      rm "$i"
    fi
  done
  rm '#/allfiles'
}

hooks_remove_files() {
  local files=(\#/*.hook.files)
  case ${#files[@]} in
  0) return 0;;
  1) [[ -f "${files[0]}" ]] || return 0;;
  esac
  remove_files "${files[@]}"
}

hooks_run() {
  local hook
  local path
  local perm
  local uid
  local gid

  for hook in \#/hooks/*; do
    [[ -f "$hook" ]] || continue
    hook="${hook#\#/hooks/}"

    echo -n "Running hook ${hook}.. "
    while read path perm uid gid; do
      [[ -n "$uid" ]] || uid=0
      [[ -n "$gid" ]] || gid=0
      if [[ -L "$path" ]]; then
        echo -ne "${path}\tl\t777\t${uid}\t${gid}\t" >&7
        readlink "$path" >&7
      elif [[ -f "$path" ]]; then
        [[ -n "$perm" ]] || perm='644'
        echo -ne "${path}\tf\t${perm}\t${uid}\t${gid}\t" >&7
        sha1sum "$path" | head -c40 >&7
        echo >&7
      elif [[ -d "$path" ]]; then
        [[ -n "$perm" ]] || perm='755'
        echo -e "${path}\td\t${perm}\t${uid}\t${gid}" >&7
      elif [[ -e "$path" ]]; then
        echo 'failed.'
        echo "ERROR: Unable to add hook-generated '$path'." >&2
        return 1
      else
        echo 'failed.'
        echo "ERROR: Hook file '$path' not found." >&2
        return 1
      fi
    done < <(. "#/hooks/$hook") 7>"#/${hook}.hook.files"
    echo 'done'
  done
}

# vim: set ft=sh ts=2 sw=2 et:
