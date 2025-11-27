#!/bin/bash
# Molecular docking workflow extracted from Notion (sensitive info removed)

# Activate AutoDock Vina environment
source activate /path/to/conda/envs/vina

# Prepare the receptor (creates PDBQT file)
prepare_receptor -r 1iep_receptorH.pdb -o 1iep_receptor.pdbqt

# Prepare the ligand using meeko
mk_prepare_ligand.py -i 1iep_ligand.sdf -o 1iep_ligand.pdbqt

# Alternative: convert SDF to PDB and prepare ligand using ADFRsuite
# obabel ZINC000000058172.sdf -O caffeic.acid.pdb
# prepare_ligand -l Methoxyeugenol.pdb -o Methoxyeugenol.pdbqt

# Generate affinity maps for AutoDock force field
pythonsh /path/to/autodock_scripts/prepare_gpf.py -l 1iep_ligand.pdbqt -r 1iep_receptor.pdbqt -y
