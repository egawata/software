use strict;
use warnings;

use Audio::Wav;
use Data::Dumper;
use List::Util;


#  この振幅を超えた位置を演奏開始とみなす
my $START_THRESHOLD = 500;

#  音源のテンポ
my $TEMPO = 120;

#  1サンプルの長さ(拍数)
#  4/4拍子で1小節分なら 4
my $NUM_QUARTER_TONES = 4;

#  位置微調整用
#  本来サンプル間の切れ目と思われる位置から前後 
#  $NUM_SAMPLES_NEAR_BEAT サンプルの振幅を調べ
#  最大音量だった位置の $NUM_SAMPLES_BEFORE_MAX_AS_BEAT サンプル前を
#  新しいサンプルの開始位置とみなす
my $NUM_SAMPLES_NEAR_BEAT = 3000;
my $NUM_SAMPLES_BEFORE_MAX_AS_BEAT = 300;


main();
exit(0);


sub main {
    my $infile = $ARGV[0] or die "wav filename required\n";

    my $wav = new Audio::Wav;
    my $read = $wav->read($infile);

    #  開始位置を探す
    my $time = 0;
    while ( my ($sample) = $read->read() ) {
        $sample > $START_THRESHOLD and last;
        $time++;
    }

    print "Start time: $time\n";

    my $details_read = $read->details;
    my $SAMPLE_RATE = $details_read->{sample_rate};

    my $details_write = {};
    $details_write->{$_} = $details_read->{$_} for qw/ bits_sample sample_rate channels /;

    my $prev_pos = $read->position_samples();
    $prev_pos -= 512;
    $read->move_to_sample($prev_pos);
    for my $pattern_num (1 .. 128) {
        my $outfile = $infile;
        $outfile =~ s/\.wav$/sprintf("%03d.wav", $pattern_num++)/e;
        print "$outfile\t";

        my $write = $wav->write($outfile, $details_write);
        
        my $data = $read->read_raw_samples($SAMPLE_RATE * 60 / $TEMPO * $NUM_QUARTER_TONES); 
        $write->write_raw_samples($data);
        $write->finish();
        
        my $curr_pos = $read->position_samples();
        print sprintf("Position: %d (+%d)\n", $curr_pos, $curr_pos - $prev_pos);
        $prev_pos = $curr_pos;
    }

}
    
        
