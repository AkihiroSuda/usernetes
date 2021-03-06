#!/bin/bash
set -eu -o pipefail
if [[ $# -lt 3 ]]; then
	echo "Usage: $0 NAME IMAGE ARGS"
	exit 1
fi

cd $(realpath $(dirname $0)/..)
container=$1
image=$2
shift 2
args=$@

set -x
tmpdir=$(mktemp -d)
docker run -td --name $container -p 127.0.0.1:8080:8080 --privileged rootlesscontainers/usernetes -p 0.0.0.0:8080:8080/tcp $args
function cleanup() {
	docker rm -f $container
	rm -rf $tmpdir
}
trap cleanup EXIT

export KUBECONFIG=$(pwd)/config/localhost.kubeconfig
docker cp $container:/home/user/usernetes/bin/kubectl $tmpdir/kubectl
chmod +x $tmpdir/kubectl
kubectl=$tmpdir/kubectl

if ! timeout 60 sh -exc "until [ \$(docker inspect -f '{{.State.Health.Status}}' $container) = \"healthy\" ]; do sleep 10; done"; then
	docker logs $container
	exit 1
fi
$kubectl get nodes -o wide
if ! timeout 60 time $kubectl run --rm -i --image busybox --restart=Never hello echo hello $container; then
	$kubectl get pods -o yaml
	$kubectl get nodes -o yaml
	docker logs $container
	exit 1
fi
