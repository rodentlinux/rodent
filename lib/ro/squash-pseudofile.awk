# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

BEGIN {
  FS="\t"
  OFS=" "
}

{
  path=$1
  gsub(/\\/,"\\\\",path)
  gsub(/ /,"\\ ",path)
  if ($2=="d" || $2=="f" || $2=="l")
    print path,"m",$3,$4,$5
  else if ($2=="b" || $2=="c")
    print path,$2,$3,$4,$5,$6,$7
}

# vim: set ts=2 sw=2 et:
