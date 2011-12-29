package PoemRelate;
use Dancer ':syntax';
use Dancer::Plugin::Redis;
use Dancer::Plugin::Database;

our $VERSION = '0.1';

get '/' => sub {
    my $sth = database->prepare('select author, count(author) count from poem group by author');
    $sth->execute();
    my @index;
    while( my $ref = $sth->fetchrow_arrayref ) {
        push @index, $ref;
    };
    template 'index', {index => \@index};
};

get '/list/:author' => sub {
    my $sth = database->prepare('select id, title from poem order by id');
    $sth->execute(params->{'author'});
    my @titles;
    while( my $ref = $sth->fetchrow_arrayref ) {
        push @titles, $ref;
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
