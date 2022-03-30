rm thermo2.out
for file in `ls -1v slurm-*`
do
	echo $file
	awk 'NF==12 && $1!="Section" && $3!="I" && $1!="Step"' $file >> thermo2.out
done
sed '/Step/,+1 d' thermo2.out > thermo.out
rm thermo2.out
