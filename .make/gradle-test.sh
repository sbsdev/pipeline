[[ -n ${VERBOSE+x} ]] && set -x
set -e
for arg in "$@"; do
    cd "$CURDIR/$arg"
    eval $GRADLE --no-search-upward test
done
