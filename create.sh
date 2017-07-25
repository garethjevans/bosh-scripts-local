#!/bin/sh

if [[ ! -d bosh-deployment ]]; then
	git clone https://github.com/cloudfoundry/bosh-deployment	
fi

bosh2 create-env bosh-deployment/bosh.yml \
  --state ./state.json \
  -o bosh-deployment/virtualbox/cpi.yml \
  -o bosh-deployment/virtualbox/outbound-network.yml \
  -o bosh-deployment/bosh-lite.yml \
  -o bosh-deployment/bosh-lite-runc.yml \
  -o bosh-deployment/jumpbox-user.yml \
  -o bosh-deployment/uaa.yml \
  -o bosh-deployment/credhub.yml \
  --vars-store ./creds.yml \
  -v director_name="Bosh Lite Director" \
  -v internal_ip=192.168.50.6 \
  -v internal_gw=192.168.50.1 \
  -v internal_cidr=192.168.50.0/24 \
  -v outbound_network_name=NatNetwork

if [[ ! -d cf-deployment ]]; then
	git clone https://github.com/cloudfoundry/cf-deployment	
fi

bosh2 update-cloud-config cf-deployment/bosh-lite/cloud-config.yml

bosh2 upload-stemcell https://s3.amazonaws.com/bosh-core-stemcells/warden/bosh-stemcell-3421.11-warden-boshlite-ubuntu-trusty-go_agent.tgz 

bosh2 -d cf deploy \
  -o cf-deployment/operations/bosh-lite.yml \
  -v system_domain=bosh-lite.com \
  cf-deployment/cf-deployment.yml
