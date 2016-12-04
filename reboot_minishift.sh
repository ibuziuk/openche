#!/bin/bash
minishift stop

minishift delete

minishift start

eval $(minishift docker-env)

oc login -u admin -p admin -n default
docker pull openshift/origin-haproxy-router:`oc version | awk '{ print $2; exit }'`
oc adm policy add-scc-to-user hostnetwork -z router
oc adm router --create --service-account=router --expose-metrics --subdomain="openshift.mini"

# Create OpenShift project
oc login -u openshift-dev -p devel
oc new-project eclipse-che

# Create a serviceaccount with privileged scc
oc login -u admin -p admin -n eclipse-che
oc create serviceaccount cheserviceaccount
oc adm policy add-scc-to-user privileged -z cheserviceaccount

oc login -u openshift-dev -p devel
export CHE_HOSTNAME=che.openshift.mini
export CHE_IMAGE=codenvy/che-server:local
export DOCKER0_IP=$(docker run -ti --rm --net=host alpine ip addr show docker0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
export CHE_OPENSHIFT_ENDPOINT=https://$(minishift ip):8443

echo $(minishift ip)