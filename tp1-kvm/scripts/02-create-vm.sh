#!/usr/bin/env bash
# 02-create-vm.sh : créer une VM depuis une ISO (2 vCPU, 2 Gio, disque 15 Gio, VirtIO, NAT)
# Usage : ./02-create-vm.sh NOM_VM CHEMIN_ISO
# Exemple : ./02-create-vm.sh ubuntu-test01 /var/lib/libvirt/boot/ubuntu.iso
# Remarque : libvirt ne peut pas lire une ISO située dans /home (droits) ;
# le script la copie donc dans /var/lib/libvirt/boot si besoin.
set -euo pipefail

VM="${1:?Usage: $0 NOM_VM CHEMIN_ISO}"
ISO="${2:?Usage: $0 NOM_VM CHEMIN_ISO}"
IMGDIR="${IMGDIR:-/var/lib/libvirt/images}"
BOOTDIR="${BOOTDIR:-/var/lib/libvirt/boot}"
OSVAR="${OSVAR:-ubuntu24.04}"

sudo test -f "$ISO" || { echo "ISO introuvable : $ISO" >&2; exit 1; }

case "$ISO" in
  "$BOOTDIR"/*) ;;
  *)
    echo "Copie de l'ISO dans $BOOTDIR (accès libvirt)..."
    sudo cp -n "$ISO" "$BOOTDIR/"
    ISO="$BOOTDIR/$(basename "$ISO")"
    ;;
esac

sudo virt-install \
  --connect qemu:///system \
  --name "$VM" \
  --memory 2048 \
  --vcpus 2 \
  --disk path="$IMGDIR/$VM.qcow2",size=15,format=qcow2,bus=virtio \
  --cdrom "$ISO" \
  --network network=default,model=virtio \
  --channel unix,target_type=virtio,name=org.qemu.guest_agent.0 \
  --os-variant "$OSVAR" \
  --graphics vnc,listen=127.0.0.1 \
  --noautoconsole

echo "VM $VM créée. Suivre l'installation avec virt-manager ou virt-viewer."
