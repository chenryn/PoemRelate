#!env perl -w
use HTML::Table::FromDatabase;
use Data::Dumper;
use DBI;
use DBD::mysql;
my $dbh = DBI->connect("DBI:mysql:dancer:localhost",'dancer','dancer');
my $sth = $dbh->prepare('select name, count(name) count from food group by name');
$sth->execute();
my $table = HTML::Table::FromDatabase->new( -sth => $sth );
$table->print();

