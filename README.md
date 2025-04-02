# Analysis of sedimentary ancient DNA using euka

This repository contains a nextflow-based implementation of a euka-centered workflow to analyze ancient mitochondrial DNA (mtDNA) from archaeological sediments.

The pipeline was created to benchmark [quicksand](github.com/mpieva/quicksand). I created this pipeline to analyze multiple files with euka in parallel and create a minimal report-file.

## Documentation

The pipeline consists of 4 steps:

1. Deduplicate BAM (by sequence)
2. Convert BAM to FASTQ
3. Run euka
4. Normalize taxonomy (report order and family)

### Run the pipeline

Run the pipeline with nextflow >= v22.10 and singularity installed.

```
nextflow run merszym/euka_nf \
    --split DIR  
    --euka_dir DIR
    --taxonomy FASTA
    -profile singularity
```

### Available Flags
```
--split     DIR     // a folder containing bam-files (required)
--euka_dir  DIR     // the folder containing the euka database (required)
--taxonomy  DIR     // a folder containig the names.dmp and nodes.dmp files from NCBI (required)
```

### References

See the euka tool 

> Nicola Vogel et al., _euka: Robust tetrapodic and arthropodic taxa detection from modern and ancient environmental DNA using pangenomic reference graphs._ Methods in Ecology and Evolution, 14, 2717–2727 (2023).[10.1111/2041-210X.14214](https://doi.org/10.1111/2041-210X.14214)
