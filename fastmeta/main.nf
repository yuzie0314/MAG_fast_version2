#!/usr/bin/env nextflow
/*
========================================================================================
    nf-core/metagenome
========================================================================================
    Github : https://github.com/nf-core/metagenome
    Website: https://nf-co.re/metagenome
    Slack  : https://nfcore.slack.com/channels/metagenome
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
========================================================================================
    GENOME PARAMETER VALUES
========================================================================================
*/

//params.fasta = WorkflowMain.getGenomeAttribute(params, 'fasta')

/*
========================================================================================
    VALIDATE & PRINT PARAMETER SUMMARY
========================================================================================
*/

WorkflowMain.initialise(workflow, params, log)

/*
========================================================================================
    NAMED WORKFLOW FOR PIPELINE
========================================================================================
*/

include { FASTMETA } from './workflows/fastmeta'

//
// WORKFLOW: Run main nf-core/metagenome analysis pipeline
//
workflow NFCORE_FASTMETA {
    FASTMETA ()
}

/*
========================================================================================
    RUN ALL WORKFLOWS
========================================================================================
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {
    NFCORE_FASTMETA ()
}

/*
========================================================================================
    THE END
========================================================================================
*/
