use strict;
use warnings;

use File::Spec;
use List::Util qw/ shuffle /;

main();
exit(0);

sub main {
    my $result_train_file = '/tmp/fft_result_train.txt';
    my $result_test_file = '/tmp/fft_result_test.txt'; 

    open my $OUT_TRAIN, '>', $result_train_file or die $!;
    open my $OUT_TEST, '>', $result_test_file or die $!;
    my $header = join ' ', map{"x$_"} (1 .. 191);
    $header .= " result";
    print $OUT_TRAIN "$header\n";
    print $OUT_TEST "$header\n";

    my %train_ids = map { $_ => 1 } ((shuffle 1 .. 128)[0..86]);
    print "Num of train data = " . scalar(keys %train_ids); 

    for my $tone ( qw/ do reb / ) {
        my $basedir = "${tone}_patterns";
        opendir my $DIR, File::Spec->catdir($basedir, 'fft_result') or die $!;
        while ( my $file = readdir $DIR ) {
            $file =~ /(\d{3})\.txt$/ or next;
            my $id = $1 + 0;
            my $OUT = ( $train_ids{$id} ) ? $OUT_TRAIN : $OUT_TEST;
            my $file_fp = File::Spec->catfile($basedir, 'fft_result', $file);
            open my $IN, '<', $file_fp or die $!;
            while ( my $line = <$IN> ) {
                chomp($line);
                print $OUT "$_ " for split " ", $line;
            }
            print $OUT "$tone\n";
            close $IN;
        }
    }
    
    close $OUT_TRAIN;
    close $OUT_TEST;
    print "Done\n";
}
