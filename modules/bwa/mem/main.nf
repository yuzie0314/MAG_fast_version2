process BWAMEM {
    label 'process_medium'

    container "${params.singularity_cachedir}/bwa.0.7.17-r1188.sif"

    input:
    tuple val(batch), val(meta), path(r1), path(r2), path(fasta), path(sa), path(amb), path(ann), path(pac), path(bwt)   
    
    output:
    tuple val(batch), val(meta), path('*.bam'), path('*.bai')       , emit: bam
    path ("versions.yml")                                , emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    Read_Group_ID = "@RG\\tID:${prefix}\\tSM:${prefix}\\tPL:Illumina"   
    """
    # bwa mem alignment
    bwa mem -v 1 -t ${task.cpus} ${fasta} ${r1} ${r2} > ${prefix}.sam
    samtools sort -T ./tmp -@ ${task.cpus} -O BAM -o ${prefix}.bam ${prefix}.sam
    samtools index ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(samtools  2>&1 | grep Version | sed 's/Version: //' | sed 's/ (.*)//')
    END_VERSIONS
    """
}
