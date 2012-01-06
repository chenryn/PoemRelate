#!env perl
package PoemRelate::Gearman;
use warnings;
use strict;
use Gearman::XS::Client;
use Gearman::XS::Worker;
use Lingua::ZH::WordSegmenter;

sub new {
    my $class = shift;
    my $self = bless { @_ }, $class;
    $self->{seg} = Lingua::ZH::WordSegmenter->new();
    $self->{client} = Gearman::XS::Client->new();
    $self->{worker} = Gearman::XS::Worker->new();
    return $self;
};

sub storage {
    my $self = shift;
    my $worker = $self->{worker};
    $worker->add_function( 'storage', 0, sub {
        my $job = shift;
        my $poem = $job->workload();
        my $sth = $self->{dbh}->prepare('insert into poem (type, title, author, content) value (?,?,?,?)');
        $sth->execute($poem);
    }, $options );
    $worker->work() while true;
};

1;
