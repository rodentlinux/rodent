# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

BEGIN {
  FS="\t"
}

FILENAME=="-" {
  path=$1
  tag[path]=1
  exact[path]=1
  while (match(path,/\/[^\/]*$/)) {
    path=substr(path,1,RSTART-1)
    if (tag[path])
      break
    tag[path]=1
  }
}

FILENAME!="-" {
  if (prefix) {
    if (plen<length($1) && substr($1,1,plen)==prefix)
      print
    else
      prefix=""
  }

  if (!prefix) {
    if (tag[$1]) {
      print
      if ($2=="d" && exact[$1]) {
        prefix=$1 "/"
        plen=length(prefix)
      }
    }
  }
}

# vim: set ts=2 sw=2 et:
