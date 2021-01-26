#!/bin/bash

repo="juliancruzsanchez/kubeconfig"
username="admin-user"
ixio="f"
tokenOnly="f"

while [ "$1" != "" ]; do
    case $1 in
        i | ixio) shift
                    ixio=t
                    ;;
        h | help) 
                    showHelp
                    exit
                    ;;
        u | username) 
                    username=$1
                    ;;
        tokenOnly | t) 
                    tokenOnly=t
                    ;;
    esac
    shift
done

mkdir .kui_init
cd .kui_init

function showHelp {
  echo """
  i | ixio - Pipes token to ix.io then displays link (useful for systems that're RDPed into CLIs)
  h | help - Shows this menu
  u | username [username] - Set username for user
  t | tokenOnly - Only generates token doesn't make user
  """
}
# Makes Users
function makeUsers {
  """
  echo "Making User $username..."
  cat <<EOF | kubectl apply -f -
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: $username
    namespace: kubernetes-dashboard
  EOF
  
  
  echo "Done."
  echo "Assigning ClusterRole to $username..."
  
  cat <<EOF | kubectl apply -f -
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRoleBinding
  metadata:
    name: $username
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: cluster-admin
  subjects:
  - kind: ServiceAccount
    name: $username
    namespace: kubernetes-dashboard
  EOF
  """
}

function getToken {
  kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/$username -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}" 1> token
  cat token
  if [ $ixio = "t" ]; then
    cat token | curl -F 'f:1=<-' ix.io
  fi
}

if [$tokenOnly = "t"]; then
  getToken
else
  makeUsers
  getToken
fi

cd ..
rm -rf .kui_init
