# This file is part of Rodent Linux
# Copyright 2016 Emil Renner Berthing

BEGIN {
  FS="\t"
}

$2=="d"{ printf "%4s %5u %5u %s/\n",$3,$4,$5,$1 }
$2=="f"{ printf "%4s %5u %5u %s\n",$3,$4,$5,$1 }
$2=="l"{ printf "%4s %5u %5u %s -> %s\n",$3,$4,$5,$1,$6 }
$2=="b"{ printf "%4s %5u %5u %s (block)\n",$3,$4,$5,$1 }
$2=="c"{ printf "%4s %5u %5u %s (character)\n",$3,$4,$5,$1 }

# vim: set ts=2 sw=2 et:
