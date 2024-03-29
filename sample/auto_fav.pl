use strict;
use warnings;
use utf8;
use WassrApi;
use Encode;
use FindBin;

my $LOG_FILE_PATH = "$FindBin::Bin/replies.log";
my $YOUR_ID       = '';

sub is_logfile {
    my $target_id = shift;        

    open my $fh , '<:utf8', $LOG_FILE_PATH or die $! . $LOG_FILE_PATH;

    my $id_fg = 0;
    while( my $id = <$fh> ) {
        chomp $id;
        if( $target_id == $id ) {
            $id_fg = 1;
            last;
        } 
    }

    close $fh;

    return $id_fg;
}

sub add {
    my $target_id = shift;
    open my $fh , '>>', $LOG_FILE_PATH or die $!;
    print $fh encode('utf8',$target_id) . "\n"; 
    close $fh;
}

sub main {

    unless( $YOUR_ID ) {
        die('please set your id');
    }

    for my $row ( replies() ) {
        unless( is_logfile($row->{id}) ) {
            unless( grep { $YOUR_ID eq $_ } @{ $row->{favorites} } ) { 
                fav( $row->{rid} );    
            }
            add($row->{id});
        }
    }

}

&main();

