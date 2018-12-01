library(audio)
library("proxy")
library(seewave)
setwd("E:/Speech Recognition Project")
fs <- 16000 # sampling Frequency
frameSize <- 1.0 / 40   #frame size calculation
frameShift <- 1.0 / 100 #Frame Shift Calculation
ncep <- 13  # no. of cepstral coeff
ncep1 <- ncep + 1 
nTestFiles <- 20
nRefFiles <- 20  
matchCost <- matrix (0, nTestFiles, nRefFiles)



#to compute test Templates
for (inFname in Sys.glob("wave/*2.wav"))
{ 
  begin <- 0.0
  snd <- load.wave(inFname)
  N <- length(snd)
  N<-N/fs
  nFrame <- (as.integer(((N-frameSize)/frameShift)+1) )  #no of frames
  test_cepstrumMatrix <- matrix(0, ncep, nFrame)
  
  for(iFrame in 1:nFrame)
  {
    end <- begin + frameSize
    logPowerSpectrum <- spec(snd,fs, wn = "hamming", fftw = FALSE, norm = TRUE,  dB="max0", from = begin, to = end)
    cepstrum <- fft(logPowerSpectrum,inverse = TRUE)
    cepstrumcoeff <- suppressWarnings(as.numeric(cepstrum[2:ncep1]))
    test_cepstrumMatrix[,iFrame] <- (cepstrumcoeff / (frameSize*fs))
    begin <- begin + frameShift
    iFrame = iFrame + 1
    
  }
  
  outFname <- inFname
  outFname = sub("wave", "testTemplates", outFname)
  outFname = sub(".wav", ".mfcc", outFname)
  save(test_cepstrumMatrix, file=outFname)
  
}

#DTW
kTestIndex <-  1
for (inFname1 in Sys.glob("Composite_ref_Templates/* .mfcc"))
{ 
  load(inFname1)
  mRefIndex <- 1
  
  for (inFname2 in Sys.glob("testTemplates/*2.mfcc"))
  { 
    load(inFname2)
   
  
    # calculation of dist Matrix
    nTestFrame <- dim(test_cepstrumMatrix)[2]
    nRefFrame <- dim(composite_ref)[2]
    nRefFrame
    #allocate d[][] here.
    DistMatrix <- matrix(0,nTestFrame,nRefFrame)
    
    for(iTest in 1:nTestFrame)
    {
      x <- test_cepstrumMatrix[,iTest]
      for(jRef in 1:nRefFrame)
      {
        y <- composite_ref[,jRef]
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
    
    matchCost[kTestIndex, mRefIndex] <- capD[nTestFrame,nRefFrame]
    mRefIndex <- mRefIndex +1
    
    # calculation of boolean_path
    
    nTestFrame <- dim(capD)[1]
    nRefFrame <- dim(capD)[2]
    boolean_path <- matrix(0, nTestFrame, nRefFrame)
    boolean_path[nTestFrame,nRefFrame] <- 1
    minimum <- 0
    iTestAxis <- nTestFrame
    jRefAxis <- nRefFrame
    
    while ((iTestAxis > 1) && (jRefAxis > 1))
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
    
  }
 
kTestIndex <- kTestIndex + 1
}

#print variables to debug or find values of the variables.
inFname1
inFname2

matchCost
kTestIndex
mRefIndex
composite_ref
test_cepstrumMatrix
DistMatrix
capD
boolean_path
inFname1
inFname2

