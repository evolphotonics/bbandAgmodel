## Awk code to calculate the standard deviation of the reflectivity/intensity of a number of spectra
## Author: Vinodkumar Saranathan (https://github.com/evolphotonics, August 2021)
## Usage: awk -v avgfile="avg.dat" -f sd.awk *.txt
## This code first takes in the average spectra of the same dataset calculated using 'avg.awk'and then the spectra files as input and writes the result to 'avgwsd.dat'

BEGIN { #cmd= "date +%s%N" ## start time
#cmd | getline t1
#close(cmd) 
n=1; while (getline < avgfile > 0) {lam[n]=$1; avg[n]=$2; n++} ## read in the average spectra from user-specified file
}
{ sqsum[FNR] += ($2-avg[FNR]) * ($2-avg[FNR]) ## sum of squared residuals        
} END {
    print "wl\tmean\tsd" >> "avgwsd.dat"
    
    ## calculate sample standard deviation
    for (i=1;i<=FNR;i++) {
       print lam[i]"\t"avg[i]"\t"sqrt(sqsum[i]/(NR/FNR - 1)) >> "avgwsd.dat"
    }
    
    ## end time
    #cmd | getline t2
    #close(cmd)
    #print "time elapsed is "(t2-t1)/1000000000 " s"
}
