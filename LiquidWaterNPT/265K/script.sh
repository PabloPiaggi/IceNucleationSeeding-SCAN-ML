rm thermo2.out
for file in `ls -1v log.lammps.*`
do
	echo $file
	awk 'NF==12 && $1!="Section"' $file >> thermo2.out
done
sed '/Step/,+1 d' thermo2.out > thermo.out
rm thermo2.out
