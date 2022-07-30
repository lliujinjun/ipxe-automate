#!/bin/sh

cd vagrant/
vagrant destroy -f
cd ..
rm -rf vagrant/

prlctl stop archops --kill
prlctl delete archops
