#' ---
#' title: "Plotting FreeSnell reflectance predictions and insect visual modeling"
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

#' Read in measured reflectance
buttspec <- read.csv("Wt silver reflectance.csv", comment.char = ">", row.names = NULL, header = T)  
spp <- gsub('\\_[0-9]*$', '', names(buttspec))[-1]
table(spp)

#' Read in raw absorbance
absorb <- read.csv("Wt silver absorbance.csv", comment.char = ">", row.names = NULL, header = T)  
n <- ncol(absorb)
sppa <- gsub('\\_[0-9]*$', '', names(absorb))[-1]
table(sppa)

#' Extrapolate absorbance data to 350 nm
absorbi <- matrix(nrow = 351, ncol = 31)
xnew <- seq(350,399,1)
explorespec(absorb, by = 6, ylim = c(0,0.5))
for(i in 2:ncol(absorb)) {
  x<-absorb[,1]
  y<-absorb[,i]
  low <- loess(y ~ x, span = 0.2, control = loess.control(surface = "direct"))
  res <- predict(low, newdata = xnew)
  #plot(x,y,xlim=c(350,700), ylim = c(0,0.6))
  #lines(xnew, res, col = "blue", lwd = 3)
  absorbi[,1] <- c(xnew,x)
  absorbi[,i] <- c(res,y)
}
colnames(absorbi) <- colnames(absorb)
absorb <- as.data.frame(absorbi)
absorbi <- NULL

#' Calculate the Transmission Spectra
transm <- as.data.frame(absorb[,1]) #initialize
colnames(transm)[1] <- "wl"
for (i in 2:n) {
  transm <- cbind(transm,10^(-absorb[,i]))
  colnames(transm)[i] <- colnames(absorb)[i]
}

#' Plot Transmittance spectra
aggtransspecsm <- aggspec(as.rspec(transm,lim=c(350,700)), by = sppa, FUN = mean) 
plot(x = aggtransspecsm, select = c(2:length(aggtransspecsm)), col = spec2rgb(as.rspec(aggtransspecsm,lim=c(300,700))), type = 'o', lwd=4,ylim=c(0,1))
title(main = "Mean Transmission Spectra (extrapolated to 350 nm)")
text(x=rep(400,length(aggtransspecsm)-1),y=colMeans(as.matrix(aggtransspecsm[-1])),colnames(aggtransspecsm)[-1])

types  <- unique(substring(colnames(aggtransspecsm), first=1, last=8))[-1]

aggbuttspecsm <- aggspec(buttspec, by = spp, FUN = mean) 
plot(x = aggbuttspecsm, select = c(2:length(aggbuttspecsm)), col = spec2rgb(as.rspec(aggbuttspecsm,lim=c(300,700))), type = 'o', ylim = c(0,80))#, xaxs="i", yaxs="i")
title(main = "Mean Measured Microspectra")

#' get the list of different anatomies/loci measured (put files in separate directories)
dirs <- list.dirs(path = ".",  recursive = TRUE)
#' remove directory without .dat files
dirs <- dirs [sapply(dirs, function(x) length(dir(path=x,pattern = "*.dat",recursive = TRUE))>0)][-1]
ndirs <- length(dirs)

#' split screen
#turn off hit return to see next plot
par(ask = F)
#fix other plot parameters
#par(mfrow=c(2,2))
par(cex = 1)
#par(mar = c(1,1,1,1), oma = c(0,100/ndirs,0,100/ndirs)) #right and left margins 100/ndirs, top and bottom margins 2
par(mar = c(1,1,1,1), oma = c(2,2,2,2)) 
par(tcl = -0.25)
par(mgp = c(2, 0.6, 0))


## ------------------------------------------------------------------------
#' There is a quick way to hide files from plotting: 
#'  just remove their ".dat" file extensions and rename the file. you can re-add ".dat" to plot these files again.
## ------------------------------------------------------------------------

DCoffset <- 30

