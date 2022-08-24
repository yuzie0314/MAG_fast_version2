process BMTAGGER  {
    label 'process_medium'

    container "${params.singularity_cachedir}/bmtagger.3.101.sif"
    
    input:
    tuple val(meta), path(reads)

    output:
    path("bmtagger.ratio.txt") , emit: ratio

    script:
    def args = task.ext.args ?: ''
    // Add soft-links to original FastQs for consistent naming in pipeline
    def prefix = task.ext.prefix ?: "${meta.id}"
    def ratio = 0

    """
    mkdir tmp
    bmtagger.sh -b ${params.bitmask} -x ${params.srprism} -T tmp -q 1 -o ${prefix}.blacklist -1 ${reads[0]} -2 ${reads[1]}
    total=`wc ${reads[0]} | awk \'{print \$1/4}\'`
    black=`wc ${prefix}.blacklist | awk '{print \$1}'` 
    ratio=`python -c "print(\$black / \$total)"`
    echo \$ratio > "bmtagger.ratio.txt"
    """    
}