#!/usr/bin/env bash
# 04-create-template.sh : créer un template généralisé à partir d'une VM source ARRÊTÉE
# Usage : ./04-create-template.sh VM_SOURCE NOM_TEMPLATE
# Exemple : ./04-create-template.sh ubuntu-vm01 ubuntu-template
# Prérequis (dans la VM source, avant de l'arrêter) : cloud-init installé et configuré
# (datasource NoCloud, fichiers de l'installateur supprimés, cloud-init clean --logs --seed).
# La source n'est jamais modifiée : on travaille sur une copie.
set -euo pipefail

SRC="${1:?Usage: $0 VM_SOURCE NOM_TEMPLATE}"
NAME="${2:?Usage: $0 VM_SOURCE NOM_TEMPLATE}"
IMGDIR="${IMGDIR:-/var/lib/libvirt/images}"
PREUVES="${PREUVES:-$HOME/tp1-kvm/preuves}"
DISK="$IMGDIR/$SRC.qcow2"
TEMPLATE="$IMGDIR/$NAME.qcow2"

STATE="$(sudo virsh -c qemu:///system domstate "$SRC")"
[ "$STATE" = "shut off" ] || { echo "Arrêter $SRC d'abord (état : $STATE)." >&2; exit 1; }
sudo test -f "$DISK" || { echo "Disque introuvable : $DISK" >&2; exit 1; }
sudo test ! -e "$TEMPLATE" || { echo "Le template existe déjà : $TEMPLATE" >&2; exit 1; }

mkdir -p "$PREUVES"
sudo qemu-img convert -p -f qcow2 -O qcow2 "$DISK" "$TEMPLATE"

sudo virt-sysprep -a "$TEMPLATE" \
  --operations machine-id,ssh-hostkeys,udev-persistent-net,logfiles,tmp-files,bash-history

sudo qemu-img check -f qcow2 "$TEMPLATE"
sudo qemu-img info "$TEMPLATE"
sudo sha256sum "$TEMPLATE" | tee "$PREUVES/$NAME.sha256"
