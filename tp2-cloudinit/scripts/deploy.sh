#!/usr/bin/env bash
# deploy.sh : déploie sur KVM chaque VM générée par generate.py (dossier output/).
# Usage : bash scripts/deploy.sh
# Variable optionnelle : BASE_IMAGE=/chemin/vers/template.qcow2
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMGDIR=/var/lib/libvirt/images
V="sudo virsh -c qemu:///system"

if [ -z "${BASE_IMAGE:-}" ]; then
  if [ -f "$ROOT/images/ubuntu-template-v1.qcow2" ]; then
    BASE_IMAGE="$ROOT/images/ubuntu-template-v1.qcow2"
  else
    BASE_IMAGE="$IMGDIR/ubuntu-template-v1.qcow2"
  fi
fi
sudo test -f "$BASE_IMAGE" || { echo "Image de base introuvable : $BASE_IMAGE" >&2; exit 1; }

shopt -s nullglob
CONFS=("$ROOT"/output/*/vm.conf)
[ ${#CONFS[@]} -gt 0 ] || { echo "Rien à déployer : lancez d'abord scripts/generate.py" >&2; exit 1; }

for conf in "${CONFS[@]}"; do
  dir="$(dirname "$conf")"
  # shellcheck disable=SC1090
  . "$conf"

  if $V dominfo "$VM_NAME" >/dev/null 2>&1; then
    echo "== $VM_NAME existe déjà : ignorée"
    continue
  fi

  case "$VM_OS" in
    ubuntu) OSVAR=ubuntu24.04 ;;
    *)      OSVAR=linux2022 ;;
  esac

  echo "== Déploiement de $VM_NAME (cpu=$VM_CPU ram=$VM_RAM)"
  sudo qemu-img convert -f qcow2 -O qcow2 "$BASE_IMAGE" "$IMGDIR/$VM_NAME.qcow2"
  sudo cp "$dir/seed.img" "$IMGDIR/$VM_NAME-seed.img"

  sudo virt-install --connect qemu:///system \
    --name "$VM_NAME" \
    --memory "$VM_RAM" --vcpus "$VM_CPU" \
    --import \
    --disk path="$IMGDIR/$VM_NAME.qcow2",format=qcow2,bus=virtio \
    --disk path="$IMGDIR/$VM_NAME-seed.img",device=cdrom \
    --network network=default,model=virtio \
    --channel unix,target_type=virtio,name=org.qemu.guest_agent.0 \
    --os-variant "$OSVAR" \
    --graphics vnc,listen=127.0.0.1 \
    --noautoconsole
done

echo
$V list --all
