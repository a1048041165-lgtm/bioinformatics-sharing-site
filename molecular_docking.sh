#!/bin/bash
# Molecular docking script extracted from Notion (personal names removed)

# Convert SDF to PDB using OpenBabel
/home/ubuntu/work/biosoft/mgltools/mgltools_x86_64Linux2_1.5.7/obabel ZINC000000058172.sdf -O caffeic.acid.pdb

# Activate AutoDock Vina environment
source activate /home/ubuntu/work/biosoft/miniconda3/envs/vina

# Prepare the receptor (requires ADFRsuite)
prepare_receptor -r 1iep_receptorH.pdb -o 1iep_receptor.pdbqt

# Run docking using Vina forcefield (no affinity maps)
vina --receptor 1iep_receptor.pdbqt --ligand 1iep_ligand.pdbqt \
  --config 1iep_receptor_vina_box.txt \
  --exhaustiveness 32 \
  --out 1iep_ligand_vina_out.pdbqt

# Content of the config file (1iep_receptor_vina_box.txt)
center_x=15.190
center_y=53.903
center_z=16.917
size_x=20.0
size_y=20.0
size_z=20.0

# Batch processing script
wd='/home/ubuntu/work/parsley/cyp450/docking/test'
source activate /home/ubuntu/work/biosoft/miniconda3/envs/vina

for i in *pdb; do
  dir=${i%%-*}
  mkdir "$dir"
  cd "$dir"
  # Prepare receptor for each protein
  prepare_receptor -r ../"$i" -o "${dir}.pdbqt"
  # Generate GPF file for ligand
  pythonsh /home/ubuntu/work/biosoft/autodock-vina/AutoDock-Vina/example/autodock_scripts/prepare_gpf.py \
    -l /home/ubuntu/work/parsley/cyp450/docking/Methoxyeugenol.pdbqt \
    -r "${dir}.pdbqt" -y
  # Run AutoGrid
  autogrid4 -p *.gpf -l "${dir}.glg"
  cd ..
done < deseq.mfuzz.list

# Docking loop using Vina (AD4 scoring)
while IFS= read -r i; do
  dir=${i%%-*}
  cd "$dir"
  echo "Results of $i"
  /home/ubuntu/work/biosoft/autodock-vina/vina_1.2.5_linux_x86_64 \
    --ligand /home/ubuntu/work/parsley/cyp450/docking/Methoxyeugenol.pdbqt \
    --maps "$dir" \
    --scoring ad4 \
    --exhaustiveness 32 \
    --out "${dir}_ad4_out.pdbqt"
  cd ..
done < deseq.mfuzz.list
