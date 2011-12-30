package PoemRelate;
use Dancer ':syntax';
use Dancer::Plugin::Redis;
use Dancer::Plugin::Database;

our $VERSION = '0.1';

get '/' => sub {
    my $sth = database->prepare('select author name, count(author) count from poem group by author');
    $sth->execute();
    my @index;
    my $i = 0;
    my $j = 0;
    while( my $ref = $sth->fetchrow_hashref ) {
        $i++ unless $j % 5 or $j == 0;
        push $index[$i], $ref;
        $j++;
    };
    template 'index', {index => \@index};
};

get '/list/:author' => sub {
    my $sth = database->prepare('select id, title from poem order by id where author = ?');
    $sth->execute(params->{'author'});
    my @titles;
    my $i = 0;
    my $j = 0;
    while( my $ref = $sth->fetchrow_hashref ) {
        $i++ unless $j % 5 or $j == 0;
        push $titles[$i], $ref;
        $j++;
    };
    template 'list', { author => params->{'author'}, titles => \@titles };
};

get '/poem/:titleid' => sub {
    my $sth = database->prepare('select title, author, content from poem where id = ?');
    $sth->execute(params->{'titleid'});
    $mainref = $sth->fetchrow_hashref;
    my $relate_id = redis->srandmember('relate:'params->{'titleid'});
    $sth->execute($relate_id);
    $relateref = $sth->fetchrow_hashref;
    template 'poem', { main => $mainref, relate => $relateref };
};

true;
