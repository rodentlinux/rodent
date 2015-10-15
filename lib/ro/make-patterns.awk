# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

# Roughly translate sh-style globbing to regular expressions
# ^$()+|.{} are escaped with \
# ** is translated to .*
# * is translated to [^/]*
# ? is translated to .
function glob2re(glob,re,len,cpos,c,lastesc,laststar) {
  re="^"
  # lastesc: Last character was a \
  # laststar: Last character was a *
  len = length(glob)
  for (cpos=1;cpos<=len;cpos++) {
    c = substr(glob,cpos,1)
    if (laststar) {
      laststar=0
      if (c=="*") {
        re=re ".*"
        continue
      }
      re=re "[^/]*"
    }
    if (lastesc) {
      re=re c
      lastesc=0
    } else if (index("^$()+|.{}",c)) {
      re=re "\\" c
    } else if (c=="?") {
      re=re "."
    } else if (c=="\\") {
      lastesc=1
    } else if (c=="*") {
      laststar=1
    } else
      re=re c
  }
  if (laststar)
    re=re "[^/]*"
  return re "$"
}

BEGIN {
  FS="\t"
  n=0
}

FILENAME=="-" {
  if (!index($1,"\\")&&!index($1,"?")&&!index($1,"*")) {
    exact[$1]=1
  } else {
    n++
    glob[n]=$1
    pattern[n]=glob2re($1)
  }
}

FILENAME!="-" {
  if (exact[$1]) {
    seen[$1]=1
    print $1
  } else {
    delete exact[$1]
    for (i=1;i<=n;i++) {
      if (match($1,pattern[i])) {
        matched[i]=1
        print $1
        break
      }
    }
  }
}

END {
  for (i in exact) {
    if (!seen[i])
      print "WARNING: file '" i "' not found" > "/dev/stderr"
  }
  for (i=1;i<=n;i++) {
    if (!matched[i])
      print "WARNING: pattern '" glob[i] "' not found" > "/dev/stderr"
  }
}

# vim: set ts=2 sw=2 et:
