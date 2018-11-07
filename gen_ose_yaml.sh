#/bin/bash
[ -z "$1" ] && echo "No argument supplied" && exit 1
oc process -f openshift.iotools.buildNrun.yaml -p APPLICATION_NAME=$1 -p SOURCE_DOCKERFILE=Dockerfile -p SOURCE_REPOSITORY_REF=master
