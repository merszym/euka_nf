process VGAN_EUKA {
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/vgan:3.0.0--h9ee0642_0' :
        'quay.io/biocontainers/vgan:3.0.0--h9ee0642_0' }"
    tag "$meta.id"

    input:
    tuple val(meta), path(fasta)
    path(euka_dir)

    output:
    tuple val(meta), path("euka_output_*")           , emit: euka_out
    tuple val(meta), path("euka_output_detected.tsv"), emit: detected
    tuple val(meta), path("euka_output_5p.prof")     , emit: prof5
    tuple val(meta), path("euka_output_3p.prof")     , emit: prof3
    path "versions.yml"                              , emit: versions

    script:
    def args = task.ext.args ?: ''
    """
    vgan euka --euka_dir ${euka_dir} -fq1 ${fasta} $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vgan: \$(vgan version | cut -d' ' -f2)
    END_VERSIONS
    """
}