#!/usr/bin/perl

use strict ;
use warnings ;
use Fcntl qw(O_RDONLY LOCK_EX LOCK_UN F_GETFD F_SETFD FD_CLOEXEC) ;
use feature qw(say switch state) ;
use threads ;
use Data::Dumper;
use feature "switch";

my $ss=0;
my $avg_lat=0;
my $max_lat=0;
my $IOps=0;
my $var=0;
my $BW=0;

sub to_kbps {
    $_ = shift ;
    my ($val) = /([0-9.]+)/ ;
    return (/KB\/s/)? $val / 1000 : $val ;
    }
print "sep=;\n";
print "blocksize;iodepth;numjobs;rw;rwmixread;r_iops;r_maxlat_usec;r_avglat_usec;w_iops;w_maxlat_usec;w_avglat_usec;r_aggrb_MB;w_aggrb_MB;\n" ;
while( <> ) {
    if ( /^blocksize=\s*([^ ,\n]+)/ ) { print "$1;"; next }
    if ( /^iodepth=\s*([^ ,\n]+)/ ) { print "$1;"; next }
    if ( /^numjobs=\s*([^ ,\n]+)/ ) { print "$1;"; next }
    if ( /^rw=\s*([^ ,\n]+)/ )        { print "$1;"; next }
    if ( /^rwmixread=\s*([^ ,\n]+)/ ) {
        $ss=$1;
    if ( $ss==0 ) { print "$ss;0;0;0;";  next }
        else { print "$ss;"; next }
       }
    if ( /IOPS=\s*([^ ,\n]+)/ ) {
        $IOps = $1;
        if ( $IOps =~ /[.][0-9][k]/ ) {
            $IOps =~ tr/k/0/;
            $IOps = $IOps*1000;
            print "$IOps;"; next }
        if ( $IOps =~ /[k]/ ) {
            $IOps =~ tr/k/0/;
            $IOps = $IOps*100;
            print "$IOps;"; next }
        else { print "$IOps;"; next }
       }
#    if ( /bw.*min=\s*([^ ,\n]+), max=\s*([^ ,\n]+).*avg=\s*([^ ,\n]+), stdev=\s*([^ ,\n]+)/ )
#        { print "$1;$2;$3;$4;"; next }
#    if ( /[^cs]lat.*\(([u,m]).*max=\s*([^ ,\n]+).*avg=\s*([^ ,\n]+)/) { print "$1_$2;$1_$3;"; next }
    if ( /[^cs]lat.*\(([u,m]).*max=\s*([^ ,\n]+).*avg=\s*([^ ,\n]+)/) {
        if ( $1 eq "u" ) {
             $max_lat=$2;
             $avg_lat=$3;
             given ($max_lat) {
               when ( /[.][0-9][k]/ ) {
                    $max_lat =~ tr/k/0/;
                    $max_lat = $max_lat*1000;
                    print "$max_lat;";
               }
               when ( /[k]/ ) {
                    $max_lat =~ tr/k/0/;
                    $max_lat = $max_lat*100;
                    print "$max_lat;";
               }
               default                { print "$max_lat;" }
             }
             given ($avg_lat) {
               when ( /[.][0-9][k]/ ) {
                    $avg_lat =~ tr/k/0/;
                    $avg_lat = $max_lat*1000;
                    print "$avg_lat;";
               }
               when ( /[k]/ ) {
                    $avg_lat =~ tr/k/0/;
                    $avg_lat = $avg_lat*100;
                    print "$avg_lat;";
               }
               default                { print "$avg_lat;" }
             }
             #print "$2;$3;";
              next }
        elsif ( $1 eq "m" ) {
          $max_lat=$2*1000;
          $avg_lat=$3*1000;
          print "$max_lat;$avg_lat;"; next
         }
        else {
           print "not_usec_or_msec_$max_lat;not_usec_or_msec_$avg_lat;"; next
         }
        }
    if ( /(READ): bw=[^\(]+\(([\d+(\.\d{1,2})?+M+B+G+B+K+B]+)/ ) {
        if ( $ss==100 ) {
            $BW=$2;
            given ($BW) {
               when ( /(MB)/ ) {
                    $BW =~ s/.{2}$//;
                    print "0;0;0;$BW;0\n";
               }
               when ( /(GB)/ ) {
                    $BW =~ s/.{2}$//;
                    $BW = $BW*1000;
                    print "0;0;0;$BW;0\n";
               }
               default                { print "0;0;0;when_other_$2;0\n" }
             }
            #$BW =~ s/.{2}$//;
            #print "0;0;0;0;0;0;0;when1_MB_$2;0\n"; 
            next }
        else {
            $BW=$2;
            given ($BW) {
               when ( /(MB)/ ) {
                    $BW =~ s/.{2}$//;
                    print "$BW;";
               }
               when ( /(GB)/ ) {
                    $BW =~ s/.{2}$//;
                    $BW = $BW*1000;
                    print "$BW;";
               }
               default                { print "when_other_$2;" }
             }
            #$BW =~ s/.{2}$//;
            #print "$2;" ;
            next }
       }
    if ( /(WRITE): bw=[^\(]+\(([\d+(\.\d{1,2})?+M+B+G+B+K+B]+)/ ) {
        if ( $ss==0 ) {
            $BW=$2;
            given ($BW) {
               when ( /(MB)/ ) {
                    $BW =~ s/.{2}$//;
                    print "0;$BW;\n";
               }
               when ( /(GB)/ ) {
                    $BW =~ s/.{2}$//;
                    $BW = $BW*1000;
                    print "0;$BW;\n";
               }
               default                { print "0;when_other_$2;\n" }
             }
            #print "0;$2;\n" ;
            next }
        else {
            $BW=$2;
            given ($BW) {
               when ( /(MB)/ ) {
                    $BW =~ s/.{2}$//;
                    print "$BW;\n";
               }
               when ( /(GB)/ ) {
                    $BW =~ s/.{2}$//;
                    $BW = $BW*1000;
                    print "$BW;\n";
               }
               default                { print "when_other_$2;\n" }
             }
             #print "$2;\n" ;
             next }
      }
     }
print "blocksize;iodepth;numjobs;rw;rwmixread;r_iops;r_maxlat_usec;r_avglat_usec;w_iops;w_maxlat_usec;w_avglat_usec;r_aggrb_MB;w_aggrb_MB;\n" ;