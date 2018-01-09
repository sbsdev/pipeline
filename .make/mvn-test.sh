[[ -n ${VERBOSE+x} ]] && set -x
set -e
set -o pipefail
for arg in "$@"; do
    cd "$CURDIR/$arg"
    eval $MVN clean verify | eval $MVN_LOG
done
