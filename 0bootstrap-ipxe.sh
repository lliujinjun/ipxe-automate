#!/bin/sh

mkdir vagrant/
cd vagrant/

vagrant init bento/ubuntu-20.04
vagrant up
ssh -o StrictHostKeyChecking=no -i .vagrant/machines/default/parallels/private_key vagrant@$(prlctl list -f | grep $(cat .vagrant/machines/default/parallels/action_provision | awk -F ':' '{print $2}') | awk '{print $3}')
scp -o StrictHostKeyChecking=no -i .vagrant/machines/default/parallels/private_key ../scripts/install-ipxe.sh vagrant@$(prlctl list -f | grep $(cat .vagrant/machines/default/parallels/action_provision | awk -F ':' '{print $2}') | awk '{print $3}'):
ssh -o StrictHostKeyChecking=no -i .vagrant/machines/default/parallels/private_key vagrant@$(prlctl list -f | grep $(cat .vagrant/machines/default/parallels/action_provision | awk -F ':' '{print $2}') | awk '{print $3}') /home/vagrant/install-ipxe.sh
