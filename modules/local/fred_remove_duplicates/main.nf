process FRED_PSEUDOUNIQ{
    container (workflow.containerEngine ? "merszym/bam_deam:nextflow" : null)
    tag "${meta.id}"
    label 'local'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${meta.sample}.noPCRdups.bam"), path("${meta.id}.pseudouniq_stats.txt"), emit: pseudouniq

    script:
    def args = task.ext.args ?: ''
    """
    fred_remove_dups.py ${bam} ${meta.sample}.noPCRdups.bam $args > ${meta.id}.pseudouniq_stats.txt
    """
}