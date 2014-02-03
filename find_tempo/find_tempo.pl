#!/usr/bin/perl

use strict;
use warnings;

use Audio::Wav;
use Math::FFT;
use List::Util qw/ min /;
use Data::Dumper;

my $FRAME_SIZE = 1024;
my $NUM_FRAMES = 1024;  #  2のn乗でないといけない

my $PI2 = 2.0 * 3.14159;

main();
exit(0);


sub main {
    my $infile = $ARGV[0] or die "Filename required\n";
    my $start_sec = $ARGV[1] || 0;

    my $wav = new Audio::Wav;
    my $read = $wav->read($infile);

    my $details = $read->details();
    my $SAMPLE_RATE = $details->{sample_rate};
    my $SAMPLE_FREQ = $SAMPLE_RATE / $FRAME_SIZE;

    #  50秒くらい読み飛ばす
    $read->move_to_sample( $SAMPLE_RATE * $start_sec );

    my @deltas = ();
    my $prev_level = 0;
    for my $frame_no ( 1 .. $NUM_FRAMES ) {
        my $level = 0;
        for ( 1 .. $FRAME_SIZE ) {
            my @channels = $read->read();
            last unless @channels;
            my $vol = 0;
            $vol += $_ for @channels;
            $level += $vol ** 2;
        }
        my $sum_level = sqrt($level / $FRAME_SIZE);
        my $delta = $sum_level - $prev_level;
        $delta = ($delta >= 0) ? $delta : 0;
        push @deltas, $delta;
        $prev_level = $sum_level;
    }

    my $fft = new Math::FFT(han(\@deltas));
    my $fft_res = $fft->cdft();

    my %peaks = ( -1 => 0 );

    for ( 10 .. (@$fft_res - 10) / 2 ) {    #  最初と最後のデータはピークになりやすいので無視
        my $cos = $fft_res->[$_ * 2];
        my $sin = $fft_res->[$_ * 2 + 1];
        my $bpm = $_ / ($NUM_FRAMES / $SAMPLE_FREQ) * 60;
        my $val = sqrt($cos ** 2 + $sin ** 2);
        print "$bpm\t$val\n";
        if ( $val > min(values %peaks) ) {

            #  特定BPMの周囲に最大値が集まっていることがあるので、
            #  その中から一つだけ採用するための処理
            #  近傍のものよりレベルが高ければ、その近傍のBMPを消して
            #  代わりに今回のものを採用する。
            #  レベルが低ければ、今回のものは無視する。
            my ($near_bpm) = grep { $bpm - $_ < 10 } keys %peaks;
            if ( $near_bpm ) {
                if ( $peaks{$near_bpm} < $val ) {
                    delete $peaks{$near_bpm};
                }
                else {
                    next;
                }
            }

            $peaks{$bpm} = $val;

            #  上位3つのみ採用する
            my @keys = sort { $peaks{$b} <=> $peaks{$a} } keys %peaks;
            delete $peaks{ $keys[-1] } if @keys > 3;
        }
    }

    #  BPM = 1分間あたりの四分音符の数だが、
    #  八分/十六分のリズムが強いことがありがちなので、
    #  BPM を2の累乗で割っていく。
    #  だいたい BPM が200以下であれば適正と思われる。
    my $result_bpm = min(keys %peaks);
    while ( $result_bpm > 200 ) {
        $result_bpm /= 2;
    }

    print "This song maybe BPM $result_bpm\n";
}


sub han {
    my ($orig) = @_;
    
    my $size = @$orig;
    my @han = ();
    for ( 0 .. $size - 1 ) {
        my $val = $orig->[$_] * (0.5 - 0.5 * cos($PI2 * ($_ / $size)));
        push @han, $val;
    }

    return [@han];
}

    


