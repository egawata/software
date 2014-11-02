library(tuneR, verbose=F)

fftStep <- 512          #  frame size
fftLength <- 32768
realFftLength <- 4096
sampleFreq <- 48000
analyzeStartPos <- fftStep * 20

args <- commandArgs(trailingOnly = T)
if ( length(args) != 2 ) {
    warnings("Usage: createFftData.R [infile.wav] [outfile.wav]")
    quit(status = -1)
}

infile <- args[1]
waveObj <- readWave(infile)
wave <- attr(waveObj, 'left')

outfile <- args[2]

#  解析対象のwavを抽出
fftWave <- wave[analyzeStartPos:(analyzeStartPos + realFftLength - 1)]
fftWave[(realFftLength + 1):fftLength] <- 0

#res <- log(abs(fft(fftWave)))
res <- abs(fft(fftWave))
xx <- (0:(fftLength - 1)) * (sampleFreq / fftLength) 
len <- 1024

maxAmp <- c()
for (oct in 0:7) {
    for (tone in 0:23) {
        centerFreq <- 27.5 * (2 ** (oct + (tone / 24)))
        loFreq <- centerFreq / (2 ** (1/48))
        hiFreq <- centerFreq * (2 ** (1/48))
        loIndex <- as.integer(loFreq * (fftLength / sampleFreq)) - 1
        hiIndex <- as.integer(hiFreq * (fftLength / sampleFreq))
        maxAmp[oct * 24 + tone] <- mean(res[loIndex:hiIndex])
    }
}
   
write(maxAmp, outfile)
 


