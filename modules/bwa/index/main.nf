process BWAINDEX {
    label 'process_low'

    container "${params.singularity_cachedir}/bwa.0.7.17-r1188.sif"

    input:
    tuple val(batch), path(fa)

    output:
    tuple val(batch), path('*.fa'), path('*.sa'), path('*.amb'), path('*.ann'), path ('*.pac'), path ('*.bwt'), emit: index
    path ("versions.yml"),  emit: versions

    script:
    """
    # bwa index of final_assembly.fasta
    mv ${fa} _${fa}
    bwa index _${fa}


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwa: \$(bwa 2>&1 | grep Version | sed 's/Version: //')
    END_VERSIONS
    """
}
