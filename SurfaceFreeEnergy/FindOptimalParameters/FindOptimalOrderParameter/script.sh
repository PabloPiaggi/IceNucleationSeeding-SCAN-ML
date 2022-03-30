module purge
module load rh/devtoolset/4
module load openmpi/gcc/3.1.3/64

source /home/ppiaggi/Programs/Software-deepmd-kit-1.0/plumed2-git/sourceme.sh

for i in `seq 0.05 0.0025 0.08`
do
        for phase in IceIh Liquid
        do
                cd $phase
                sed "s/replace/$i/g" plumed-base.dat > plumed.dat
                timeout 10 plumed --no-mpi driver --plumed plumed.dat --mf_dcd dump.dcd > /dev/null
                cd ../
        done
        echo $i
        python script.py
        #gnuplot plot.gpi
        for phase in IceIh Liquid
        do
                cd $phase
                rm COLVAR histo* analysis.*
                cd ../
        done
done
