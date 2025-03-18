#!/usr/bin/env nextflow

include { SAMTOOLS_FASTQ } from './modules/local/samtools_fasta'
include { VGAN_EUKA } from './modules/local/vgan_euka'
include { PARSE_TAXONOMY } from './modules/local/parse_taxonomy'

import groovy.json.JsonSlurper
// load the files

ch_split = Channel.fromPath("${params.split}/*.bam", checkIfExists:true)
ch_euka_dir = Channel.fromPath("${params.euka_dir}", checkIfExists:true)
ch_taxonomy = Channel.fromPath("${params.taxonomy}", checkIfExists:true)

ch_versions = Channel.empty()

workflow {

  // add a fake meta
  ch_split.map{it -> [['sample': it.baseName, 'id':it.baseName], it] }.set{ ch_split }


  //
  // 1. Convert bam to fasta (for euka)
  //

  SAMTOOLS_FASTQ(ch_split)

  ch_fasta = SAMTOOLS_FASTQ.out.fastq
  ch_versions = ch_versions.mix(SAMTOOLS_FASTQ.out.versions.first())

  //
  // 2. Run euka
  //

  ch_fasta.combine(ch_euka_dir)
    .multiMap{ meta, fasta, eukadir -> 
      fasta: [meta, fasta]
      eukadir: eukadir
    }
    .set{ch_euka_input}

  VGAN_EUKA( ch_euka_input.fasta, ch_euka_input.eukadir )

  ch_fasta.combine(VGAN_EUKA.out.detected, by:0)
    .map{meta, fasta, detected ->
      [
        meta,
        detected.splitCsv(header:true, sep:'\t'),
        fasta,
      ]  
    }
    .transpose()
    .set{ch_results}

  //
  // 3. Parse Taxonomy
  //

  ch_results.map{meta, detected, fasta ->
    detected['#Taxa']
  }
  .collect()
  .map{it.toList().join(',')}
  .combine(ch_taxonomy)
  .multiMap{
    taxonomy: it[1]
    taxa: it[0]
  }
  .set{ch_taxonomy}

  PARSE_TAXONOMY(ch_taxonomy.taxonomy, ch_taxonomy.taxa)

  ch_taxonomy_json = PARSE_TAXONOMY.out.json

  def jsonSlurper = new JsonSlurper()
  ch_taxonomy_json.map{ json ->
      [jsonSlurper.parseText(file(json).text)]
  }.set{ json }

  ch_results_json = ch_results.combine(json)
    .branch{ meta,detected,fasta,json -> 
        valid_taxid: json.containsKey(detected["#Taxa"])
        invalid_taxid: !json.containsKey(detected["#Taxa"])
  }

  ch_extracted_fasta_valid = ch_results_json.valid_taxid.map{
    meta,detected,fasta,json ->
      [
          meta,
          detected,
          json[detected['#Taxa']],
      ]
  }
  
  //
  // 4. Create output-table
  //
  
ch_extracted_fasta_valid.collectFile(
  name: "final_report.tsv", 
  newLine:true, 
  sort:true,
  storeDir:'.',
  seed:[
      "RG",
      "FinalReads",
      "EukaTaxa",
      "Order",
      "Family",
    ].join("\t"), 
  ){
    [
      it[0].id,
      it[1]['Number_of_reads'],
      it[1]['#Taxa'],
      it[2]['order'],
      it[2]['family'],
    ].join('\t')
  }
}