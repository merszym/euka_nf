# Analysis of sedimentary ancient DNA using BLAST and MEGAN

This repository contains a nextflow-based implementation of the BLAST+MEGAN-centered workflow described in Slon et al, 2017 to analyze ancient mitochondrial DNA (mtDNA) from archaeological sediments.

The pipeline was created to benchmark [quicksand](github.com/mpieva/quicksand), it is *NOT* the exact workflow described in Slon et al, 2017. I streamlined and updated some processes and output-files to make it more comparable to quicksand. Also the summary-table headers differ a bit.

## Documentation

The pipeline consists of 5 steps:

1. Reduce input sequences by removing identical duplicates (keep only the first). Keep only sequences that are seen at least twice (by default)
2. Run BLAST
3. RUN MEGAN and export all assigned reads on the family level
4. map the family-sequences against all genomes in the reference-database
5. filter, deduplicate and analyze the alignments for ancient DNA damage

### Run the pipeline

Run the pipeline with nextflow >= v22.10 and singularity installed.

```
nextflow run merszym/blastmegan_nf \
    --split DIR  
    --genomes DIR
    --database FASTA
    --acc2taxid ABIN
```

### Available Flags
```
--split     DIR     // a folder containing bam-files (required)
--database  PATH    // the fasta files used as BLAST database (required)
--acc2taxid PATH    // the MEGAN .abin file used for the taxonomy (required)
--genomes   DIR     // folder with reference genomes (use the quicksand-build genomes directory) (required)
--doublestranded    // calculate damage patterns based on C-T and G-A instead of only C-T (like in single stranded libs)

--pseudouniq_filterflag INT // samtools filter flag. 1=unpaired, 4=unmapped, 5=both. (default: 5)
--pseudouniq_minlen     INT // samtools length filter (default:35)
--pseudouniq_mindup     INT // keep reads that are duplicated at least N times (default: 2)

--rma_sup  INT    // blast2rma flag, min-support (default:3)
--rma_supp FLOAT  // blast2rma flag, min-support percent (default: 0.1)
--rma_ms   INT    // blast2rma flag, min-support (default:35)  

--mapbwa_quality_cutoff INT  // bwa minimal quality cutoff (default: 25)
--save_deaminated            // save the deaminated reads (term1 and term3)
```

### Acknowledgments

The pipeline was developed by [Frederic Romagne](https://github.com/frederic-romagne) and described in Slon et al. (2017).

> Viviane Slon et al., _Neandertal and Denisovan DNA from Pleistocene sediments._ Science356,605-608 (2017).[10.1126/science.aam9695](https://doi.org/10.1126/science.aam9695)
