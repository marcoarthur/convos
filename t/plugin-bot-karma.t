use lib '.';
use t::Helper;
use Convos::Plugin::Bot::Action::Karma;

plan skip_all => 'TEST_BOT=1' unless $ENV{TEST_BOT} or $ENV{TEST_ALL};

$ENV{CONVOS_BOT_ALLOW_STANDALONE} = 1;
$ENV{CONVOS_BOT_EMAIL} ||= 'bot@convos.chat';

my $t     = t::Helper->t;
my $karma = Convos::Plugin::Bot::Action::Karma->new;

$karma->register($t->app->bot, {});

$karma->emit(message => {message => 'convos++'});
$karma->emit(message => {message => 'convos++ ai-ai'});
$karma->emit(message => {message => 'convos_bot++ # too cool'});

$karma->emit(message => {message => 'bla bla superman--'});
$karma->emit(message => {message => ' superman--'});
$karma->emit(message => {message => 'superman-- # not cool'});
$karma->emit(message => {message => 'superman++ rock around the sun'});

is $karma->reply({command => ''}),           undef, 'missing command';
is $karma->reply({command => 'kkarma foo'}), undef, 'invalid command';
is $karma->reply({command => 'karma foo?'}), '"foo" has neither negative nor positive karma.',
  'karma foo';
is $karma->reply({command => 'karma convos'}), 'Karma for convos is 2 (+2/-0) and reason "ai-ai".',
  'karma convos';

cmp_deeply(
  $karma->reply({command => 'karma superman?'}),
  any(
    'Karma for superman is -1 (+1/-2) and reason "not cool".',
    'Karma for superman is -1 (+1/-2) and reason "rock around the sun".'
  ),
  'karma superman',
);

done_testing;
