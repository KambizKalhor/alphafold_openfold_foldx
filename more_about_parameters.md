# The parameters needed to run Alpha Fold are:

ALPHAFOLD_DATA_PATH: Absolute path to folder with databases.

ALPHAFOLD_MODELS: Absolute path to folder with models.

pwd: Path to Singularity Image File (SIF) file.

fasta_paths: Path to the input sequence in fasta format.

uniref90_database_path: Path to Uniref90 database for use by JackHMMER.

mgnify_database_path: Path to the MGnify database for use by JackHMMER.

bfd_database_path: Path to the BFD database for use by HHblits.

uniclust30_database_path: Path to Uniclust30 database for use by HHblits.

pdb70_database_path: Path to PDB70 database for use by HHsearch.

template_mmcif_dir_ Path to a directory with template mmCIF structures, each named <pdb_id>.cif.

uniprot_database_path Path to the UniProt database for AlphaFold Multimer.

obsolete_pdbs_path: Path to a file mapping obsolete PDB IDs to their replacements.

max_template_date: Maximum template release date to consider (ISO-8601 format - i.e. YYYY-MM-DD). Important if folding historical test sets. Default is None.

output_dir: Path to a directory that will store the results.

model_preset: [‘monomer’, ‘monomer_casp14’, ‘monomer_ptm’, ‘multimer’]. Control which AlphaFold model use, choosing between the original model used at CASP14 with no ensembling (monomer), the original model used at CASP14 with num_ensemble=8, matching our CASP14 configuration (monomer_casp14), the original CASP14 model fine tuned with the pTM head, providing a pairwise confidence measure (‘monomer_ptm’) and the AlphaFold-Multimer model (‘multimer’), to use this model, provide a multi-sequence FASTA file.

db_preset: [‘reduced_dbs’, ‘full_dbs’, ‘casp14’]. Choose preset model configuration - no ensembling and smaller genetic database config (reduced_dbs), no ensembling and full genetic database config (full_dbs) or full genetic database config and 8 model ensemblings (casp14). Default is full_dbs.

benchmark: [True, False]. Run multiple JAX model evaluations to obtain a timing that excludes the compilation time, which should be more indicative of the time required for inferencing many proteins. Default is False.
