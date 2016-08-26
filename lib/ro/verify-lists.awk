# This file is part of Rodent Linux
# Copyright 2015-2016 Emil Renner Berthing

BEGIN {
  FS="\t"
}

FILENAME=="-" {
  if ($1!~/\.hook\.files$/)
    tag[$1]=2
}

FILENAME!="-" {
  split($1,a,/=/)
  tag[a[1] "-" a[2] ".files"]++
}

END {
  for (i in tag) {
    n=tag[i]
    if (n==1)
      print "+ #/" i
    if (n==2)
      print "- #/" i
  }
}

# vim: set ts=2 sw=2 et:
