#!/usr/bin/perl
use strict ;
use warnings ;
use feature qw(say switch state) ;
use Data::Dumper;
my %global = (
# please don't change the parameter sequence. If it will be changed then parser willn't work.
#
# blocksize => [ "4k", "8k", "16k", "32k", "64k", "128k", "256k", "512k", "1m" ],
#
   blocksize => [ "4k", "1m" ],
# mixed workflows
#  rwmixread => [ "0", "5",  "10", "15", "20", "25", "30", "35", "40", "45", "50", "55", "60", "65", "70", "75", "80", "85", "90", "95", "100" ],
  rw        => [ "rw", "randrw" ],
  rwmixread => [ "0", "30", "50", "70", "100" ],
#direct
    direct    => [ 1 ],
#    size      => [ "1T" ],
    ioengine  => [ "libaio" ],
#    iodepth   => [ "1", "4", "8", "32", "64" ],
    iodepth   => [ "32" ],
    runtime   => [ 60 ],
#    numjobs   => [ "1", "8", "32" ],
    numjobs   => [ "32" ],
    bwavgtime => [ 100000 ],
    random_generator => [ "tausworthe64" ],
#    write_bw_log => [ "results" ],
#    write_iops_log => [ "results" ],
#    write_lat_log => [ "results"],
);

my @config_name = qw( blocksize rw iodepth numjobs );

my $device1 = $ARGV[0];
#my $device2 = $ARGV[1];
#my $device3 = $ARGV[2];
#my $device4 = $ARGV[3];


sub cartesian {
    my @C = map { [ $_ ] } @{ shift @_ };
    foreach (@_) {
        my @A = @$_;
        @C = map { my $n = $_; map { [ $n, @$_ ] } @C } @A;
    }
    return @C;
}

my @keys = sort keys %global ;
my @global = map { $global{$_} } @keys ;

foreach ( cartesian( @global ) ) {
     my $config .= "[global]\n" ;
     my $parameters .= "" ;
     my $template = "";
     my @params = reverse @$_ ;
     foreach (@keys) {
         $template = shift( @params ) ;

         $config .= "$_=" ;
         $config .= $template ;
         $config .= "\n" ;

	if ($_ ~~ @config_name) {
           $parameters .= "$_-" ;
           $parameters .= $template ;
           $parameters .= "_" ;
	}
     }
     $config .= "group_reporting\n" ;
     $config .= "[job]\n" ;
     $config .= "filename=$device1\n" ;
#     $config .= "filename=$device2\n" ;
#     $config .= "filename=$device3\n" ;
#     $config .= "filename=$device4\n" ;
     print "-----------------\n" ;
     print "Start new test:\n" ;
     print "-----------------\n" ;
     my $time = localtime;
     print "$time\n";
     print $config ;
     print "-----------------\n" ;
#     system( "echo \"$config\" | fio --output-format=normal --output=results_$parameters.txt -" ) ;
     system( "echo \"$config\" | fio --output-format=normal -" ) ;
     sleep 1 ;
}