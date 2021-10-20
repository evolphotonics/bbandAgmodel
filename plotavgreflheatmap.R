#' ---
#' title: "Systematic parameter sweeps of FreeSnell reflectance predictions"
#' author: "Vinod Saranathan (https://github.com/evolphotonics)"
#' date: "August-October 2021"
#' output:
#'   pdf_document:
#'     highlight: default
#'     toc: false
#'     number_sections: true
#' ---
#' 
#' In this document, all R output is prefaced by "##" and R codes are in highlighted blocks.
#' 
#' 
#' First, let's reset R. Always a good idea before starting!!
rm(list = ls())
graphics.off()
#' 
#' Load the required libraries:
require(pavo)
require(knitr)
library(RColorBrewer)
#require(rgl)
#opts_chunk$set(tidy.opts=list(width.cutoff=950))
#opts_chunk$set(fig.align = 'center', fig.show = 'hold',out.width = "5cm")
options(width=100)
opts_chunk$set(comment = "##", prompt=FALSE, warning = TRUE, error=TRUE, 
               message = TRUE, tidy = FALSE, size="normalsize", highlight=TRUE,
               background='#22FF23', cache=TRUE, strip.white=TRUE) 

## ------------------------------------------------------------------------
#' Change this line below to set the working directory, according to where you have stored the files on your computer.
#' Organize the spectra in each folder into subfolders.
## ------------------------------------------------------------------------
#'First set the working directory either here:
##getwd() #get current working directory
setwd("/path/to/your/files")

## ------------------------------------------------------------------------
files = dir(path=".",pattern = "*.dat",recursive = TRUE)

numfiles <- length(files)
spec <- vector(mode="numeric", length=0);#temporary spec data variable
buttspec <- array(0,dim=c(1199,0));

for (i in 1:numfiles) {
  #read in data as tab-delimited and skipping header lines, if any
  spec <- read.table(paste(files[i],sep="/"), sep="\t",skip=0, comment.char = ">",header = FALSE)  
  specname <- gsub("llopt/","",gsub("ulopt/","",gsub(".dat","",gsub("gapopt/","",files[i])))) #gsub finds and replaces any containing folder names with ''   
  
  ## plot the spectra for each thickness as we read them in
  #colnames(spec) <- c("wl", specname)
  #plot(spec[spec$wl>xlowerlim & spec$wl<950,5],ylab="Reflectance")  
  #title(specname)
  #readline(prompt="Press [enter] to continue") #to read in one by one
  
  buttspec <- cbind(buttspec, spec[1:1199,2])  
  colnames(buttspec)[ncol(buttspec)] <- specname
}

#'now add the wavelength bins as the first column
#buttspec <- cbind(spec[1:2047,1],buttspec)
buttspec <- data.frame("wl" = spec[1:1199,1]/1e-9,buttspec) #convert from m to nm
#buttspec <- as.data.frame(na.exclude(buttspec),row.names = NULL) #remove NAs
#buttspec <- procspec(as.rspec(buttspec, lim = c(xlowerlim,950)), opt='smooth', span = 0.05)

#reorder
buttspec <- buttspec[c(1,order(as.numeric(substr(colnames(buttspec)[-1],2,10)))+1)]

#' (un)comment the next two lines as appropriate
N <- 5 #layer thickness increment (in nm) for upper/lower lamina
#N <- 20 #layer thickness increment (in nm) for air gap (lumen)

pal <- colorRampPalette(brewer.pal(10, "Blues"))(10)
hotmetal <- colorRampPalette(c('black','red','yellow','white'))(20)
cols <- spec2rgb(as.rspec(buttspec,lim=c(300,700),whichwl = 1))
names(cols) <- NULL
plot(as.rspec(buttspec,whichwl = 1,lim=c(350,700)), type = 's', col = cols, lwd = 4)#, labels.stack = "")
plot(as.rspec(buttspec,whichwl = 1,lim=c(350,700)), type = 'h', varying = seq(0,ncol(buttspec)-2,1)*N, las = 2, useRaster=TRUE, 
     ylab = "layer thickness (nm)", col=rev(pal))


#' reset plot window
par(mfrow = c(1,1))


## ------------------------------------------------------------------------
#' To debug, try running (a few) line(s) at a time and/or comment out the next three lines
#rgl.close() #close 3D graphics
#graphics.off()# close all other graphics
#cat("\014") #clear the command line; same as typing Control+L
warnings()