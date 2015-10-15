# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

BEGIN {
  FS="\t"
}

FILENAME=="-" {
  path=$1
  tag[path]=1
  while (match(path,/\/[^\/]*$/)) {
    path=substr(path,1,RSTART-1)
    if (tag[path])
      break
    tag[path]=1
  }
}

FILENAME!="-" {
  if (tag[$1])
      print
}

# vim: set ts=2 sw=2 et:
