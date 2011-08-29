use strict;
use warnings;
use utf8;
use WassrApi;
use Data::Dumper;
use Encode;

my $LOG_FILE_PATH = "$FindBin::Bin/replies.log";
my $YOUR_ID       = '';

sub is_logfile {
    my $target_id = shift;        

    open my $fh , '<:utf8', $LOG_FILE_PATH or die $! . $LOG_FILE_PATH;
    while( my $id = <$fh> ) {
        chomp $id;
        if( $target_id == $id ) {
            return 1;    
        } 
    }

    return 0;
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

