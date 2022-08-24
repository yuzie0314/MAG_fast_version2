//
// FASTQ QC STEPS
//

include { CDHITEST } from '../../modules/cd_hit/main'
include { FASTP } from '../../modules/fastp/main'
include { BMTAGGER } from '../../modules/bmtagger/main'

workflow FASTQ_QC {
    take:
    reads            // channel: [ val(meta), [ reads ] ]


    main:

    CDHITEST ( reads ).fastq.set { ch_cd_hit_est }
    FASTP ( ch_cd_hit_est ).fastp.set { ch_fastp }
    BMTAGGER ( ch_cd_hit_est ).ratio.set { ch_bmtagger }



    emit:
    ch_fastp
    ch_bmtagger
}
