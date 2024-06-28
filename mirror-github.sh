#!/usr/bin/env bash

#[ ! -d "/data" ] && echo "error: no volume mounted to /data" && exit 1

#cd /data

cd /media/jedi/fastdisk/test/

page=1
repos=()

# Fetch repos list
repos_per_page=("placeholder")
while [ ${#repos_per_page[@]} -gt 0 ]
do
  echo Loading page $page
  repos_per_page=($(curl --silent -u jdmichaud:$gh_token "https://api.github.com/user/repos?per_page=100&page=$page" -q | grep clone_url | sed -e 's/[[:space:]]*"clone_url": "\([^"]*\)",/\1/g'i))
  echo Found ${#repos_per_page[@]} repos
  repos+=(${repos_per_page[@]})
  page=$(($page+1))
done

# Clone repos
for repo in ${repos[@]}
do
  repo_with_token=`echo $repo | sed -e "s#https://\(.*\)#https://$gh_token@\1#g"`
  echo $repo_with_token
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

# Fetch gist list
page=1
gists=()
gists_per_page=("placeholder")
while [ ${#gists_per_page[@]} -gt 0 ]
do
  echo Loading page $page
  gists_per_page=($(curl --silent -u jdmichaud:$gh_token "https://api.github.com/gists?per_page=100&page=$page" -q | grep git_pull_url | sed -e 's/[[:space:]]*"git_pull_url": "\([^"]*\)",/\1/g'i))
  echo Found ${#gists_per_page[@]} gists
  gists+=(${gists_per_page[@]})
  page=$(($page+1))
done

# Clone gists in a sub folder
mkdir -p gists
cd gists
for repo in ${gists[@]}
do
  repo_with_token=`echo $repo | sed -e "s#https://\(.*\)#https://$gh_token@\1#g"`
  echo $repo_with_token
  git clone --mirror $repo_with_token
done

# Update existing gists
for folder in `ls`
do
  pushd . > /dev/null
  cd $folder
  echo updating $(pwd)
  git remote update --prune
  popd > /dev/null
done
cd -

