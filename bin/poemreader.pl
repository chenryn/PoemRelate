#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use PDF::API2;
use Text::Extract::Word;

sub read_word {
    my $filename = shift;
    my $word = Text::Extract::Word->new("$filename");
    return $word->get_body();
};

sub read_pdf {
    my $filename = shift;
    my $pdf = PDF::API2->open("$filename");
    my $page1 = $pdf->openpage(-1);
    return $page1;
};

print Dumper read_pdf $ARGV[0];
