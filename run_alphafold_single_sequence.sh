#!/bin/bash
#SBATCH --account=asteen_1130
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=8
#SBATCH --nodes=1
#SBATCH --gres=gpu:p100:1
#SBATCH --mem=60GB
#SBATCH --time=02:00:00



# PART-ONE -> get input

##########
# Check if a file is passed as an argument
if [ $# -eq 0 ]; then
    echo "No FASTA file supplied. Please provide a FASTA file as an argument."
    exit 1
fi

# Input FASTA file
fasta_file="$1"
output_path="$2"


# Check if file exists
if [ ! -f "$fasta_file" ]; then
    echo "File not found!"
    exit 1
fi


structure_prediction_directory=${output_path}/result/
#############################
# PART-TWO
# START_ALPHFOLD
# start the alphafold2 main script
module purge
eval "$(conda shell.bash hook)"
conda activate /spack/conda/alphafold/

export TMPDIR=/scratch1/${USER}/tmp
python /spack/conda/alphafold/alphafold/run_alphafold.py \
                --fasta_paths=$fasta_file \
                --model_preset=monomer \
                --data_dir=/project/biodb/alphafold_data \
                --bfd_database_path=/project/biodb/alphafold_data/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt \
                --uniprot_database_path=/project/biodb/alphafold_data/uniprot/uniprot.fasta \
                --uniref90_database_path=/project/biodb/alphafold_data/uniref90/uniref90.fasta \
                --uniref30_database_path=/project/biodb/alphafold_data/uniref30/UniRef30_2021_03 \
                --pdb_seqres_database_path=/project/biodb/alphafold_data/pdb_seqres/pdb_seqres.txt \
                --mgnify_database_path=/project/biodb/alphafold_data/mgnify/mgy_clusters_2018_12.fa \
                --template_mmcif_dir=/project/biodb/alphafold_data/pdb_mmcif/mmcif_files/ \
                --obsolete_pdbs_path=/project/biodb/alphafold_data/pdb_mmcif/obsolete.dat \
                --max_template_date=2022-12-12 \
                --models_to_relax=best \
                --output_dir=$structure_prediction_directory/ \
                --use_gpu_relax=TRUE
