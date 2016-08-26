# This file is part of Rodent Linux
# Copyright 2015-2016 Emil Renner Berthing

BEGIN {
  FS="\t"
  OFS="\t"
}

FILENAME=="-" {
  base_repo[$3]=$1
  base_hash[$3]=$6

  repo_base[$2]=$3
  repo_provides[$2]=$4
  repo_depends[$2]=$5
  repo_description[$2]=$7

  provides_add(repos,$2,$4)
}

FILENAME!="-" {
  provides_add(installed,$1,$3)
}

END {
  repo_depends["<cmdline>"]=ENVIRON["DEPS"]

  head=0
  tail=0
  queue[++tail]="<cmdline>"
  while (head<tail) {
    pkg=queue[++head]

    n=split(repo_depends[pkg],darray," ")
    for (i=1;i<=n;i++) {
      dep=darray[i]
      m=dep_resolve(installed,dep,array)
      if (m>0)
        continue
      m=dep_resolve(repos,dep,array)
      if (m==0) {
        print "Could not find dependency '" dep "' of " pkg
        exit 1
      }
      if (m>1) {
        print "Which of these do you want?"
        for (j=1;j<=m;j++)
          print " - " array[j]
        exit 1
      }
      dep=array[1]
      queue[++tail]=dep
      provides_add(installed,dep,repo_provides[dep])
    }
  }

  for (i=tail;i>1;i--) {
    pkg=queue[i]
    base=repo_base[pkg]
    print base_repo[base],pkg,base,repo_provides[pkg],repo_depends[pkg],base_hash[base],repo_description[pkg]
  }
}

# vim: set ts=2 sw=2 et:
