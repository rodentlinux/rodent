# This file is part of Rodent Linux
# Copyright 2016 Emil Renner Berthing

BEGIN {
  FS="\t"
  OFS="\t"
  needle=ENVIRON["WHAT"]
}

{
  n=split($5,deps," ")
  for (i=1;i<=n;i++) {
    dep=deps[i]
    cons=""
    if (match(dep,/[=<>]/)) {
      cons=substr(dep,RSTART)
      dep=substr(dep,1,RSTART-1)
    }
    if (dep==needle) {
      print $1 ": " $2 " from " $3 " depends on " dep cons
      found=1
    }
  }
}

END {
  if (!found)
    print "Nothing seems to depend on '" needle "'"
}

# vim: set ts=2 sw=2 et:
