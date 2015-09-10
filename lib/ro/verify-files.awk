# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

BEGIN {
  FS="\t"
}

FILENAME=="-" {
  if (!match($1,/^#\//))
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
