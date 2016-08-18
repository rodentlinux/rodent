# This file is part of Rodent Linux
# Copyright 2016 Emil Renner Berthing

BEGIN {
  FS="\t"
  OFS="\t"
  needle="^" ENVIRON["WHAT"] "="
}

{
  if (match($2,needle)) {
    if ($2==$3)
      print $2 " in repo " $1
    else
      print $2 " from " $3 " in repo " $1
    if ($1=="installed")
      print " - " $6
    else
      print " - " $7
    if ($4) {
      print "provides:"
      n=split($4,a," ")
      for (i=1;i<=n;i++)
        print "  " a[i]
    }
    if ($5) {
      print "depends:"
      n=split($5,a," ")
      for (i=1;i<=n;i++)
        print "  " a[i]
    }
    print ""
    found=1
  }
}

END {
  if (!found)
    print "Not found."
}

# vim: set ts=2 sw=2 et:
