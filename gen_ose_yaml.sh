#/bin/bash
oc process -f openshift.iotools.buildNrun.yaml -p APPLICATION_NAME=iotools -p SOURCE_DOCKERFILE=Dockerfile -p SOURCE_REPOSITORY_REF=master
