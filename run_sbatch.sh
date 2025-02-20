#!/bin/bash
#SBATCH --partition=gpulongd       # Name of the partition you will use
#SBATCH --account=asml-gpu         # Associated account
#SBATCH --job-name=go_athena       # Job name
#SBATCH --time=520:00:00           # Maximum time for the job (in hours)

# Show job information for easier debugging
echo "Job ID: $SLURM_JOB_ID"
echo "Running on node: $(hostname)"
echo "Allocated GPU(s): $CUDA_VISIBLE_DEVICES"

# Execute the Singularity container with GPU support and run the setup script
singularity exec --nv Singularity.sif python test.py
