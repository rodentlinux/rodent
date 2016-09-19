# This file is part of Rodent Linux
# Copyright 2016 Emil Renner Berthing

BEGIN {
  FS="\t"
}

{
  pkg=$1
  split(pkg,a,"=")
  filename="#/" a[1] "-" a[2] ".files"
  while ((getline < filename) > 0) {
    attr=$2 ":" $3 ":" $4 ":" $5
    attrpath=attr ":" $1
    entry=pkgs[attrpath]
    if (entry) {
      pkgs[attrpath]=entry " " pkg
      if ($2!="d")
        clash[$1]=1
    } else
      pkgs[attrpath]=pkg

    entry=attrs[$1]
    if (!entry) {
      attrs[$1]=attr
      continue
    }
    if (entry==attr)
      continue
    n=split(entry,a," ")
    for (i=1;i<=n;i++) {
      if (a[i]==attr)
        break
    }
    if (i>n) {
      attrs[$1]=entry " " attr
      clash[$1]=1
    }
  }
  close(filename)
}

END {
  ret=0
  for (p in clash) {
    ret=1
    print "Conflicting definitions for '" p "'"
    n=split(attrs[p],a," ")
    for (i=1;i<=n;i++) {
      m=split(pkgs[a[i] ":" p],b," ")
      if (n==1) {
        for (j=1;j<=m;j++)
          print "  " b[j]
      } else if (m > 3)
        print "  " a[i] " " b[1] " and " m-1 " other packages"
      else
        print "  " a[i] " " pkgs[a[i] ":" p]
    }
  }
  exit ret
}

# vim: set ts=2 sw=2 et:
