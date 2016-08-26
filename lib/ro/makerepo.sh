# This file is part of Rodent Linux
# Copyright 2015-2016 Emil Renner Berthing

makerepo() {
  local arch="$1"
  local -a pkgs=(*.${arch}.tar.*)
  [[ "${pkgs[0]}" != "*.${arch}.tar.*" ]] || return 1

  printf "Processing %3d packages into %-22s" ${#pkgs[@]} "repo.${arch}.tar.gz.. "
  sha1sum "${pkgs[@]}" | while read -r sha1 file; do
    tar -x --to-stdout --occurrence=1 -f "$file" './#/meta' \
      | awk "BEGIN{FS=\"\\t\";OFS=\"\\t\"};{print \$1,\$2,\$3,\$4,\"$sha1\",\$5}"
  done | sort | xz -c > "repo.${arch}.xz"
  echo 'done.'
}

# vim: set ft=sh ts=2 sw=2 et:
