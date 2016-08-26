# This file is part of Rodent Linux
# Copyright 2015-2016 Emil Renner Berthing

BEGIN {
  FS="\t"
}

FILENAME=="-" {
  if ($1!~/^#.*\.files$/&&$1!="#/installed")
    tag[$1]=2
}

FILENAME!="-" {
  if ($2=="d"||$2=="f"||$2=="l")
    tag[$1]++
}

END {
  delete tag["#"]
  for (i in tag) {
    n=tag[i]
    if (n==1)
      print "+ " i
    if (n==2)
      print "- " i
  }
}

# vim: set ts=2 sw=2 et:
