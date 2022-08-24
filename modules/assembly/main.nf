process ASSEMBLY {
    label 'process_assembly'
    container "${params.singularity_cachedir}/meta_assembly.0.0.1.sif"

    input:
    tuple val(batch), path(r1),  path(r2)
    val(assembler)

    output:
    tuple val(batch), path("*.fa")       , emit: assembly
    path "versions.yml"    , emit: versions

    script:
    if (assembler == 'metaspades')
    """  
    # https://github.com/bxlab/metaWRAP/blob/master/bin/metawrap-modules/assembly.sh
    cat *_1.fastq > ALL_READS_R1.fastq
    cat *_2.fastq > ALL_READS_R2.fastq
    output=${batch}.fa
    metaspades.py --tmp-dir ./metaspades.tmp -t 20 -m 90 -o ./metaspades -1 ALL_READS_R1.fastq -2 ALL_READS_R2.fastq  
    rm_short_contigs.py ${params.min_len} ./metaspades/scaffolds.fasta  > \$output

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaspades: \$(metaspades.py -v | sed -e "s/SPAdes genome assembler v//g" | sed -e "s/ \\[metaSPAdes mode\\]//g")
    END_VERSIONS
    """
    else if(assembler == 'megahit')
    """ 
    cat *_1.fastq > ALL_READS_R1.fastq
    cat *_2.fastq > ALL_READS_R2.fastq
    output=${batch}.fa
    mkdir megahit.tmp
    megahit -1 ALL_READS_R1.fastq -2 ALL_READS_R2.fastq -o ./megahit --tmp-dir ./megahit.tmp -t 20 -m 50000000000 --continue    
    fix_megahit_contig_naming.py ./megahit/final.contigs.fa ${params.min_len} > \$output
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        megahit: \$( megahit --version | sed -e "s/MEGAHIT v//g" )
    END_VERSIONS
    """
}
