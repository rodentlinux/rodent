# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

BEGIN {
  FS="\t"
  n=0
}

FILENAME=="-" {
  pkgs[$1]=1
}

FILENAME!="-" {
  n++
  name[n]=$1
  depends[n]=$4

  provides_add(installed,$1,$3)
}

END {
  status=0

  for (i=1;i<=n;i++) {
    pkg=name[i]
    if (pkgs[pkg])
      continue
    delete pkgs[pkg]

    m=split(depends[i],darr," ")
    for (j=1;j<=m;j++) {
      if (dep_resolve(installed,darr[j],deps)==1) {
        dpkg=deps[1]
        if (pkgs[dpkg]) {
          print pkg " depends on " darr[j] " only satisfied by " dpkg
          status=1
        } else
          delete pkgs[dpkg]
      }
    }
  }

  exit status
}

# vim: set ts=2 sw=2 et :
