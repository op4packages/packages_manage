#!/usr/bin/env bash
dir=$1;shift;
prefix=$1;shift;
package=$1;shift;
remote=$1;shift;
remote_branch=$1;shift;
cd ${dir}
[ -z "${remote_branch}" ] && remote_branch=${package}
local_branch=$(git rev-parse --abbrev-ref HEAD)
echo "${package}"
git subtree split --prefix=${prefix} -b ${package}
git checkout ${package}
git pull --rebase ${remote} ${remote_branch}
git push -f ${remote} ${package}:${remote_branch}

git checkout ${local_branch}
