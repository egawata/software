library(tuneR)

fftStep <- 512          #  frame size
fftLength <- 32768
realFftLength <- 4096
sampleFreq <- 48000
analyzeStartPos <- fftStep * 10

args <- commandArgs(trailingOnly = T)
wavfile <- args[1]
waveObj <- readWave(wavfile)
wave <- attr(waveObj, 'left')

#  解析対象のwavを抽出
fftWave <- wave[analyzeStartPos:(analyzeStartPos + realFftLength - 1)]
fftWave[(realFftLength + 1):fftLength] <- 0

res <- log(abs(fft(fftWave)))
xx <- 1:fftLength
len <- 1024

plot(x = xx[1:len], y = res[1:len], type = 'l')
Sys.sleep(100)


