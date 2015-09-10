# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

BEGIN {
  FS="\t"
  keep["d"]=1
  keep["l"]=1
  keep["f"]=1
  tag["#"]=1
}

FILENAME!="-" {
  if (keep[$2])
    tag[$1]=1
}

FILENAME=="-" {
  if (!tag[$1] && !match($1,/^#\//))
    print $1
}

# vim: set ts=2 sw=2 et:
