# This file is part of Rodent Linux
# Copyright 2015-2016 Emil Renner Berthing

BEGIN {
  FS="\t"
  d=0
  f=0
  l=0
  o=0
}

{
  if ($2=="d") {
    d++
  } else if ($2=="f") {
    f++
  } else if ($2=="l") {
    l++
  } else {
    o++
  }
}

END { print f " " l " " d " " o }

# vim: set ts=2 sw=2 et:
