#!/bin/sh

BASEBOX="archops"

prlctl create "$BASEBOX" --ostype other
prlctl set "$BASEBOX" \
  --cpus 12 \
  --memsize 16384 \
  --device-bootorder "hdd0 net0" --bios-type efi64 
prlctl set "$BASEBOX" \
  --device-set hdd0 --size 524288 --iface sata
prlctl set "$BASEBOX" --device-del fdd0
prlctl set "$BASEBOX" --device-del cdrom0
prlctl start "$BASEBOX"
