#!/bin/bash
#SBATCH --job-name=ppanggolin                             # name of the job submitted
#SBATCH -p short                                    # name of the queue you are submitting to
#SBATCH -N 1                                            # number of nodes in this job
#SBATCH -n 16                                           # number of cores/tasks in this job, you get all 20 cores with 2 threads per core with hyperthreading
#SBATCH -t 48:00:00                                      # time allocated for this job hours:mins:seconds
#SBATCH -o "stdout.%j.%N.%x"                               # standard out %j adds job number to outputfile name and %N adds the node name
#SBATCH -e "stderr.%j.%N.%x"                               # optional but it prints our standard error
#SBATCH --mem=32G   # memory
#SBATCH --account fsepru
#SBATCH --mail-user=kathy.mou@usda.gov
#SBATCH --mail-type=ALL
#Enter commands here:
set -e
set -u
set +eu
module load miniconda
source activate /project/fsepru/conda_envs/ppanggolin
ppanggolin workflow --anno Ecoligbk.txt
ppanggolin write -p pangenome.h5 --families_tsv --output gene_families

#End of file
