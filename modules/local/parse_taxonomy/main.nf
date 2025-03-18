process PARSE_TAXONOMY{
    container (workflow.containerEngine ? "pypy:3" : null)
    label 'local'
    label "process_low"

    input:
    path(taxonomy)
    val(taxa)

    output:
    path("taxonomy.json"), emit: json
    path "versions.yml"  , emit: versions

    script:
    """
    parse_taxonomy.py ${taxonomy}/nodes.dmp ${taxonomy}/names.dmp ${taxa} > taxonomy.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pypy: \$(pypy3 --version | tail -1 | cut -d ' ' -f2)
    END_VERSIONS
    """
}