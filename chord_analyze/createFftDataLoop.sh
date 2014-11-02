#!/bin/bash

for TONE in 'do' 'reb'; do
    for ID in {1..128}; do 
        INFILE=$(printf "${TONE}_patterns/orig_wav/${TONE}_patterns%03d.wav" $ID)
        OUTFILE=$(printf "${TONE}_patterns/fft_result/${TONE}_result_%03d.txt" $ID)
        echo "Processing $INFILE..."
        R --vanilla --slave --args $INFILE $OUTFILE < createFftData.R
    done
done

