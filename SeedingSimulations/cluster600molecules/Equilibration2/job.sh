#!/bin/bash
#SBATCH --ntasks=16               # total number of tasks across all nodes
#SBATCH --ntasks-per-node=4         
#SBATCH --nodes=4         
#SBATCH --cpus-per-task=7        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=144:00:00          # total run time limit (HH:MM:SS)
#SBATCH --job-name="c600-Equil" 
#SBATCH --gres=gpu:4             # number of gpus per node

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export PLUMED_NUM_THREADS=$SLURM_CPUS_PER_TASK

pwd; hostname; date

module purge
module load rh/devtoolset/4
module load cudatoolkit/10.0
module load cudnn/cuda-10.0/7.6.3
module load openmpi/gcc/3.1.3/64

############################################################################
# Variables definition
############################################################################
LAMMPS_EXE=/home/ppiaggi/Programs/Software-deepmd-kit-1.0/lammps-git2/src/lmp_mpi
source /home/ppiaggi/Programs/Software-deepmd-kit-1.0/tensorflow-venv/bin/activate
cycles=1
############################################################################

############################################################################
# Run
############################################################################
if [ -e runno ] ; then
   #########################################################################
   # Restart runs
   #########################################################################
   nn=`tail -n 1 runno | awk '{print $1}'`
   export SLURM_WHOLE=1
   mpirun $LAMMPS_EXE -sf omp -in Restart.lmp
   #########################################################################
else
   #########################################################################
   # First run
   #########################################################################
   nn=1
   # Number of partitions
   export SLURM_WHOLE=1
   mpirun $LAMMPS_EXE -sf omp -in start.lmp
   #########################################################################
fi
############################################################################


############################################################################
# Prepare next run
############################################################################
# Back up
############################################################################
cp restart2.lmp restart2.lmp.${nn}
cp restart.lmp restart.lmp.${nn}
cp data.final data.final.${nn}

############################################################################
# Check number of cycles
############################################################################
mm=$((nn+1))
echo ${mm} > runno
#cheking number of cycles
if [ ${nn} -ge ${cycles} ]; then
  exit
fi
############################################################################

############################################################################
# Resubmitting again
############################################################################
sbatch < job.sh
############################################################################

date
