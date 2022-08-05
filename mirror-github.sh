#!/usr/bin/env bash

[ ! -d "/data" ] && echo "error: no volume mounted to /data" && exit 1

cd /data

repos=`curl --silent -u jdmichaud:$gh_token https://api.github.com/user/repos?per_page=1000 -q | grep clone_url | sed -e 's/[[:space:]]*"clone_url": "\([^"]*\)",/\1/g'`

for repo in $repos
do
  repo_with_token=`echo $repo | sed -e "s#https://\(.*\)#https://$gh_token@\1#g"`
  git clone --mirror $repo_with_token
done

for folder in `ls`
do
  pushd . > /dev/null
  cd $folder
  echo updating $(pwd)
  git remote set-url origin https://$gh_token@github.com/jdmichaud/$folder
  git remote update --prune
  popd > /dev/null
done

