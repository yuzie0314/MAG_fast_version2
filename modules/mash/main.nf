process MASH {
    label 'process_medium'
    container "${params.singularity_cachedir}/mash.4.4.3.sif"
    publishDir = [
            path: { "${params.mash_reads}" },
            mode: params.publish_dir_mode,
            pattern: '*sig'
        ]
    
    input:
    tuple val(meta), path(reads), val(pass)

    output:
    path("*reads.sig"), emit: mash

    script:
    def args = task.ext.args ?: ''
    // Add soft-links to original FastQs for consistent naming in pipeline
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    trim-low-abund.py -C 3 -Z 18 -V -M 2e9 ${reads[0]} ${reads[1]}
    sourmash sketch dna -p scaled=1000,k=21,k=31,k=51 *.fastq.abundtrim --merge ${prefix} -o ${prefix}-reads.sig
    """    
}
