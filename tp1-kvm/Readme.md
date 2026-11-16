# TP1 : KVM

Premier TP du projet Virtualisation et Cloud Computing (Master BD2C, FSAC, 2026/2027).
Il pose les bases : installer KVM/libvirt, créer des VM depuis une ISO, les cloner, puis figer une VM de référence en template.

Environnement : Ubuntu 24.04 LTS, architecture x86_64.

## Arborescence

    tp1-kvm/
    ├── iso/          images d'installation (non versionnées)
    ├── images/       disques des VM (non versionnés)
    ├── templates/    templates généralisés (non versionnés)
    ├── scripts/
    │   ├── 01-install-kvm.sh        installer et contrôler KVM/libvirt
    │   ├── 02-create-vm.sh          créer une VM depuis une ISO
    │   ├── 03-clone-vm.sh           cloner une VM arrêtée
    │   ├── 04-create-template.sh    fabriquer un template généralisé
    │   └── 05-manage-vm.sh          gérer les VM (liste, état, démarrage, arrêt...)
    └── Readme.md

## Fichiers non versionnés

Les ISO, les disques `.qcow2` et les templates pèsent plusieurs Go. Ils sont exclus du dépôt par le fichier `.gitignore` (limite de 100 Mo par fichier sur GitHub).
Sur la machine du TP, libvirt stocke les disques dans `/var/lib/libvirt/images/` et les ISO dans `/var/lib/libvirt/boot/`.
Aucune clé privée ni secret n'est présent dans le dépôt.

## Prérequis

- Ubuntu 24.04 avec virtualisation matérielle activée (extensions vmx ou svm)
- droits `sudo`
- l'ISO `ubuntu-24.04.4-live-server-amd64.iso`, téléchargée depuis https://ubuntu.com/download/server

## Utilisation

    chmod +x scripts/*.sh

    # 1. installer et contrôler KVM/libvirt
    ./scripts/01-install-kvm.sh

    # 2. créer une VM depuis l'ISO
    ./scripts/02-create-vm.sh ubuntu-vm01 /var/lib/libvirt/boot/ubuntu.iso

    # 3. arrêter la VM, puis la cloner
    ./scripts/05-manage-vm.sh shutdown ubuntu-vm01
    ./scripts/03-clone-vm.sh ubuntu-vm01 ubuntu-vm02

    # 4. fabriquer un template à partir de la VM de référence (arrêtée)
    ./scripts/04-create-template.sh ubuntu-vm01 ubuntu-template

    # 5. administrer les VM
    ./scripts/05-manage-vm.sh list
    ./scripts/05-manage-vm.sh state ubuntu-vm01

Les scripts utilisent `/var/lib/libvirt/images/` pour les disques. Ce dossier peut être changé avec la variable `IMGDIR`.

## Points d'attention

- Un clone (`03-clone-vm.sh`) garde le hostname, le machine-id et les clés SSH hôte de sa source : ce n'est pas un template.
- `04-create-template.sh` généralise une copie du disque avec `virt-sysprep` (machine-id, clés SSH hôte, journaux, historique). La VM source n'est jamais modifiée.
- libvirt ne peut pas lire une ISO placée dans `/home` : `02-create-vm.sh` la copie dans `/var/lib/libvirt/boot/` si besoin.
- Le template est la base du TP2 (cloud-init) : ses images de base sont copiées dans `tp2-cloudinit/images/`.
