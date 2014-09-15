library(tuneR)
library(ggplot2)

fftStep <- 512
fftLength <- 32768
realFftLength <- 4096
sampleFreq <- 44100
numPreview <- 512

args <- commandArgs(trailingOnly = T)
numSample <- 100

if ( length(args) >= 2 ) {
    numSample <- as.integer(args[2])
}

cat(paste("Num of sample : ", numSample, "\n"))

freqs <- 0:(numPreview - 1)
freqs <- freqs * (sampleFreq / fftLength)

p <- ggplot()
mean <- c(rep(0, times = numPreview))

for ( wavfile in c("Cmajor.wav", "Cminor.wav", "G7.wav") ){

    waveObj <- readWave(wavfile)
    wave <- attr(waveObj, 'left')

    offsetSeq <- seq(1, fftStep * numSample, by = fftStep)
    for ( offset in offsetSeq ) {
        fftWav <- wave[(offset):(offset + fftLength - 1)]
        fftWav[(realFftLength + 1):fftLength] <- c(rep(0, times = (fftLength - realFftLength)))
        res <- abs(fft(fftWav)) ^ 2
        res <- res[1:numPreview]
        mean <- mean + res
    }

    mean <- mean / length(offsetSeq)
    dat <- data.frame(freqs, mean)
    col <- ifelse(wavfile == "Cmajor.wav", "blue", ifelse(wavfile == "Cminor.wav", "green", "red"))
    p <- p + geom_line(data = dat, aes(freqs, mean), colour=col)
}
warnings()

ggsave(paste(wavfile, ".png", sep=""))


