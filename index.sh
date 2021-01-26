#!/bin/bash

repo="juliancruzsanchez/kubeconfig"
username="admin-user"
while getopts ixio:username:u:help:tokenOnly: flag
do
    case "${flag}" in
        ixio) ixio=${OPTARG};;
        help) help=true
        username) username=${OPTARG};;
        u) username=${OPTARG};;
        tokenOnly) tokenOnly=${OPTARG};;
    esac
done

mkdir .kui_init
cd .kui_init

# Makes Users
function makeUsers {
  cat <<EOF | kubectl apply -f -
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: $username
    namespace: kubernetes-dashboard
  EOF

  cat <<EOF | kubectl apply -f -
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRoleBinding
  metadata:
    name: admin-user
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: cluster-admin
  subjects:
  - kind: ServiceAccount
    name: $username
    namespace: kubernetes-dashboard
  EOF  
}

function getToken {
  kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/$username -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}" 1> token
  cat token
  if [ $ixio = true ]; then
    cat token | curl -F 'f:1=<-' ix.io
  fi
}

if [$tokenOnly = true]; then
  getToken
else
  makeUsers
  getToken
