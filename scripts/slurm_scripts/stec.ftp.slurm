#!/bin/bash
#SBATCH --job-name=stec                             # name of the job submitted
#SBATCH -p short                                 # name of the queue you are submitting to
#SBATCH -N 1                                            # number of nodes in this job
#SBATCH -n 2                                           # number of cores/tasks in this job, you get all 20 cores with 2 threads per core with hyperthreading
#SBATCH -t 48:00:00                                      # time allocated for this job hours:mins:seconds
#SBATCH -o "stdout.%j.%N.%x"                               # standard out %j adds job number to outputfile name and %N adds the node name
#SBATCH -e "stderr.%j.%N.%x"                               # optional but it prints our standard error
#SBATCH --account fsepru
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kathy.mou@usda.gov

#Enter commands here:
wget -i stecftp.txt
