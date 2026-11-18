#!/usr/bin/env python3
"""generate.py : génère, pour chaque VM de l'inventaire, les fichiers cloud-init.

Entrées : inventaire/vms.yaml, profils/<profil>.yaml, templates/*.j2
Sorties : output/<nom>/user-data, meta-data, network-config, vm.conf, seed.img
La clé publique SSH est lue dans ~/.ssh/bd2c_tp2.pub (variable SSH_PUBKEY_FILE pour la changer).
"""
import os
import shlex
import subprocess
import sys
from pathlib import Path

import yaml
from jinja2 import Environment, FileSystemLoader

root = Path(__file__).resolve().parent.parent
inventory = yaml.safe_load((root / "inventaire/vms.yaml").read_text())
env = Environment(
    loader=FileSystemLoader(root / "templates"),
    autoescape=False,
    trim_blocks=True,
    lstrip_blocks=True,
    keep_trailing_newline=True,
)

key_file = Path(os.environ.get("SSH_PUBKEY_FILE", Path.home() / ".ssh/bd2c_tp2.pub"))
if not key_file.is_file():
    sys.exit(f"Clé publique introuvable : {key_file} (variable SSH_PUBKEY_FILE)")
key = key_file.read_text().strip()

for vm in inventory["vms"]:
    profile = yaml.safe_load((root / "profils" / f"{vm['profil']}.yaml").read_text())
    context = {**vm, **profile, "ssh_public_key": key}
    target = root / "output" / vm["nom"]
    target.mkdir(parents=True, exist_ok=True)

    for name in ("user-data", "meta-data", "network-config"):
        text = env.get_template(f"{name}.j2").render(**context)
        yaml.safe_load(text)  # contrôle de syntaxe YAML
        (target / name).write_text(text)

    conf = {"VM_NAME": vm["nom"], "VM_CPU": vm["cpu"], "VM_RAM": vm["ram"], "VM_OS": vm["os"]}
    (target / "vm.conf").write_text("".join(f"{k}={shlex.quote(str(v))}\n" for k, v in conf.items()))

    subprocess.run(
        ["genisoimage", "-quiet", "-output", str(target / "seed.img"), "-volid", "cidata",
         "-joliet", "-rock", "user-data", "meta-data", "network-config"],
        cwd=target, check=True,
    )
    print(target)
