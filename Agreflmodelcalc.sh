## BASH shell code to calculate the theoretical normal reflectivity of a 3-layer silver scale ultrastructure. The scale layer thickness parameters can be varied one at a time, any two or all three simultaneously.
## Author: Vinodkumar Saranathan (https://github.com/evolphotonics, August-October 2021)
## Usage: sh Agreflmodelcalc.sh midul midgap midll CVul CVgap CVll [N]

#!/bin/bash

## Instead of hard coding, the scale thickness parameters for each scale type are passed as command line arguments (see usage)

## upper lamina
#ll=(56)  ##FW Ag 
#ul=(64)  ##FW Gland Ag
#ul=(76)  ##HW Gray
#ul=(83)  ##HW Ag
#ul=(120) ##HW Coupling
#midul="$(seq -s ' ' 0.001 5 501)" ## varying ul from 0 to 300 nm
midul=$1 

## air gap/lumen layer
#gap=(1044) ##FW Ag
#gap=(1420) ##FW Gland AG
#gap=(819)  ##HW Gray
#gap=(1069) ##HW AG
#gap=(1223) ##HW Coupling
#midgap="$(seq -s ' ' 0.001 20 2001)" ## varying air gap from 0 to 2000 nm
midgap=$2

## lower lamina
#ll=(69)  ##FW Ag 
#ll=(81)  ##FW Gland Ag
#ll=(83)  ##HW Gray
#ll=(67)  ##HW Ag 
#ll=(105) ##HW Coupling
#midll="$(seq -s ' ' 0.001 5 501)" ## varying ul from 0 to 500 nm
midll=$3  

## Coefficient of Variation
#CV= #(0.08) (0.14) (0.07) ##FW Ag
#CV= #(0.13) (0.10) (0.12) ##FW Gland Ag
#CV= #(0.23) (0.14) (0.13) ##HW Gray
#CV= #(0.11) (0.17) (0.14) ##HW Ag
#CV= #(0.17) (0.28) (0.24) ##HW Coupling
CVul=$4
CVgap=$5
CVll=$6

## Sample size
if [ $7 -ge 0 ];
then
   N=$7
else
   N=200
fi

count=1 ## counter start
extension=txt ## for output file name
suffix=e-9 ## for nanometer
 
runfs () {
   local i=$1
   local j=$2
   local k=$3


   ## increment and run Freesnell by passing the clparams as cl-arguments
   clparamul=$(echo $i$suffix)   #"$i"
   clparamgap=$(echo $j$suffix)  #"$j"
   clparamll=$(echo $k$suffix)   #"$k"

   ## append direct output to dev null for speed
   /usr/local/bin/scm -v -f BanySilver.scm $clparamul $clparamgap $clparamll $i-$j-$k.$extension > /dev/null 2>&1 
   
   ## run verbosely by uncommenting the next line
   #echo "done with step $count"; 
}

## We use the well known trick to average 3 uniform distributions to get a nearly normal distribution (See http://www.johndcook.com/blog/2009/02/12/sums-of-uniform-random-values/)

## generate the normally distributed upper lamina values to average over
#ul=$(for i in $(seq 1 $N) ; do awk -v seed=$RANDOM 'BEGIN{srand(seed); rdm=(((rand()*2)-1)+((rand()*2)-1)+((rand()*2)-1)); print (rdm*'"$CVul"'*'"$m"'+'"$m"')}'; done)
if (( $(echo "$CVul > 0" |bc -l) )); ## Do only if the upper lamina layer thickness varies
then
uavg=0 ## initialize
tol=5 ## tolerance of distribution mean from desired value, in nm
while (( $(echo "$midul $uavg $tol" |  awk '{print (sqrt(($1 - $2)^2) > $3)}') )) ## we shouldn't need this loop, but just in case
    do
	echo "$(for i in $(seq 1 $N) ; do awk -v seed=$RANDOM 'BEGIN{srand(seed); rdm=(((rand()*2)-1)+((rand()*2)-1)+((rand()*2)-1)); print (rdm*'"$CVul"'*'"$midul"'+'"$midul"')}'; done)" > ul
	uavg="$(awk '{sum+=$0} END { print sum/NR}'  ul)"
    done;
ul="$(cat ul)"
else
ul=$midul
fi

## generate the normally distributed air gap values to average over
#gap=$(for i in $(seq 1 $N) ; do awk -v seed=$RANDOM 'BEGIN{srand(seed); rdm=(((rand()*2)-1)+((rand()*2)-1)+((rand()*2)-1)); print (rdm*'"$CVgap"'*'"$m"'+'"$m"')}'; done)
if (( $(echo "$CVgap > 0" |bc -l) )); ## Do only if the air gap layer thickness varies
then
gavg=0 ## initialize
tol=5 ## tolerance of distribution mean from desired value, in nm
while (( $(echo "$midgap $gavg $tol" |  awk '{print (sqrt(($1 - $2)^2) > $3)}') )) ## we shouldn't need this loop, but just in case
    do
	echo "$(for i in $(seq 1 $N) ; do awk -v seed=$RANDOM 'BEGIN{srand(seed); rdm=(((rand()*2)-1)+((rand()*2)-1)+((rand()*2)-1)); print (rdm*'"$CVgap"'*'"$midgap"'+'"$midgap"')}'; done)" > gap
	gavg="$(awk '{sum+=$0} END { print sum/NR}'  gap)"
done;
gap="$(cat gap)"
else
gap=$midgap
fi

## generate the normally distributed lower lamina values to average over
#ll=$(for i in $(seq 1 $N) ; do awk -v seed=$RANDOM 'BEGIN{srand(seed); rdm=(((rand()*2)-1)+((rand()*2)-1)+((rand()*2)-1)); print (rdm*'"$CVll"'*'"$m"'+'"$m"')}'; done)
if (( $(echo "$CVll > 0" |bc -l) )); ## Do only if the lower lamina layer thickness varies
then
uavg=0 ## initialize
tol=5 ## tolerance of distribution mean from desired value, in nm
while (( $(echo "$midll $uavg $tol" |  awk '{print (sqrt(($1 - $2)^2) > $3)}') )) ## we shouldn't need this loop, but just in case
    do
	echo "$(for i in $(seq 1 $N) ; do awk -v seed=$RANDOM 'BEGIN{srand(seed); rdm=(((rand()*2)-1)+((rand()*2)-1)+((rand()*2)-1)); print (rdm*'"$CVll"'*'"$midll"'+'"$midll"')}'; done)" > ll
	uavg="$(awk '{sum+=$0} END { print sum/NR}'  ll)"
done;
ll="$(cat ll)"
else
ll=$midll
fi


## changing parameters simultaneously - if any of them are constant, then the corresponding for loop is only executed once
for i in ${ul[@]}; do for j in ${gap[@]}; do for k in ${ll[@]}; do 

	num_procs=100 ## number of concurrent jobs -- adjust according to your computer hardware specs
	num_jobs="\j"  ## The prompt escape for number of jobs currently running
	while (( ${num_jobs@P} >= num_procs )); do
		wait ## wait before starting any more jobs
	done

	## run each loop iteration in parallel
	runfs "$i" "$j" "$k" "$count" &

	## increment counter
	count=$((count+1)) 
 
done;
done;
done;


num_jobs="\j"  ## The prompt escape for number of jobs currently running
while (( ${num_jobs@P} > 0 )); do
	# echo "waiting for job" ${num_jobs@P}
	wait; ## for jobs to finish
done

## First calculate average spectra
awk -v avgfile="avg.dat" -f avg.awk *.txt

## Then calculate standard deviation of spectra
awk -v avgfile="avg.dat" -f sd.awk *.txt

## post processing/cleanup
rm *.txt
rm avg.dat
mv avgwsd.dat $midul"_"$midgap"_"$midll"_"$CVul"_"$CVgap"_"$CVll"_"$N"_avg.dat" ## a more meaningful and unique name for the result

exit 0
