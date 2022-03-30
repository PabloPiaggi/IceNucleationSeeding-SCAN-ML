index=$1
for file in `ls -1v log.lammps.${index}.*`
do
	echo $file
	awk 'NF==12 && $1!="Section" && $3!="I" && $1!="Step"' $file >> thermo.${index}.out
done
#sed '/Step/,+1 d' thermo2.out > thermo.out
#rm thermo2.out
