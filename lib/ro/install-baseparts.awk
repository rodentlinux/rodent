# This file is part of Rodent Linux
# Copyright 2016 Emil Renner Berthing

BEGIN {
  FS="\t"
}

{
  repo[$3]=$1
  split($2,a,"=")
  pkgs[$3]=pkgs[$3] " ./#/" a[1] "-" a[2] ".files"
}

END {
  for (base in repo) {
    print repo[base]
    print base
    print pkgs[base]
  }
}

# vim: set ts=2 sw=2 et:
