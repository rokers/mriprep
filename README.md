# mriprep
Preprocessing of MRI data acquired at NYUAD to run the scripts in this project to perform the preprocessing of the structural and fMRI data based on the data from xnat 

1. Perform the dcm2bids step on xnat - http://xnat.abudhabi.nyu.edu

TODO: currently dcm2bids needs to be run on each participant individually. Amr/Ameen need to update, so that it runs in the project level. 
TODO: get CLI command from Amr/Ameen to download BIDS data from XNAT - [https://github.com/bids-standard/bids-validator](https://www.notion.so/rokerslab/XNAT-CLI-Download-Setup-51d4a3425fd1462590303f9e4fa41610?pvs=4)
   
3. Download the BIDS converted data to your local machine


4. Correct locations and directories related to the project in dcm2bids_setup.m

   for example:
   case {'Abdalla'}
    user='/Users/azm9155/';
    projectDir = [user,'Desktop/Ambl'];
    githubDir = '~/Documents/MATLAB/Visual_studies/GitHub';
    freesurferDir = '/Applications/freesurfer/7.4.1';
    fslDir = '/usr/local/fsl';
    configfilePath = [user,'Documents/GitHub/nyuad_mr_pipeline/config_20230918.json'];

6. once you correct this part, you need to run "dcm2bids_run.m", but before you run it, you need to choose which step to run by
    Dounzip=0; % 1 means run this step, 0 means do no run this step
    Dodcm2bids=0;
    DoFixsBref=1;
    DoCorrectJson=1;
    DoValidateBids=1; % make sure you have validatebids installed on your computer. 

Upto this point, you have got the data in BIDS structure, and you need to move it to the HPC computer (e.g. Jubail) to run fMRI prep. 
It is very importantant to have enough # of files on your account as fMRIprep will run and will generate a large number of files. 

To run fMRI prep, you need to edit the following section in the file called "run_fmriprep_41k_array.sh"

            WORKDIR=/scratch/azm9155/Retinotopy/work/$subject/${SLURM_ARRAY_TASK_ID}
            
            # *** Set BRAIMCORE_ENGINE in case not using -e option ***
            export BRAIMCORE_ENGINE=fmriprep
            #
            # *** Grab a particular subject
            
            #
            # *** DEFINE VARIABLES ***
            #
            #export SUBJECT_ID=${subject}
            export SUBJECT_ID=$1
            export SUBJECTS_DIR=/scratch/azm9155/Retinotopy/derivatives/freesurfer
            export STUDY_DIR=/scratch/azm9155/Retinotopy

Once edited, to run this script, you need to call it by 
sbatch run_fmriprep_41k_array.sh <subject_ID>
For example for subject sub-0419, You will call this function as 
sbatch run_fmriprep_41k_array.sh 0149
