package PoemRelate;
use Dancer ':syntax';
use Dancer::Plugin::Redis;
use Dancer::Plugin::Database;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

true;
