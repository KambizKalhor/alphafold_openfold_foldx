#!/bin/bash
#SBATCH --account=asteen_1130
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=8
#SBATCH --nodes=1
#SBATCH --gres=gpu:p100:1
#SBATCH --mem=60GB
#SBATCH --time=00:30:00
#SBATCH --array=1-2



#####################
# PART-ZERO -> inputs

# Initialize variables (some are optional parameters)
fasta_file=""; output_path=""; executable_foldx_file_path="/home1/kkalhor/important_basic_files/foldx_v5"; temperature=""; PH=""; ionStrength=""; g=""; h=""; i=""; j=""


# Parse parameters
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --fasta_file) fasta_file="$2"; shift ;;
        --output_path) output_path="$2"; shift ;;
        --executable_foldx_file_path) executable_foldx_file_path="$2"; shift ;;
        --temperature) temperature="$2"; shift ;;
        --PH) PH="$2"; shift ;;
        --ionStrength) ionStrength="$2"; shift ;;
        --g) g="$2"; shift ;;
        --h) h="$2"; shift ;;
        --i) i="$2"; shift ;;
        --j) j="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Print the arguments to verify (if provided)
echo "fasta_file: ${fasta_file:-"not provided"}"
echo "output_path: ${output_path:-"not provided"}"
echo "executable_foldx_file_path: $executable_foldx_file_path"
echo "temperature: ${temperature:-"not provided"}"
echo "PH: ${PH:-"not provided"}"
echo "ionStrength: ${ionStrength:-"not provided"}"
echo "g: ${g:-"not provided"}"
echo "h: ${h:-"not provided"}"
echo "i: ${i:-"not provided"}"
echo "j: ${j:-"not provided"}"



#####################
# PART-ONE -> separate the fasta file to multiple fasta files and make directory for each of them
# we have a multiple big fasta file as first argument
# we also have a directory to save all results as second argument


# Check if file exists
if [ ! -f "$fasta_file" ]; then
    echo "File not found!"
    exit 1
fi

# Read the FASTA file line by line
while read -r line; do
    if [[ $line == ">"* ]]; then
        # It's a FASTA identifier
        identifier=$(echo "$line" | sed 's/>//')  # Remove ">"

        # Sanitize the identifier to replace problematic characters with underscores
        sanitized_identifier=$(echo "$identifier" | sed 's/[\/\\:*?"<>| ]/_/g')

        # Create a directory with the sanitized identifier name
        mkdir -p "$output_path/50_openfold_3D_structure/$sanitized_identifier"

        # Define the output file path inside the new directory
        output_file="$output_path/50_openfold_3D_structure/$sanitized_identifier/${sanitized_identifier}.fasta"

        # Write the identifier to the output file
        echo "$line" > "$output_file"
    else
        # It's a sequence, append it to the current output file
        echo "$line" >> "$output_file"
    fi
done < "$fasta_file"

echo "FASTA file processed successfully."





#####################
# PART-TWO

# find all fasta files in directory and create appropriate input for alphafold
# Find all files with .fasta extension and save their full paths to the output file, each on a new line
find "$output_path" -type f -name "*.fasta" > "$output_path/list_of_paths.txt"


#############################
echo "job started"
echo "this is job ${SLURM_ARRAY_TASK_ID}"
#############################

# now make a variable to feed as input to main script
line=$(sed -n -e "$SLURM_ARRAY_TASK_ID p" "$output_path/list_of_paths.txt")
structure_prediction_directory=$(dirname "${line}")

#############################
# ALL PATHS
# path to fasta	file
echo "line"
echo $line

# path to main output folder (ex: resluts)
echo "output_path"
echo $output_path

# directory to save structure prediction results
echo "structure_prediction_directory"
echo $structure_prediction_directory
############################

start_time=$(date +%s) # Start time in seconds since epoch
echo $start_time


#############################
# PART-THREE
# START_OPENFOLD
# start the openfold main script
module purge
module load usc
unset LD_PRELOAD
export TMPDIR=/scratch1/${USER}/tmp
singularity exec --nv --bind /project,/scratch1,/home1 /spack/singularity/hpc/openfold.sif \
 python3 /opt/openfold/run_pretrained_openfold.py  \
 --use_single_seq_mode \
 --cpu 12 \
 --output_dir $structure_prediction_directory \
 --preset full_dbs  \
 --uniref90_database_path /project/biodb/alphafold_data/uniref90/uniref90.fasta  \
 --jax_param_path /project/biodb/alphafold_data/params/params_model_1.npz \
 --hhsearch_binary_path hhsearch  \
 --jackhmmer_binary_path jackhmmer  \
 --hhblits_binary_path hhblitz  \
 --hmmbuild_binary_path hmmbuild  \
 --kalign_binary_path kalign  \
 --max_template_date 2020-01-01  \
 --bfd_database_path /project/biodb/alphafold_data/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt  \
 --mgnify_database_path /project/biodb/alphafold_data/mgnify/mgy_clusters_2018_12.fa  \
 --pdb70_database_path /project/biodb/alphafold_data/pdb70/pdb70  \
 --pdb_seqres_database_path /project/biodb/alphafold_data/pdb_seqres/pdb_seqres.txt  \
 --uniprot_database_path /project/biodb/alphafold_data/uniprot/uniprot.fasta \
 --model_device cuda:0 \
 $structure_prediction_directory \
 /project/biodb/alphafold_data/pdb_mmcif/mmcif_files










#############################
# PART-FOUR
# START_FOLDX
# load needed modules
module purge
module load gcc/12.3.0
module load libnl/3.3.0


basename=$(basename "$structure_prediction_directory")
foldx_directory=$output_path/51_FoldX/$basename
mkdir -p $foldx_directory

# then copy the executable in in
cp -r $executable_foldx_file_path/. $foldx_directory

# copy the pdb files in the new path, next to executable file
pdb_file=$(find "$(pwd)/$structure_prediction_directory" -type f -name "*_relaxed.pdb" -print -quit)
cp $pdb_file $foldx_directory/${basename}_relaxed_protein.pdb

# run foldX
cd $foldx_directory
./foldx_20241231 --command=Stability --temperature $temperature --pH $PH --pdb ${basename}_relaxed_protein.pdb --output-file "${basename}_output.fxout" > "${basename}_foldx_log.txt"


rm ${foldx_directory}/foldx_20241231






end_time=$(date +%s) # End time in seconds since epoch

# Calculate and print the execution time
execution_time=$((end_time - start_time))
echo "Execution Time: $execution_time seconds"