for(j in 1:ndirs) {
  
  files = dir(path=dirs[j],pattern = "*.dat",recursive = TRUE)
  
  #if (length(files) > 0) { #non-empty folder
  numfiles <- length(files)
  predspec <- array(0,dim=c(1199,0));
  pspec <- array(0,dim=c(1199,0));
  
  dev.new() # Create a new graphics device for plotting

  #plot with square aspect ratio
  par(pty="s")
  plot.new()
  
  pdf(paste(gsub('./','',dirs[j]),"_measpred_wsd_abs.pdf",sep = ''), width = 4.5, height = 5) # Open a pdf file
  
  plot(c(1,1), type = 'n', ylim = c(0,80), xlim = c(350,700), xaxt='n', yaxt="n", ann=FALSE) #xaxs = "i", yaxs = "i",
  
  
  for (i in 1:numfiles) {
    #read in data as tab-delimited and skipping the header if it exists
    predspec <- read.table(paste(dirs[j],files[i],sep="/"), sep="\t",skip=0, comment.char = ">",header = TRUE)  
    predspec[1] <- predspec[1]/1e-9 #convert from m to nm
    #predspec[2:3] <- predspec[2:3]*100 #convert to % reflectivity
    predspec[2] <- predspec[2]*100+DCoffset #convert to % reflectivity %with a DC signal
    predspec[3] <- predspec[3]*100 
    specname <- paste(gsub('._','',gsub("/","_",dirs[j])), gsub('.dat','',gsub("/","_",files[i])), sep='_')
    pspec <- cbind(pspec, predspec[,2])
    colnames(pspec)[ncol(pspec)] <- specname
    
    #' Aggregated spectra
    titlename <- paste(gsub('._','',gsub("/","_",dirs[j])), gsub('.dat','',gsub("/","_",files[i])), sep='_')
    #cols <- spec2rgb(as.rspec(predspec[-3],lim=c(300,700),whichwl = 1))
    #names(cols) <- NULL
    alpha <- '40'
    if(length(grep("abaxial",files[i])) > 0) { #for abaxial/abwing reflectance, we include the effects of pigmentary absorption
      par(new = TRUE)
      cols <- "#444444"
      
      #' Rescale as Pavo refl. spectra
      reflpredspec <- as.rspec(predspec, whichwl=1, lim = c(350,700))
      #' Incorporate Pigmentary Absorption
      currtype <- substring(gsub(" ", "_", gsub("Male ", "", gsub("./","",dirs[j]))),1,8)
      idx <- grep(currtype, types, ignore.case = TRUE)+1
      
      lines(reflpredspec$wl, reflpredspec$mean*t(aggtransspecsm[idx])^1, col = cols, lwd=4, lty=2,ylim=c(0,80),xlim = c(350,700))#, xaxs="i", yaxs="i")
      cols <- paste(substring("#666666",first = 1,last =7),alpha,sep='') #with alpha
      
      title(substring(titlename,1,20))
      N <- 100
      xx <- reflpredspec$wl
      yu <- reflpredspec$mean*t(aggtransspecsm[idx])^1 + reflpredspec$sd#/sqrt(N)
      yl <- reflpredspec$mean*t(aggtransspecsm[idx])^1 - reflpredspec$sd#/sqrt(N)
      #lines(xx, yl, col = cols, lwd=1)
      #lines(xx, yu, col = cols, lwd=1)
      par(new = TRUE)
      polygon(x=c(xx,rev(xx)),y=c(yl,rev(yu)), col = cols,border = NA,ylim=c(0,80),xlim = c(350,700))#, xaxs="i", yaxs="i")
    }else { #for adaxial/adwing reflectance
      par(new = TRUE)
      cols <- "#AAAAAA"
      
      #' Rescale as Pavo refl. spectra
      reflpredspec <- as.rspec(predspec, whichwl=1, lim = c(350,700))
      
      lines(reflpredspec$wl, reflpredspec$mean, col = cols, lwd=4, lty=3,ylim=c(0,80),xlim = c(350,700))#, xaxs="i", yaxs="i")
      cols <- paste(substring("#CCCCCC",first = 1,last =7),alpha,sep='') #with alpha
      title(substring(titlename,1,20))
      N <- 100
      xx <- reflpredspec$wl
      yu <- reflpredspec$mean + reflpredspec$sd#/sqrt(N)
      yl <- reflpredspec$mean - reflpredspec$sd#/sqrt(N)
      #lines(xx, yl, col = cols, lwd=1)
      #lines(xx, yu, col = cols, lwd=1)
      par(new = TRUE)
      polygon(x=c(xx,rev(xx)),y=c(yl,rev(yu)), col = cols,border = NA,ylim=c(0,80),xlim = c(350,700))#, xaxs="i", yaxs="i")
    }

    
    #Now plot the corresponding measured spectra
    findstr <- paste(gsub(x=gsub(x=dirs[j],pattern='./Male ',replacement=''),pattern=' ',replacement='_'),substring(files[i],1,2),sep='_')
    idx <- grep(findstr, colnames(buttspec),ignore.case = TRUE)
    if (length(idx) == 0) {
      findstrab <- gsub(x=gsub(x=dirs[j],pattern='./Male ',replacement=''),pattern=' ',replacement='_')
      findstrad <- paste(gsub(x=gsub(x=dirs[j],pattern='./Male ',replacement=''),pattern=' ',replacement='_'),'ad',sep='_')
      idx1 <- grep(findstrab, colnames(buttspec),ignore.case = TRUE)
      idx2 <- grep(findstrad, colnames(buttspec),ignore.case = TRUE)
      idx <- idx1[-c(match(idx2, idx1))]
    }
    bspec <- buttspec[c(1,idx)]
    par(new = TRUE)
    #aggplot(as.rspec(bspec), by = ncol(bspec)-1, FUN.center = mean, FUN.error = function(x)sd(x),#/sqrt(length(x)), 
            #lcol = spec2rgb(as.rspec(bspec,lim=c(300,700))), shadecol = spec2rgb(as.rspec(bspec,lim=c(300,700))), 
            #alpha = 0.4, lwd=4, ylim=c(0,80),xlim = c(350,700),# xaxs="i", yaxs="i", ylab="", xlab="")
    if(length(grep("abaxial",files[i])) > 0) { #for abaxial/abwing reflectance
      aggplot(as.rspec(bspec), by = ncol(bspec)-1, FUN.center = mean, FUN.error = function(x)sd(x),#/sqrt(length(x)), 
      lcol = "#444444", shadecol = "#666666", alpha = 0.4, lwd=4, ylim=c(0,80),xlim = c(350,700),# xaxs="i", yaxs="i", 
      xlab = "Wavelength (nm)", ylab = "% Reflectivity")
    }else{ #for adaxial/adwing reflectance
      aggplot(as.rspec(bspec), by = ncol(bspec)-1, FUN.center = mean, FUN.error = function(x)sd(x),#/sqrt(length(x)), 
      lcol = "#AAAAAA", shadecol = "#CCCCCC", alpha = 0.4, lwd=4, ylim=c(0,80),xlim = c(350,700),# xaxs="i", yaxs="i", 
      xlab = "Wavelength (nm)", ylab = "% Reflectivity")
    }
  }  
  
  dev.off() # Close the pdf file  
  
  #'now add the wavelength bins as the first column
  pspec <- data.frame("wl" = predspec[,1],pspec)
}


