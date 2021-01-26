#!/bin/bash

repo="juliancruzsanchez/kubeconfig"

mkdir .kui_init
cd .kui_init
curl https://raw.githubusercontent.com/$repo/main/getToken.sh
curl https://raw.githubusercontent.com/$repo/main/makeUsers.sh
