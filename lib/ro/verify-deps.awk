# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

BEGIN {
  FS="\t"
}

{
  name[NR]=$1
  depends[NR]=$4

  provides_add(installed,$1,$3)
}

END {
  #for (p in provides) {
  #  n=split(provides[p],array," ")
  #  if (n>1)
  #    print p, provides[p]
  #}

  for (i=1;i<=NR;i++) {
    n=split(depends[i],darr," ")
    for (j=1;j<=n;j++) {
      m=dep_resolve(installed,darr[j],deps)
      if (m==0)
        print name[i] " depends on " darr[j] " which is not satisfied"
      #else if (m==1)
      #  print name[i] ": " darr[j] " -> " deps[1]
      #else
      #  print name[i] ": " darr[j] " -> " list_squash(deps,m) " HEY!"
    }
  }
}

# vim: set ts=2 sw=2 et :
