# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

BEGIN {
  FS="\t"
}

FILENAME=="-" {
  pkgs[$1]=1
}

FILENAME!="-" {
  if (!pkgs[$1])
    print

  delete pkgs[$1]
}

# vim: set ts=2 sw=2 et :
