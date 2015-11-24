# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

BEGIN {
  FS="\t"
  n=0
}

FILENAME=="-" {
  n++
  pkgs[n]=$1
  idx[$1]=n

}

FILENAME!="-" {
  provides_add(installed,$1,$3)

  split($1,a,/=/)
  name=a[1]
  i=idx[name]
  delete idx[name]
  if (i>0)
    found[i]=$1
}

END {
  for (i=1;i<=n;i++) {
    if (found[i]) {
      print found[i]
      continue
    }

    if (dep_resolve(installed,pkgs[i],deps)>0) {
      print list_squash(deps)
      continue
    }

    print pkgs[i]
  }
}

# vim: set ts=2 sw=2 et:
