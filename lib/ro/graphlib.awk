# This file is part of Rodent Linux
# Copyright 2015 Emil Renner Berthing

function list_append(list,v) {
  if (!list)
    return v
  return list " " v
}

function list_squash(array,n,i,list) {
  list=array[1]
  for (i=2;i<=n;i++)
    list=list " " array[i]
  return list
}

function provides_add(map,pkg,plist,name,ver,pver,i,n,array) {
  i=index(pkg,"=")
  ver=substr(pkg,i+1)
  name=substr(pkg,1,i-1)

  map[name]=list_append(map[name],pkg "=" ver)

  n=split(plist,array," ")
  for (i=1;i<=n;i++) {
    name=array[i]
    if (match(name,/=/)) {
      pver=substr(name,RSTART+1)
      name=substr(name,1,RSTART-1)
    } else
      pver=ver
    map[name]=list_append(map[name],pkg "=" pver)
  }
}

function verleq(v1,v2,a1,a2,n1,n2,i) {
  if (v1==v2)
    return 1
  i=index(v1,"-")
  if (i) {
    n1=substr(v1,i+1)
    v1=substr(v1,1,i-1)
  }
  i=index(v2,"-")
  if (i) {
    n2=substr(v2,i+1)
    v2=substr(v2,1,i-1)
  }
  if (v1==v2) {
    if (n1<=n2)
      return 1
    return 0
  }
  n1=split(v1,a1,".")
  n2=split(v2,a2,".")
  for (i=1;;i++) {
    if (i>n1)
      return 1
    if (i>n2)
      return 0
    if (a1[i]<a2[i])
      return 1
    if (a1[i]>a2[i])
      return 0
  }
}

function dep_resolve(provides,dep,array,eq,geq,lt,i,n,m,pa,found,tmp) {
  if (match(dep,/>=/)) {
    geq=substr(dep,RSTART+2)
    dep=substr(dep,1,RSTART-1)
    if (match(geq,/</)) {
      lt=substr(geq,RSTART+1)
      geq=substr(geq,1,RSTART-1)
    }
  } else if (match(dep,/</)) {
    lt=substr(dep,RSTART+1)
    dep=substr(dep,1,RSTART-1)
  } else if (match(dep,/=/)) {
    eq=substr(dep,RSTART+1)
    dep=substr(dep,1,RSTART-1)
  }
  n=split(provides[dep],array," ")
  for (i=1;i<=n;i++) {
    split(array[i],pa,"=")
    if (eq && eq!=pa[3])
      continue
    if (geq && geq!=pa[3] && verleq(pa[3],geq))
      continue
    if (lt && verleq(lt,pa[3]))
      continue
    tmp=found[pa[1]]
    if (!tmp || verleq(tmp,pa[2]))
      found[pa[1]]=pa[2]
  }
  m=0
  for (tmp in found)
    array[++m]=tmp "=" found[tmp]
  for (i=m+1;i<=n;i++)
    delete array[i]
  return m
}

# vim: set ts=2 sw=2 et:
