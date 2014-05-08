#!/usr/bin/perl

use strict;
#use warnings;

use Audio::Wav;
use File::Basename;
use Data::Dumper;

main();
exit(0);


sub main {
    my $file = $ARGV[0] or usage();

    my $wav = new Audio::Wav();
    my $read = $wav->read($file);
    
    my $details = $read->details();
    my $sample_rate = $details->{sample_rate};

    #  解析の対象区間は、楽曲の長さの半分の箇所から前後15秒
    #  2 でなく 4 で割っているのは、data_length の単位が byte であって、
    #  sample 単位に変換するためにまず 2 で割り(1sample = 16bits)、
    #  さらに半分の箇所を求めるために 2 で割るという演算を一度に行っているため。
    my $start = $details->{data_length} / 4 - $sample_rate * 15;
    my $length = $sample_rate * 30;

    $read->move_to_sample($start);

    my $prev_amp = 0;
    my $zero_count = 0;
    for ( 1 .. $length - 1 ) {
        my ($amp) = $read->read();
        defined $amp or die "Failed to retrieve sample at $_\n";
        $prev_amp * $amp < 0 and $zero_count++;
        $prev_amp = $amp;
    }

    #  1ms あたりの ZCR
    print basename($file) . "\t: ZCR = " . $zero_count / 30000 . "\n";
}


sub usage {
    print STDERR <<USAGE;
Usage: $0 (wav filename)
USAGE

    exit(-1);
}


