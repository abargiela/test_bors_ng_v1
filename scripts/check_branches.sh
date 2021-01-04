#!/bin/bash

# The SRC_REPO refers to the working repository, the repository where developers are working at the momment.
SRC_REPO="git@github.com:abargiela/test_bors.git"
SRC_BANCHES_LIST="/tmp/src_branches.txt"
# DST_REPO refers to the repository that receive a copy of the SRC_REPO.
DST_BANCHES_LIST="/tmp/dst_branches.txt"
# Final file with the difference of branches between the dst_repo and the src_repo
DIFF_BRANCHES="/tmp/diff_branches.txt"

# list src_branches and dst_branches 
git ls-remote --heads ${SRC_REPO} | awk -F \/ '{print $3}' > ${SRC_BANCHES_LIST}
git branch -a | awk -F \/ '{print $3}' | egrep -v "^HEAD|^$" > ${DST_BANCHES_LIST}

# check the difference between the dst_repo and src_repo and get only the difference
diff -u  ${DST_BANCHES_LIST} ${SRC_BANCHES_LIST} | grep ^- | sed '1d' | awk -F ^- '{print $2}' | egrep -v "master|^dev$"  > ${DIFF_BRANCHES}

# If the diff file contains data the delete is executed because there is something to be removed.
if [ -s ${DIFF_BRANCHES} ]; then
    # As Im already in the repo I want to remove the branches, I execute the remove.
    for branches in $(cat ${DIFF_BRANCHES}); do
        git push origin --delete ${branches}
    done
else
    echo "Nothing to be deleted";
fi
