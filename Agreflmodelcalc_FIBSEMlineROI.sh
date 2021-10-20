## BASH shell code to calculate the theoretical normal reflectivity of a 3-layer silver scale ultrastructure. The layer thicknesses are specified by the line ROI measurements from a scale FIB-SEM image in FIJI, passed here as a tab-delimited text file.
## Author: Vinodkumar Saranathan (https://github.com/evolphotonics, October 2021)
## Usage: sh Agreflmodelcalc_FIBSEMlineROI.sh FWSilver_lineROImeasurements.txt

#!/bin/bash

infile=$1 ## command line parameter

## In order to perform hierarchical modeling, where 1, 2 or all 3 parameters are varied, just set the other parameter(s) to a constant value below

## upper lamina
#ul=(56)  ##FW Ag 
#ul=(64)  ##FW Gland Ag
#ul=(76)  ##HW Gray
#ul=(83)  ##HW Ag
#ul=(120) ##HW Coupling

## air gap/lumen layer
#gap=(1044) ##FW Ag
#gap=(1420) ##FW Gland AG
#gap=(819)  ##HW Gray
#gap=(1069) ##HW AG
#gap=(1223) ##HW Coupling

## lower lamina
#ll=(69)  ##FW Ag 
#ll=(81)  ##FW Gland Ag
#ll=(83)  ##HW Gray
#ll=(67)  ##HW Ag 
#ll=(105) ##HW Coupling

## Coefficient of Variation
#CV= #(0.08) (0.14) (0.07) ##FW Ag
#CV= #(0.13) (0.10) (0.12) ##FW Gland Ag
#CV= #(0.23) (0.14) (0.13) ##HW Gray
#CV= #(0.11) (0.17) (0.14) ##HW Ag
#CV= #(0.17) (0.28) (0.24) ##HW Coupling

count=1 ## counter start
extension=txt ## for output file name
suffix=e-9 ## for nanometer
 
runfs () {
   local i=$1
   local j=$2
   local k=$3
   local fname=$4
   
   ## increment and run Freesnell by passing the clparams as cl-arguments
   clparamul=$(echo $i$suffix)   #"$i"
   clparamgap=$(echo $j$suffix)  #"$j"
   clparamll=$(echo $k$suffix)   #"$k"
   
   ## append direct output to dev null for speed
   /usr/local/bin/scm -v -f BanySilver.scm $clparamul $clparamgap $clparamll $fname > /dev/null 2>&1 
   
   ## run verbosely by uncommenting the next line
   #echo "done with step $count"; 
}


## code to read in the measured line ROI layer parameters, line by line from input file, and run Free Snell
while read line
do 
  ## comment out any 1 or 2 of the following three lines and set the corresponding parameters to a constant value above, in order to create hierarchical models
  ul=(`echo $line | awk -F ' ' '{print $1}'`)
  gap=(`echo $line | awk -F ' ' '{print $2}'`)
  ll=(`echo $line | awk -F ' ' '{print $3}' | sed 's/\r$//'`) ## strip carriage return for the last column, otherwise bad things happen

  num_procs=100 ## number of concurrent jobs  -- adjust according to your computer hardware specs
  num_jobs="\j"  ## The prompt escape for number of jobs currently running
  while (( ${num_jobs@P} >= num_procs )); do
	# echo "waiting for job" ${num_jobs@P}
	wait ## wait before starting any more jobs
  done

  ## run each loop iteration in parallel
  runfs "$ul" "$gap" "$ll" "$count" &

  ## increment counter
  count=$((count+1))
done<$infile

exit 0
