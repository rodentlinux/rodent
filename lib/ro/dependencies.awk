# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

BEGIN {
  FS="\t"
  OFS="\t"
}

FILENAME=="-" {
  base_repo[$4]=$1
  base_url[$4]=$2
  base_hash[$4]=$5

  repo_base[$3]=$4
  repo_provides[$3]=$6
  repo_depends[$3]=$7
  repo_description[$3]=$8
}

FILENAME!="-" {
  provides_add(installed,$1,$3)
}

END {
  for (pkg in repo_base)
    provides_add(repo,pkg,repo_provides[pkg])

  repo_depends["<cmdline>"]=ENVIRON["DEPS"]

  k=0
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
      m=dep_resolve(repo,dep,array)
      if (m==0) {
        print "notfound"
        print dep
        print
        print
        print
        print
        exit
      }
      if (m>1) {
        print "choice"
        print list_squash(array,m)
        print
        print
        print
        print
        exit
      }
      pkg=array[1]
      queue[++tail]=pkg
      provides_add(installed,pkg,repo_provides[pkg])

      base=repo_base[pkg]
      if (!seen[base]) {
        bases[++k]=base
        seen[base]=1
      }
    }
  }

  for (j=k;j>0;j--) {
    base=bases[j]
    for (i=2;i<=tail;i++) {
      pkg=queue[i]
      if (repo_base[pkg]==base) {
        print pkg
        print base_repo[base]
        print base
        print base_url[base]
        print base_hash[base]
        print "x" repo_provides[pkg],repo_depends[pkg],repo_description[pkg]
      }
    }
  }
}

# vim: set ts=2 sw=2 et:
