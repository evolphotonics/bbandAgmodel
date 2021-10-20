## BASH shell code to perform parameter sweeps by varying one layer parameter at a time and calculate the corresponding normal reflectance for a 3-layer scale ultrastructure.
## Author: Vinodkumar Saranathan (https://github.com/evolphotonics, August 2021)
## Usage: sh Aglayeropt.sh

#!/bin/bash

## Comment in/out the relevant layer thickness parameters for each scale type, as needed. Currently, they are set for varying the air gap layer thickness from 0 to 2 um while keeping upper and lower lamina thickness constant, for a hind-wing silver scale.

## upper lamina
#ul=(56)  ##FW Ag 
#ul=(64)  ##FW Gland Ag
#ul=(76)  ##HW Gray
ul=(83)  ##HW Ag
#ul=(120) ##HW Coupling
#midul="$(seq -s ' ' 0.001 5 501)" ## varying ul from 0 to 300 nm

## air gap/lumen layer
#gap=(1044) ##FW Ag
#gap=(1420) ##FW Gland AG
#gap=(819)  ##HW Gray
#gap=(1069) ##HW AG
#gap=(1223) ##HW Coupling
midgap="$(seq -s ' ' 0.001 20 2001)" ## varying air gap from 0 to 2000 nm

#"$(seq -s ' ' 1 2 200)"
#CV= #(0.08) (0.14) (0.07) ##FW Ag
#CV= #(0.13) (0.10) (0.12) ##FW Gland Ag
#CV= #(0.23) (0.14) (0.13) ##HW Gray
CV=(0.17) #(0.11) (0.17) (0.14) ##HW Ag
#CV= #(0.17) (0.28) (0.24) ##HW Coupling

## lower lamina
#ll=(69)  ##FW Ag 
#ll=(81)  ##FW Gland Ag
#ll=(83)  ##HW Gray
ll=(67)  ##HW Ag 
#ll=(105) ##HW Coupling
#midll="$(seq -s ' ' 0.001 5 501)" ## varying ul from 0 to 500 nm

N=(100) ##No of samples
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


#for m in ${midul[@]}; do
for m in ${midgap[@]}; do
#for m in ${midll[@]}; do

	## We use the well known trick to average 3 uniform distributions to get a nearly normal distribution (See http://www.johndcook.com/blog/2009/02/12/sums-of-uniform-random-values/)
	
	## generate the normally distributed upper lamina values to average over
	#ul=$(for i in $(seq 1 $N) ; do awk -v seed=$RANDOM 'BEGIN{srand(seed); rdm=(((rand()*2)-1)+((rand()*2)-1)+((rand()*2)-1)); print (rdm*'"$CV"'*'"$m"'+'"$m"')}'; done)

	## generate the normally distributed air gap values to average over
	gap=$(for i in $(seq 1 $N) ; do awk -v seed=$RANDOM 'BEGIN{srand(seed); rdm=(((rand()*2)-1)+((rand()*2)-1)+((rand()*2)-1)); print (rdm*'"$CV"'*'"$m"'+'"$m"')}'; done)

	## generate the normally distributed lower lamina values to average over
	#ll=$(for i in $(seq 1 $N) ; do awk -v seed=$RANDOM 'BEGIN{srand(seed); rdm=(((rand()*2)-1)+((rand()*2)-1)+((rand()*2)-1)); print (rdm*'"$CV"'*'"$m"'+'"$m"')}'; done)


	## changing params simultaneously
	for i in ${ul[@]}; do for j in ${gap[@]}; do for k in ${ll[@]}; do 

		num_procs=100 ## number of concurrent jobs
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
	awk -v avgfile=$m".dat" -f avg.awk *.txt

	## Then calculate standard deviation of spectra
	#awk -v avgfile=$m".dat" -f sd.awk *.txt
	
	## cleanup
	rm *.txt
done;


## Post processing: calculate the mean broadband reflectivity for each thickness parameter value and write it to a file for plotting
ls *.dat | while read filename ; do awk '{sum+=$2} END { print FILENAME"\t"sum/NR}' $filename ; done > Aglayeropt_avg.dat

exit 0
