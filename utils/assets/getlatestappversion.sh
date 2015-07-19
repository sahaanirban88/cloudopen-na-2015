#!/bin/bash

git_output=`git ls-remote --tags $1`
full_version=`echo "$git_output" | awk -F'/' '{ print $NF }' | awk -F'^' '{ print $1 }' | uniq | tail -1`
version=${full_version#?} && a=( ${version//./ } )
if [ ${a[2]} -eq 9 ]
  then
  a[2]=0
  if [ ${a[1]} -eq 9 ]
    then
    a[1]=0 && ((a[0]++))
    else
    ((a[1]++))
  fi
  else
  ((a[2]++))
fi
new_version="${a[0]}.${a[1]}.${a[2]}"
echo "app_version: v$version" > /tmp/version.properties
echo "new_version: v$new_version" >> /tmp/version.properties
