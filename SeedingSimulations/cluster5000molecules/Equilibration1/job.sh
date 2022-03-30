#!/bin/bash
#BSUB -P CHP115
#BSUB -W 2:00
#BSUB -nnodes 20
#BSUB -J Equil
#BSUB -o jobout.%J
#BSUB -e jobout.%J

module load cuda/10.1.243
module load gcc/7.4.0
module load cmake/3.18.2
module load ibm-wml-ce/1.6.2-3 

export OMP_NUM_THREADS=7

date
lammps_exe=/ccs/home/ppiaggi/Programs/Software-deepmd-kit-1.0/lammps-git/src/lmp_mpi
jsrun -n 120 -a 1 -c 7 -g 1 -bpacked:7 $lammps_exe -sf omp -in start.lmp
