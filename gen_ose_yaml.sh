#/bin/bash
oc process -f openshift.headless-vnc.buildandrun.yaml -p APPLICATION_NAME=iotools -p SOURCE_DOCKERFILE=Dockerfile -p SOURCE_REPOSITORY_REF=master
