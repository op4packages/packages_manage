#!/usr/bin/env bash
dir=$1;shift;
prefix=$1;shift;
package=$1;shift;
remote=$1;shift;
# remote_branch=$1;shift;
cd ${dir}
# [ -z "${remote_branch}" ] && remote_branch=${package}
local_branch=$(git rev-parse --abbrev-ref HEAD)
echo "${package}"
git subtree split --prefix=${prefix} -b ${package}
git checkout ${package}
local_commit_id = $(git rev-parse HEAD)
echo 0 > /tmp/curl_temp
curl -f -s -o /tmp/curl_temp https://api.github.com/repos/op4packages/${package}/commits/upstream -H "Accept:application/vnd.github.v3.sha"
remote_commit_id = $(cat /tmp/curl_temp)
if [ "${local_commit_id}" != "${remote_commit_id}" ]; then
    git push -f ${remote} ${package}:upstream
    git pull --rebase ${remote} ${remote_branch}
    git push -f ${remote} ${package}:${remote_branch}
    line=`sed -n "/^${package} /=" ${GITHUB_WORKSPACE}/version 2>/dev/null`
    if [ "${line}" != "" ]; then
        sed -i "${line} d" ${GITHUB_WORKSPACE}/version
        sed -i "${line} i${package} ${local_commit_id}" ${GITHUB_WORKSPACE}/version
    else
        echo "${package} ${local_commit_id}" >> ${GITHUB_WORKSPACE}/version
    fi

fi
rm /tmp/curl_temp
git checkout ${local_branch}
