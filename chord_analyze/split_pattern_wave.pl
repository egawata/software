use strict;
use warnings;

use Audio::Wav;
use List::Util;


my $SAMPLE_RATE = 44100;

#  この振幅を超えた位置を演奏開始とみなす
my $START_THRESHOLD = 5000;

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
    while ( my (@samples) = $read->read() ) {
        my $amp = List::Util::sum0(@samples) / scalar(@samples);
        $amp > $START_THRESHOLD and last;
        $time++;
    }

    print "Start time: $time\n";
}
    
        
