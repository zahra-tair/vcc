#!/usr/bin/env bash
# 03-clone-vm.sh : cloner une VM arrêtée (clone complet, disque indépendant)
# Usage : ./03-clone-vm.sh VM_SOURCE NOM_CLONE
# Rappel : le clone garde hostname, machine-id et clés SSH hôte de la source.
# Il n'est donc pas un template : pour des identités distinctes, voir 04-create-template.sh.
set -euo pipefail

SRC="${1:?Usage: $0 VM_SOURCE NOM_CLONE}"
CLONE="${2:?Usage: $0 VM_SOURCE NOM_CLONE}"
IMGDIR="${IMGDIR:-/var/lib/libvirt/images}"

STATE="$(sudo virsh -c qemu:///system domstate "$SRC")"
if [ "$STATE" != "shut off" ]; then
  echo "La VM $SRC doit être arrêtée (état actuel : $STATE)." >&2
  exit 1
fi

sudo virt-clone --connect qemu:///system \
  --original "$SRC" --name "$CLONE" --file "$IMGDIR/$CLONE.qcow2"

echo "== Contrôles =="
echo "UUID source : $(sudo virsh -c qemu:///system domuuid "$SRC")"
echo "UUID clone  : $(sudo virsh -c qemu:///system domuuid "$CLONE")"
sudo virsh -c qemu:///system domiflist "$SRC"
sudo virsh -c qemu:///system domiflist "$CLONE"
sudo qemu-img info "$IMGDIR/$CLONE.qcow2"
