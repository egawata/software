library(tuneR)
library(rgl)

fftStep <- 512          #  frame size
fftLength <- 32768
realFftLength <- 4096
sampleFreq <- 44100
numPreview <- 256       #  Range of displayed frequency
numRepeat <- 75         #  num of frames from start

args <- commandArgs(trailingOnly = T)
wavfile <- args[1]
waveObj <- readWave(wavfile)
wave <- attr(waveObj, 'left')

freqs <- 0:(numPreview - 1)
freqs <- freqs * (sampleFreq / fftLength)

times <- c()
amp <- c()

for ( pos in 1:numRepeat ) {

    offset <- pos * fftStep

    fftWav <- wave[(offset):(offset + fftLength - 1)]
    if ( realFftLength < fftLength ) {
        fftWav[(realFftLength + 1):fftLength] <- c(rep(0, times = (fftLength - realFftLength)))
    }

    res <- abs(fft(fftWav))
    res <- res[1:numPreview]

    times <- c(times, rep(pos, numPreview))
    amp <- c(amp, res)
}

freqlist <- rep(freqs, numRepeat)

result <- data.frame(times, freqlist, amp)

plot3d(result$times, result$freqlist, result$amp, col=rainbow(numPreview * 3), type="l", lwd=0.5)

Sys.sleep(1000)
print("Done")




