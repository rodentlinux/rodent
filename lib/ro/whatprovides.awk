# This file is part of Rodent Linux
# Copyright 2016 Emil Renner Berthing

BEGIN {
  FS="\t"
  OFS="\t"
  needle=ENVIRON["WHAT"]
  dep=needle
  if (match(dep,/>=/)) {
    geq=substr(dep,RSTART+2)
    dep=substr(dep,1,RSTART-1)
    if (match(geq,/</)) {
      lt=substr(geq,RSTART+1)
      geq=substr(geq,1,RSTART-1)
    }
  } else if (match(dep,/</)) {
    lt=substr(dep,RSTART+1)
    dep=substr(dep,1,RSTART-1)
  } else if (match(dep,/=/)) {
    eq=substr(dep,RSTART+1)
    dep=substr(dep,1,RSTART-1)
  }
}

{
  split($2,pkg,"=")
  if (pkg[1]==dep&&vermatch(pkg[2],geq,lt,eq)) {
    print $1 ": " $2 " from " $3
    found=1
  }

  n=split($4,provs," ")
  for (i=1;i<=n;i++) {
    split(provs[i],pa,"=")
    if (pa[1]==dep&&vermatch(pa[2],geq,lt,eq)) {
      print $1 ": " $2 " from " $3 " provides " provs[i]
      found=1
    }
  }
}

END {
  if (!found)
    print "Nothing seems to provide '" needle "'"
}

# vim: set ts=2 sw=2 et:
