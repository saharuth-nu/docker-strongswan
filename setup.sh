#!/usr/bin/bash

if [ "$1" = "1" ]; then
  docker network create -d bridge \
  --subnet 192.168.0.0/16 \
  --subnet 2001:db8::/80 \
  --ipv6 \
  internet
elif [ "$1" = "2" ]; then
  docker volume create strongswan-data
elif [ "$1" = "3" ]; then
  docker run \
  -v strongswan-data:/data \
  griffinplus/strongswan \
  init \
  --ca-pass="yCkU588n3pFMYY9*" \
  --ca-key-type="rsa4096" \
  --server-key-type="rsa3072" \
  --client-key-type="rsa3072" \
  --ca-cert-subject="CN=VPN Root CA,OU=IT Department,O=Kwisatz Corp,C=TH" \
  --server-cert-subject="CN=vpn.kwisatz.com,OU=Network Operations,O=Kwisatz Corp,C=TH" \
  --client-cert-subject="CN=Saharuth Nuallaong,OU=Engineering,O=Kwisatz Corp,C=TH"
elif [ "$1" = "4" ]; then
  docker run -it \
  --name strongswan-vpn \
  --ip6=2001:db8::2 \
  --network internet \
  --publish 500:500/udp \
  --publish 4500:4500/udp \
  --volume /lib/modules:/lib/modules:ro \
  --volume strongswan-data:/data \
  --cap-add NET_ADMIN \
  --cap-add SYS_MODULE \
  --cap-add SYS_ADMIN \
  --security-opt apparmor=unconfined \
  --security-opt seccomp=unconfined \
  --env VPN_HOSTNAMES="myvpn-kwisatz.duckdns.org" \
  --env USE_DOCKER_DNS=false \
  griffinplus/strongswan \
  run-and-enter
else
  echo "Error run command."
  exit 1
fi
