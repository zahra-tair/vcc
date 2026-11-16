#!/usr/bin/env bash
# 05-manage-vm.sh : administrer une VM (cycle de vie et informations)
# Usage : ./05-manage-vm.sh ACTION [NOM_VM]
# Actions : list | info | start | shutdown | destroy | state | ip | blk | net | xml
set -euo pipefail

ACTION="${1:-}"
VM="${2:-}"
V="sudo virsh -c qemu:///system"

need_vm() { [ -n "$VM" ] || { echo "Nom de VM manquant." >&2; exit 1; }; }

case "$ACTION" in
  list)     $V list --all ;;
  info)     need_vm; $V dominfo "$VM" ;;
  start)    need_vm; $V start "$VM" ;;
  shutdown) need_vm; $V shutdown "$VM" ;;   # arrêt propre
  destroy)  need_vm; $V destroy "$VM" ;;    # arrêt brutal (ne supprime pas le disque)
  state)    need_vm; $V domstate "$VM" ;;
  ip)       need_vm; $V domifaddr "$VM" --source agent || $V net-dhcp-leases default ;;
  blk)      need_vm; $V domblklist "$VM" ;;
  net)      need_vm; $V domiflist "$VM" ;;
  xml)      need_vm; $V dumpxml "$VM" ;;
  *) echo "Usage: $0 {list|info|start|shutdown|destroy|state|ip|blk|net|xml} [NOM_VM]" >&2; exit 1 ;;
esac
