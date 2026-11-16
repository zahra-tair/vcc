#!/usr/bin/env bash
# 01-install-kvm.sh : installer et contrôler KVM/QEMU/libvirt (Ubuntu 24.04)
set -euo pipefail

echo "== Extensions de virtualisation du CPU (vmx = Intel, svm = AMD) =="
grep -Eoc '(vmx|svm)' /proc/cpuinfo || true

echo "== Installation des paquets =="
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients virtinst \
  libguestfs-tools qemu-utils genisoimage

echo "== Démarrage de libvirt =="
sudo systemctl enable --now libvirtd

echo "== Contrôles =="
ls -l /dev/kvm
lsmod | grep kvm || true
command -v virsh virt-install qemu-img virt-sysprep genisoimage
sudo virsh -c qemu:///system list --all
sudo virsh -c qemu:///system net-list --all
