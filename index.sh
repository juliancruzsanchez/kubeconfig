#!/bin/bash

repo="juliancruzsanchez/kubeconfig"

mkdir .kui_init
cd .kui_init
curl "https://raw.githubusercontent.com/$repo/main/makeUsers.sh"
curl "https://raw.githubusercontent.com/$repo/main/getToken.sh"
chmod +x getToken.sh makeUsers.sh
