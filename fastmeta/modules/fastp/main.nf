process FASTP {
    label 'process_medium'

    container "${params.singularity_cachedir}/fastp.0.23.2.sif"
    
    input:
    tuple val(meta), path(reads)

    output:
    path("fastp.stats.csv"), emit: fastp

    script:
    def args = task.ext.args ?: ''
    // Add soft-links to original FastQs for consistent naming in pipeline
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    fastp -i ${reads[0]} -I ${reads[1]} -h ${prefix}.html -w 6
    mv fastp.json ${prefix}.fastp.json 
    fastp2table.py -fastp . -output .
    """    
}
