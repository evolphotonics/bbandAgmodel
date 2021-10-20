## Awk code to calculate the average spectral reflectivity/intensity. Files can be in any text/ASCII format, but must have the same number of rows and no headers.
## Author: Vinodkumar Saranathan (https://github.com/evolphotonics, August 2021)
## Usage: awk -f avg.awk *.txt > avg.dat
## This takes any and all '.txt' files as input and writes the result to 'avg.dat' as sepcified in the usage example above.
## Store this script within a folder containing the spectra files to be averaged, before running.

#BEGIN { cmd= "date +%s%N" ## start time
#cmd | getline t1
#close(cmd) }
{   sum[FNR" "2]+=$2  #for each wavelength (row), serially add the intensities (second column)  
    if(FNR==NR){lambda[FNR]=$1} ## store wavelength column once, as it doesn't change    
} END {for (i=1;i<=FNR;i++) {
    ## calculate the mean
    avg[i] = sum[i" "2]/(NR/FNR)
    print lambda[i]"\t"avg[i] >> avgfile
    }

    ## end time
    #cmd | getline t2
    #close(cmd)
    #print "time elapsed is "(t2-t1)/1000000000 " s"
} 
