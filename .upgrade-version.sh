#!/bin/bash

set -eu -o pipefail

kubebuilder_version=$(kubebuilder version | sed 's/.*KubeBuilderVersion:\"\([v0-9\.]*\)\".*/\1/g')
kubernetes_version=$(kubebuilder version | sed 's/.*KubernetesVendor:\"\([v0-9\.]*\)\".*/\1/g')
go_version=$(go version | sed 's/go version \(.*\) darwin\/amd64/\1/g')
VERSIONS="kubebuilder: $kubebuilder_version, kubernetes: $kubernetes_version, go: $go_version"
GIT_TAG=kubebuilder@${kubebuilder_version}-go@${go_version}

if [ $(git tag -l "$GIT_TAG") ]; then
	echo "Git tag ($GIT_TAG) already exists"
	exit 0
fi

for f_or_dir in `ls`; do rm -rf $f_or_dir || true; done
git add .
git commit -a -m "Remove all files to upgrade versions ($VERSIONS)"

kubebuilder init --domain my.domain --repo my.domain/guestbook
git add .
git commit -a -m "Start a project ($VERSIONS)"

kubebuilder create api --group webapp --version v1 --kind Guestbook --resource --controller
git add .
git commit -a -m "Create an API Guestbook ($VERSIONS)"

git tag -a "$GIT_TAG" -m "kubebuilder@${kubebuilder_version} & go@${go_version}"
