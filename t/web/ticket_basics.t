use strict;
use warnings;

use RT::Test tests => 47;

my $ticket = RT::Test->create_ticket(
    Subject => 'test ticket basics',
    Queue   => 1,
);

my ( $url, $m ) = RT::Test->started_ok;
ok( $m->login, 'logged in' );

# Failing test where the time units are not preserved when you
# click 'Add more files' on Display
my @form_tries = (
    {TimeEstimated => undef},
    {TimeEstimated => "1"},
    {TimeWorked    => undef},
    {TimeWorked    => "1"},
    {TimeLeft      => undef},
    {TimeLeft      => "1"},
);
for my $try (@form_tries) {
    $m->goto_create_ticket(1);
    $m->form_name('TicketCreate');
    for my $field (keys %$try) {
        $m->select("${field}-TimeUnits" => 'hours');
        $m->field($field => $try->{$field}) if defined $try->{$field};
        $m->click('AddMoreAttach');
        $m->form_name('TicketCreate');
        is($m->value("${field}-TimeUnits"), 'hours', 'time units stayed to "hours" after the form was submitted');
    }
}

$m->goto_update_ticket(ticket => $ticket, action => 'Respond');
$m->form_name('TicketUpdate');
$m->select("UpdateTimeWorked-TimeUnits" => 'hours');
$m->click('AddMoreAttach');
$m->form_name('TicketUpdate');
is($m->value("UpdateTimeWorked-TimeUnits"), 'hours', 'time units stayed to "hours" after the form was submitted');

my $cf = RT::Test->load_or_create_custom_field(
    Name       => 'CF1',
    Type       => 'Freeform',
    Pattern    => '.', # mandatory
    Queue      => 'General',
);

# More time unit testing by a failing CF validation
$m->get_ok($url.'/Admin/CustomFields/Objects.html?id='.$cf->id);
$m->form_name('CustomFieldAppliesTo');
$m->tick('AddCustomField-'.$cf->id => '0'); # Make CF global
$m->click('UpdateObjs');
$m->text_contains('Object created', 'CF applied globally');

$m->goto_create_ticket(1);

$m->form_name('TicketCreate');
$m->field('TimeWorked-TimeUnits' => 'hours');
$m->click('SubmitTicket');

$m->form_name('TicketCreate');
is($m->value("TimeWorked-TimeUnits"), 'hours', 'time units stayed to "hours" after the form was submitted');


# Test for time unit preservation in Jumbo
for my $try (@form_tries) {
    my $jumbo_ticket = RT::Test->create_ticket(
        Subject => 'test jumbo ticket basics',
        Queue   => 1,
    );

    $m->get_ok( $url . "/Ticket/ModifyAll.html?id=" . $jumbo_ticket->id );

    for my $field (keys %$try) {
        $m->form_name('ModifyTicket');
        $m->field("${field}" => "1");
        $m->select("${field}-TimeUnits" => 'hours');
        $m->click('AddMoreAttach');
        $m->form_name('ModifyTicket');
        is($m->value("${field}-TimeUnits"), 'hours', 'time units stayed to "hours" after the form was submitted');
    }
}
