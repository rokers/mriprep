#!/bin/bash
#SBATCH -n 1
#SBATCH -c 14
#SBATCH -a 1 # indicate number of subjects
#SBATCH -t 100:00:00

#subject=`sed "${SLURM_ARRAY_TASK_ID}q;d" subj.txt`
subject=$1
# *** load modules ***
module load singularity/3.8.3 braimcore/3.1

CDIR=`pwd`


# *** Set tmp working dir ***
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

# Needed if u downloaded the templates to a place other than $HOME/.cache/templateflow
export TEMPLATEFLOW_HOME=`cd ${STUDY_DIR}/../templateflow && pwd`

# To avoid fmriprep race condition processing multiple subjects in parallel
sleep 60

braimcore 	run \
		--nprocs 14 --omp-nthreads 14  \
        	${STUDY_DIR}/BIDS \
        	${STUDY_DIR}/derivatives \
        	participant \
        	--fs-license-file ${STUDY_DIR}/license.txt \
					--output-space T1w:res-native fsnative:den-41k MNI152NLin2009cAsym:res-native fsaverage:den-41k fsaverage\
        	--participant_label ${subject} \
        	--skip_bids_validation \
        	-w ${WORKDIR} \
        	--no-submm-recon

# remove workdir
# rm -rf ${WORKDIR}

echo "Braimcore Finished"
