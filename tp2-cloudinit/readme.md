# TP2 : Cloud-init et génération automatique de VM

## Objectif

Décrire des machines virtuelles dans un inventaire, leur associer des profils,
puis générer automatiquement les fichiers cloud-init et déployer les VM sur KVM.

Workflow : inventaire/vms.yaml + profils/*.yaml + templates/*.j2
→ scripts/generate.py → output/NOM_VM/ (user-data, meta-data, network-config, seed.img)
→ scripts/deploy.sh → VM Ubuntu sur KVM.

## Arborescence

    tp2-cloudinit/
    ├── images/        image de base (template du TP1), non versionnée
    ├── cloud-init/    exemples de fichiers cloud-init (user-data, meta-data, network-config)
    ├── profils/       web.yaml, database.yaml, admin.yaml
    ├── templates/     user-data.j2, meta-data.j2, network-config.j2
    ├── inventaire/    vms.yaml
    ├── scripts/       generate.py, deploy.sh
    ├── output/        fichiers générés par generate.py, non versionnés
    └── readme.md

## Prérequis

- KVM/libvirt installé (voir tp1-kvm/)
- Image de base ubuntu-template-v1.qcow2 (créée au TP1), placée dans
  /var/lib/libvirt/images/ ou dans images/
- Python 3 avec Jinja2 et PyYAML :
  python3 -m venv .venv && . .venv/bin/activate && pip install Jinja2 PyYAML
- genisoimage (installé par tp1-kvm/scripts/01-install-kvm.sh)
- Une clé SSH : ssh-keygen -t ed25519 -N "" -f ~/.ssh/bd2c_tp2
  (autre chemin possible avec la variable SSH_PUBKEY_FILE)

## Utilisation

    cd tp2-cloudinit
    python3 scripts/generate.py     # génère output/NOM_VM/
    bash scripts/deploy.sh          # crée et démarre les VM sur KVM
    sudo virsh -c qemu:///system list --all

Connexion : ssh -i ~/.ssh/bd2c_tp2 etudiant@IP_DE_LA_VM
(l'IP s'obtient avec : sudo virsh -c qemu:///system domifaddr NOM_VM)

## Inventaire

Chaque VM de inventaire/vms.yaml a : nom, hostname, profil, username, cpu, ram (Mo), os.
Chaque profil de profils/ définit les packages, le service à activer et le role.

## Points d'attention

- output/ et images/ ne sont pas versionnés (fichiers générés ou volumineux).
- Aucune clé privée n'est dans le dépôt : seule la clé publique est injectée dans user-data.
- deploy.sh ignore une VM qui existe déjà (même nom).