#' reset plot window
par(mfrow = c(1,1))


#' ##Ideal Trichromat model without von Kries correction
#'
#' Apply  trichromat visual model to predicted reflectance with ideal 
#' homogeneous illuminance function of 1!
## ---- echo=FALSE, fig.keep = "ALL" ------------------------------------------------------

vis.pspec.tri <- vismodel(pspec, visual = 'drosophila',
                          relative = FALSE, vonkries = FALSE) 
#vis.pspec.tri
summary(vis.pspec.tri)
tridist.pspec <- coldist(vis.pspec.tri, n = c(1, 2, 1))
#tridist.pspec
summary(tridist.pspec)
colspace.pspec.tri <- colspace(vis.pspec.tri, space = 'tri')
labs <- c("ll","ul","ll-3layer","airgap","airgap-ll","ul-3layer","ul-ll")
plot(colspace.pspec.tri, col = cols, main = "Fruitfly colorspace (ideal)",cex=1)
for (k in 1:nrow(colspace.pspec.tri)) {
  plot(colspace.pspec.tri[k,], col = cols[k], main = "Fruitfly colorspace (ideal)",cex=1)
  text(colspace.pspec.tri[k,]$x+0.2,colspace.pspec.tri[k,]$y,labels = labs[k])
}

## ------------------------------------------------------------------------
#' To debug, try running (a few) line(s) at a time and/or comment out the next three lines
#rgl.close() #close 3D graphics
#graphics.off()# close all other graphics
#cat("\014") #clear the command line; same as typing Control+L
warnings()