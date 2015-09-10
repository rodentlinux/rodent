# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

BEGIN {
  FS="\t"
}

{
  name[NR]=$1
  depends[NR]=$4

  provides_add(installed,$1,$3)
}

END {
  for (i=1;i<=NR;i++) {
    pkg=name[i]
    list=""
    m=split(depends[i],darr," ")
    for (j=1;j<=m;j++) {
      if (dep_resolve(installed,darr[j],deps)==1) {
        list=list_append(list,deps[1])
        rgraph[deps[1]]=list_append(rgraph[deps[1]],pkg)
      }
    }
    graph[pkg]=list
  }

  rtop=0
  top=0
  for (pkg in graph) {
    if (tag[pkg])
      continue

    top++
    stack[top]=pkg
    idx[top]=1
    tag[pkg]=1
    while (top) {
      pkg=stack[top]
      i=idx[top]

      n=split(graph[pkg],edge," ")
      if (i<=n) {
        pkg=edge[i]
        idx[top]=i+1

        if (!tag[pkg]) {
          top++
          stack[top]=pkg
          idx[top]=1
          tag[pkg]=1
        }
      } else {
        top--
        rstack[++rtop]=pkg
      }
    }
  }

  while (rtop) {
    pkg=rstack[rtop]
    delete rstack[rtop]
    rtop--
    if (!tag[pkg])
      continue

    top++
    stack[top]=pkg
    delete tag[pkg]
    while (top) {
      pkg=stack[top]
      top--
      scc[pkg]=1

      n=split(rgraph[pkg],edge," ")
      for (i=1;i<=n;i++) {
        dpkg=edge[i]
        sccrdeps[dpkg]=1
        if (tag[dpkg]) {
          top++
          stack[top]=dpkg
          delete tag[dpkg]
        }
      }
    }

    nordeps=1
    for (i in scc)
      delete sccrdeps[i]
    for (i in sccrdeps) {
      nordeps=0
      delete sccrdeps[i]
    }
    if (nordeps) {
      for (i in scc)
        leaf[i]=1
    }
    for (i in scc)
      delete scc[i]
  }

  for (i=1;i<=NR;i++) {
    pkg=name[i]
    if (leaf[pkg])
      print pkg
  }
}

# vim: set ts=2 sw=2 et :
