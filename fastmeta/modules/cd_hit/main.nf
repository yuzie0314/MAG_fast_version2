process CDHITEST {
    label 'process_medium'

    container "${params.singularity_cachedir}/cd_hit.4.8.1.sif"
    
    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.cluster.fastq") , emit: fastq

    script:
    def args = task.ext.args ?: ''
    // Add soft-links to original FastQs for consistent naming in pipeline
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    # cd-hit-est -i ${prefix}_1.fastq -j ${prefix}_2.fastq -o ${prefix}_1.cluster.fastq -op ${prefix}_2.cluster.fastq -c ${params.cd_hit_identity} -n 10 -r 1 –aS 0.5 -b 2 -G 0 -M ${params.cd_hit_m} -sf 1 -T ${params.cd_hit_t} -P 1
    head -40000 ${reads[0]} > ${prefix}_1.cluster.fastq
    head -40000 ${reads[1]} > ${prefix}_2.cluster.fastq
    """    
}
