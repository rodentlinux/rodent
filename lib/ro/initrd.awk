# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

BEGIN {
  FS="\t"
  OFS=" "
}

function escape(path) {
  gsub(/\\/,"\\\\",path)
  gsub(/ /,"\\ ",path)
  return path
}

{
  path=escape($1)
  if ($2=="d")
    print "dir","/" path,$3,$4,$5
  else if ($2=="f")
    print "file","/" path,path,$3,$4,$5
  else if ($2=="l")
    print "slink","/" path,escape($6),$3,$4,$5
  else if ($2=="c"||$2=="b")
    print "nod","/" path,$3,$4,$5,$2,$6,$7
}

# vim: set ts=2 sw=2 et:
