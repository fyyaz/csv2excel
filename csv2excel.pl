#! /usr/bin/perl

use 5.010;
use strict;
use warnings;
use Data::Dumper qw (Dumper);
use Excel::Writer::XLSX;
use Text::CSV::Simple;

sub usage { 
    say "USAGE: \n -i <input file name(s)> -o <output file name>";
}

unless(@ARGV > 0){
    usage;
    exit;
}

my @input_file;
my $output_file;
my $i = 1;

if ($ARGV[0] eq "-i"){ #read list of input file names
    while ($ARGV[$i] ne "-o" and $i < @ARGV){
        chomp $ARGV[$i];
        push @input_file, $ARGV[$i];
        $i++
    }
    if ($i == @ARGV){
        usage;
        exit;
    }
}else{
    usage;
    exit;
}
if ($ARGV[$i] eq "-o"){ #check if output file specified first
    if (defined $ARGV[$i + 1]) {
        chomp $ARGV[$i + 1];
        $output_file = $ARGV[$i + 1];
    }else{
        say "need output file name";
        usage;
        exit;
    }
} else {
    usage;
    exit;
}

#print Dumper(\@input_file);
#print Dumper($output_file);


my $book = Excel::Writer::XLSX->new($output_file);
my $sheet = $book->add_worksheet;

my $used_col_count = 0;

foreach my $file_name (@input_file){
    my $parser = Text::CSV::Simple->new;
    my @data = $parser->read_file($file_name);

    for (my $i = 0; $i<@data; $i++){
        for (my $j = 0; $j<@{$data[$i]}; $j++){
            my $write_data = $data[$i][$j];
            if ($i == 0) #headers modified with the file name
            {
                $write_data = $write_data . "\/" . $file_name;
            }
            $sheet->write($i, $j + $used_col_count, $write_data);
        }
    }
    $used_col_count += @{$data[0]}; #move columns by number of headers already written;
}

$book->close;




