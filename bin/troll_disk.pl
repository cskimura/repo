#!/bin/perl

# License: GPL2 (maybe :-P )

# value
my $version='0.0.1';
my $disk=shift;
my $bs=1024;
my $count=1024*1024*1024/$bs;
my @per=(
    '0', '10', '20', '30', '40',
    '50', '60', '70', '80', '90',
    '99',
);

my $size='';
my $opc=''; # one percent count

main();
exit 0;

sub main () {
    grok_disk();
    show_version();
    show_disk_info();
    benchmark();
    exit 0;
}

sub benchmark () {
    foreach my $p (@per) {
        print "$p", '%-', $p+1, '%:';
        # total block = size/$bs
        # skip = (total_bs/100)*$p
        my $skip=0;
        $skip=int((($size/$bs)/100)*$p) + 1;
        my $dd="dd if=/dev/$disk of=/dev/null bs=$bs count=$opc skip=$skip";
        $dd = $dd . ' 2>&1 | tail -n 1 | awk -F, '."'".'{print $3}'."'";
        $result=`$dd`;
        chomp $result;
        print "$result\n";
    }
}

sub grok_disk () {
    if ( $disk eq '' ) {
        usage();
        exit 1;
    }
    if  ( ! -r "/dev/$disk" ) {
        print " cannot readable /dev/$disk\n";
        usage();
        exit 1;
    }
    if  ( ! -r "/sys/block/$disk/size" ) {
        print " cannot readable /sys/block/$disk/size\n";
        usage();
        exit 1;
    }
    $size=`cat /sys/block/$disk/size`*512;
    $opc=int($size/100/$bs);
}

sub show_disk_info () {
    my $k=1024;
    my $hdparm=`hdparm -i /dev/$disk | grep Model`;
    chomp $hdparm;
    print "Target Disk: $disk\n";
    print "Disk Model\n";
    print "$hdparm\n";
    printf("Disk Size: %dB = %dKB = %dMB = %dGB\n",
        $size,
        int($size/$k),
        int($size/$k/$k),
        int($size/$k/$k/$k)
    );
}

sub show_version () {
    print "Version: $version\n";
}

sub usage () {
    print <<EOF;
short description:
    Benchmark disk read I/O performance each 10% of total capacity.
    Each benchmark only about 1% disk capacity.

usage:
    $0 [disk_device]

example:
    \$ $0 sda
    Target Disk: sda
    Disk Model
     Model=Hitachi HDS721010CLA332
    Disk Size: 1000204886016B = 976762584KB = 953869MB = 931GB
    0%-1%: 275 MB/s
    10%-11%: 146 MB/s
    ....

EOF
    show_version();
    exit 1;
}

exit 1;

# vim:set ts=4 sw=4 expandtab:
