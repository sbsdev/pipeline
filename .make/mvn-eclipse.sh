[[ -n ${VERBOSE+x} ]] && set -x
set -e
set -o pipefail

# start eclim if available
if which eclim >/dev/null; then
    if ! eclim -command ping >/dev/null 2>/dev/null; then
        echo "Please start Eclim" >&2
        exit 1
    fi
    if [ "$CURDIR" != "$( eval printf "$(eclim -command workspace_dir)" )" ]; then
        echo "Please switch to your Eclipse workspace '$CURDIR'" >&2
        exit 1
    fi
fi

# renaming existing projects means trouble
for module in "$@"; do
    if [ -e $module/.project ]; then
        groupId=$(xmllint --xpath "/*/*[local-name()='groupId']/text()" $module/pom.xml 2>/dev/null) || \
        groupId=$(xmllint --xpath "/*/*[local-name()='parent']/*[local-name()='groupId']/text()" $module/pom.xml)
        artifactId=$(xmllint --xpath "/*/*[local-name()='artifactId']/text()" $module/pom.xml)
        name=$( xmllint --xpath "string(/projectDescription/name)" $module/.project 2>/dev/null )
        if [ "${groupId}.${artifactId}" != $name ]; then
            echo "Project at '$module' cannot be renamed to '${groupId}.${artifactId}'" >&2
            exit 1
        fi
    fi
done

# generate projects one by one, otherwise projectNameTemplate is not used for inter-module links (Maven bug)
for module in "$@"; do
    eval $MVN --projects $module \
              org.apache.maven.plugins:maven-eclipse-plugin:2.10:eclipse \
              -Declipse.useProjectReferences=true \
              -Declipse.projectNameTemplate=[groupId].[artifactId] \
    | eval $MVN_LOG
done

# import projects with eclim if available
if which eclim >/dev/null; then
    for module in "$@"; do
        if [ -e "$CURDIR/$module/.project" ]; then
            msg=$( eclim -command project_import -f "$CURDIR/$module" )
            msg=$( eval printf "$msg" )
            if project=$( perl -e '$ARGV[0] =~ /^Project with name \x27(.+?)\x27 already exists/ and print "$1" or exit 1' "$msg" ); then
                msg=$( eclim -command project_update -p $project )
                eval printf "$msg"
                echo
            else
                echo "$msg"
            fi
        fi
    done
else
    # print instructions if eclim not available
    for module in "$@"; do
        echo "Now import the project at '$module' into your Eclipse workspace" >&2
    done
fi

