library(audio)
library("proxy")
library(seewave)
setwd("E:/Speech Recognition Project")
fs <- 16000 # sampling Frequency
frameSize <- 1.0 / 40   #frame size calculation
frameShift <- 1.0 / 100 #Frame Shift Calculation
ncep <- 13  # no. of cepstral coeff
ncep1 <- ncep + 1 

for (inFname1 in Sys.glob("wave/*1.wav"))
{ 
    
    #to compute refTemplates_1
   begin <- 0.0
   snd <- load.wave(inFname1) # read/load wave file
   N <- length(snd)
   N<- N/fs
   nFrame <- (as.integer(((N-frameSize)/frameShift)+1))  #no of frames
   cepstrumMatrix <- matrix(0, ncep, nFrame)
   
    for(iFrame in 1:nFrame)
    {
  
    end <- begin + frameSize
    logPowerSpectrum <- spec(snd,fs, wn = "hamming", fftw = FALSE, norm = TRUE,  dB="max0", from = begin, to = end)
    cepstrum <- fft(logPowerSpectrum,inverse = TRUE)
    cepstrumcoeff <- suppressWarnings(as.numeric(cepstrum[2:ncep1]))
    cepstrumMatrix[,iFrame] <- (cepstrumcoeff / (frameSize*fs))
    begin <- begin + frameShift
    iFrame <- iFrame + 1
    }
  
   #to  compute refTemplates_3
    begin <- 0.0
    inFname3 <- inFname1
    inFname3 <- sub("F1","F3",inFname3)
    snd <- load.wave(inFname3) # read/load wave file
    N <- length(snd)
    N<- N/fs
    nFrame <- (as.integer(((N-frameSize)/frameShift)+1))  #no of frames
    cepstrumMatrix_2 <- matrix(0, ncep, nFrame)
  
    for(iFrame in 1:nFrame)
    {
    
    end <- begin + frameSize
    logPowerSpectrum <- spec(snd,fs, wn = "hamming", fftw = FALSE, norm = TRUE,  dB="max0", from = begin, to = end)
    cepstrum <- fft(logPowerSpectrum,inverse = TRUE)
    cepstrumcoeff <- suppressWarnings(as.numeric(cepstrum[2:ncep1]))
    cepstrumMatrix_2[,iFrame] <- (cepstrumcoeff / (frameSize*fs))
    begin <- begin + frameShift
    iFrame <- iFrame + 1
    }
  
    
    
  # calculation of dist Matrix
  nTestFrame <- dim(cepstrumMatrix_2)[2]
  nRefFrame <- dim(cepstrumMatrix)[2]
   
   #allocate d[][] here.
    DistMatrix <- matrix(0,nTestFrame,nRefFrame)
    
    for(iTest in 1:nTestFrame)
    {
      x <- cepstrumMatrix_2[,iTest]
      for(jRef in 1:nRefFrame)
      {
        y <- cepstrumMatrix[,jRef]
        z <- rbind(x,y)
        DistMatrix[iTest,jRef] <- dist(z,method = "Euclidean")
      }
    }

  # calculation of capital D Matrix

    nTestFrame <- dim(DistMatrix)[1]
    nRefFrame <- dim(DistMatrix)[2]
    
    capD <- matrix(0,nTestFrame,nRefFrame)
    mini <-0.0 
    capD[1,1] <- DistMatrix[1,1];
    
    iTestAxis <- 1
    jRefAxis <- 2
    
    for(jRefAxis in 2:nRefFrame)
    {
      capD[iTestAxis,jRefAxis] <- DistMatrix[iTestAxis,jRefAxis]+DistMatrix[iTestAxis,(jRefAxis-1)];	 
    }
    
    iTestAxis <- 2
    jRefAxis <- 1
    
    for(iTestAxis in 2:nTestFrame)		
    {
      capD[iTestAxis,jRefAxis] <- DistMatrix[iTestAxis,jRefAxis]+DistMatrix[(iTestAxis-1),jRefAxis];	 
    }
    
    iTestAxis <- 2
    jRefAxis <- 2
    
    for (iTestAxis in 2:nTestFrame)
    {
      for (jRefAxis in 2:nRefFrame)
      {
        mini <- min(capD[iTestAxis-1,jRefAxis-1],capD[iTestAxis,jRefAxis-1],capD[iTestAxis-1,jRefAxis]);
        capD[iTestAxis,jRefAxis] <- DistMatrix[iTestAxis,jRefAxis] + mini;
      }
    }
    
        nTestFrame <- dim(capD)[1]
        nRefFrame <- dim(capD)[2]
        boolean_path <- matrix(0, nTestFrame, nRefFrame)
        boolean_path[nTestFrame,nRefFrame] <- 1
        minimum <- 0
        iTestAxis <- nTestFrame
        jRefAxis <- nRefFrame
        
        while ( (iTestAxis > 1)   &&   (jRefAxis > 1)  )
        { 
          minimum <- min(capD[iTestAxis-1,jRefAxis-1],capD[iTestAxis,jRefAxis-1],capD[iTestAxis-1,jRefAxis]) 
          
          if (capD[iTestAxis-1,jRefAxis-1] == minimum)
          { 
            boolean_path[iTestAxis-1,jRefAxis-1] <- 1
            iTestAxis <- iTestAxis - 1
            jRefAxis <- jRefAxis - 1
            } else if(capD[iTestAxis-1,jRefAxis] == minimum)
            {  
            boolean_path[iTestAxis-1,jRefAxis] <- 1
            iTestAxis <- iTestAxis-1
          }else 
            {
             boolean_path[iTestAxis,jRefAxis-1] <- 1
             jRefAxis <- jRefAxis -1
            }
        }
    
  
    # TO average the reference Templates to make a composite Reference Template
    
    nTestFrame <- dim(cepstrumMatrix_2)[2]
    nRefFrame <- dim(cepstrumMatrix)[2]
    composite_ref <- matrix(0,13,nTestFrame)
    
    for(x in 1:nTestFrame)
    { 
      count <- 1
      z <- cepstrumMatrix_2[ ,x]
      sum_of_columns <- 0 
      total_sum <- 0
      average <- 0
      
      
      for(y in 1:nRefFrame)
      {
        if (boolean_path[x,y]==1)
        {
          count <- count + 1
          sum_of_columns <- sum_of_columns + cepstrumMatrix[ ,y]
        }
      }
      total_sum <- sum_of_columns + z
      average <- total_sum/count
      composite_ref[,x] <- average
    }
  
  outFname <- inFname1
  outFname <- sub("wave", "Composite_ref_Templates", outFname)
  outFname <- sub(".wav", ".mfcc", outFname)
  outFname <- sub("F1"," ",outFname)
  
  save(composite_ref, file=outFname)
  
}

  
  

    
  
    
    