#!/bin/bash

git_output=`git ls-remote --tags git@gitlab.com:asaha/mywebapp.git`
app_version=`echo "$git_output" | awk -F'/' '{ print $NF }' | awk -F'^' '{ print $1 }' | uniq | tail -1`
echo $app_version
