#!env perl
use warnings;
use strict;
use Lingua::ZH::WordSegmenter;
use DBI;
use DBD::mysql;
use Redis;

#####Poem In
my ($type, $title, $author, $content) = @ARGV;
my $dbh = DBI->connect('DBI:mysql:poem:localhost', 'poem', 'poem', {RaiseError => 1});
my $create_sth = $dbh->prepare('insert into poem (type, title, author, content) value (?,?,?,?)');
$create_sth->execute($type, $title, $author, $content);
my $read_sth = $dbh->prepare('select id from poem order by id desc limit 0,1 ');
$read_sth->execute();
my $article_id = $read_sth->fetchrow_arrayref->[0];

my $segmenter = Lingua::ZH::WordSegmenter->new();
my @words_array = split " ",$segmenter->seg($content, 'utf8');

my $redis = Redis->new( server => '127.0.0.1:6379' );
$redis->sadd($article_id, $_) for @words_array;
foreach (1 .. $article_id - 1 ) {
    my @sinter = $redis->sinter($_, $article_id);
    next unless @sinter;
    my @relate;
    push @relate, [$_, $#sinter] unless $#sinter < $relate[-1]->[1];
    shift @relate if $#relate > 9;
    grep { $redis->sadd('relate:'.$article_id, $_->[0]) } @relate if $_ + 1 == $article_id;
};

#####Poem Out
my $rand_id = $redis->srandmember('relate:'.$article_id);
my $rand_sth = $dbh->prepare('select * from poem where id = ?');
$rand_sth->execute($rand_id);
my @rand_article = $rand_sth->fetchrow_array;
