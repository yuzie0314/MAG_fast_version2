/*
========================================================================================
    VALIDATE INPUTS 
    nextflow run nf-core-metagenome/main.nf -profile singularity --input samplesheet.csv --outdir subworkflow --genome hg38 --metaspades true --skip_trimming false --skip_annotation false --skip_quant false --removehost true --additional_metaassembly true  -resume 
========================================================================================
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowFastmeta.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.input ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }

/*
========================================================================================
    CONFIG FILES
========================================================================================
*/

ch_multiqc_config        = file("$projectDir/assets/multiqc_config.yaml", checkIfExists: true)
ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath(params.multiqc_config) : Channel.empty()

/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { INPUT_CHECK } from '../subworkflows/local/input_check'
include { FASTQ_QC } from '../subworkflows/local/fastq_qc'

/*
========================================================================================
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { MASH } from '../modules/mash/main'

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

// Info required for completion email and summary

workflow FASTMETA {

    INPUT_CHECK (
        ch_input
    )

    ch_input_check_reads = INPUT_CHECK.out.reads
    
    FASTQ_QC (
        ch_input_check_reads
    )

    ch_fastp = FASTQ_QC.out.ch_fastp
    ch_bmtagger = FASTQ_QC.out.ch_bmtagger

    ch_fastp
    .map { 
        stats -> 
        pass = WorkflowFastmeta.processFastp(params, stats) 
    }.set { ch_fastp_pass }
        
    ch_bmtagger
    .map { 
        ratio -> 
        pass = WorkflowFastmeta.processBmtagger(params, ratio) 
    }.set { ch_bmtagger_pass }

    
    ch_fastp_bmtagger_pass = ch_fastp_pass
    .combine(ch_bmtagger_pass)
    .map { fastp_pass, bmtagger_pass -> if ((fastp_pass == "PASS") && (bmtagger_pass == "PASS")) [ "PASS" ]}
    //.ifEmpty{ exit 1, "can't pass q30 and host ratio"}
    //.view()
    
    ch_input_check_reads
    .combine(ch_fastp_bmtagger_pass)
    .set { ch_input_check_reads_pass }
    //.view()
    MASH (
        ch_input_check_reads_pass
    )

}


/*
========================================================================================
    COMPLETION EMAIL AND SUMMARY
========================================================================================
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
}

/*
========================================================================================
    THE END
========================================================================================
*/
