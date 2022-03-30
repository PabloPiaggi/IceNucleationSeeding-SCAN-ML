#!/bin/bash
#SBATCH --ntasks=16              # total number of tasks across all nodes
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=4       # number of tasks across per node
#SBATCH --cpus-per-task=7        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=300M       # memory per cpu-core (4G is default)
#SBATCH --time=72:00:00          # total run time limit (HH:MM:SS)
#SBATCH --job-name="DP-pII-108" 
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
LAMMPS_EXE=/home/ppiaggi/Programs/Software-deepmd-kit-1.0/lammps-git4/src/lmp_mpi
source /home/ppiaggi/Programs/Software-deepmd-kit-1.0/tensorflow-venv/bin/activate
cycles=15
partitions=4
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
   mpirun -np $SLURM_NTASKS $LAMMPS_EXE -sf omp -partition ${partitions}x4 -in Restart.lmp
   #########################################################################
else
   #########################################################################
   # First run
   #########################################################################
   nn=1
   # Number of partitions
   export SLURM_WHOLE=1
   mpirun -np $SLURM_NTASKS $LAMMPS_EXE -sf omp -partition ${partitions}x4 -in start.lmp
   #########################################################################
fi
############################################################################


############################################################################
# Prepare next run
############################################################################
# Back up
############################################################################
for j in $(seq 0 3)
do
	cp log.lammps.${j} log.lammps.${j}.${nn}
	cp restart2.lmp.${j} restart2.lmp.${j}.${nn}
	cp restart.lmp.${j} restart.lmp.${j}.${nn}
	cp data.final.${j} data.final.${j}.${nn}
done

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
