# AlphaFold output
The outputs will be in a subfolder of output_dir. They include the computed MSAs, unrelaxed structures, relaxed structures, ranked structures, raw model outputs, prediction metadata, and section timings. The output_dir directory will have the following structure:

```
....├── input/
           ├── features.pkl
           ├── ranked_{0,1,2,3,4}.pdb
           ├── ranking_debug.json
           ├── relaxed_model_{1,2,3,4,5}.pdb
           ├── result_model_{1,2,3,4,5}.pkl
           ├── timings.json
           ├── unrelaxed_model_{1,2,3,4,5}.pdb
           └── msas/
                 ├── bfd_uniclust_hits.a3m
                 ├── mgnify_hits.sto
                 └── uniref90_hits.sto
```

The contents of each output file are as follows:

features.pkl: A pickle file containing the input feature NumPy arrays used by the models to produce the structures.

unrelaxed_model_x.pdb: A PDB format text file containing the predicted structure, exactly as outputted by the model.

relaxed_model_x.pdb: A PDB format text file containing the predicted structure, after performing an Amber relaxation procedure on the unrelaxed structure prediction (see Jumper et al. 2021, Suppl. Methods 1.8.6 for details).

ranked_x.pdb: A PDB format text file containing the relaxed predicted structures, after reordering by model confidence. Here ranked_0.pdb should contain the prediction with the highest confidence, and ranked_4.pdb the prediction with the lowest confidence. To rank model confidence, we use predicted LDDT (pLDDT) scores (see Jumper et al. 2021, Suppl. Methods 1.9.6 for details).

ranking_debug.json: A JSON format text file containing the pLDDT values used to perform the model ranking, and a mapping back to the original model names.

timings.json: A JSON format text file containing the times taken to run each section of the AlphaFold pipeline.

msas/: - A directory containing the files describing the various genetic tool hits that were used to construct the input MSA.

result_model_x.pkl: A pickle file containing a nested dictionary of the various NumPy arrays directly produced by the model. In addition to the output of the structure module, this includes auxiliary outputs such as:

Distograms (distogram/logits contains a NumPy array of shape [N_res, N_res, N_bins] and distogram/bin_edges contains the definition of the bins).

Per-residue pLDDT scores (plddt contains a NumPy array of shape [N_res] with the range of possible values from 0 to 100, where 100 means most confident). This can serve to identify sequence regions predicted with high confidence or as an overall per-target confidence score when averaged across residues.

Present only if using pTM models: predicted TM-score (ptm field contains a scalar). As a predictor of a global superposition metric, this score is designed to also assess whether the model is confident in the overall domain packing.

Present only if using pTM models: predicted pairwise aligned errors (predicted_aligned_error contains a NumPy array of shape [N_res, N_res] with the range of possible values from 0 to max_predicted_aligned_error, where 0 means most confident). This can serve for a visualisation of domain packing confidence within the structure.
