use warnings;
use strict;

use RT::Test tests => 11;
use Digest::SHA 'sha1_hex';
use File::Temp 'tempfile';

my $content = 'a' x 1000 . 'b' x 10;
my ( $fh, $path ) = tempfile( UNLINK => 1, SUFFIX => '.txt' );
print $fh $content;
close $fh;

my $sha1 = sha1_hex($content);
my $name = ( File::Spec->splitpath($path) )[2];

RT->Config->Set( 'MaxAttachmentSize', 1000 );
RT->Config->Set( 'TruncateLongAttachments', '0' );
RT->Config->Set( 'DropLongAttachments',     '1' );

my ( $baseurl, $m ) = RT::Test->started_ok;
ok $m->login, 'logged in';

my $queue = RT::Test->load_or_create_queue( Name => 'General' );
ok( $queue->id, "Loaded General queue" );
$m->get_ok( $baseurl . '/Ticket/Create.html?Queue=' . $queue->id );
$m->content_contains( "Create a new ticket", 'ticket create page' );

$m->form_name('TicketCreate');
$m->field( 'Subject', 'Attachments dropping test' );
$m->field( 'Attach',  $path );
$m->field( 'Content', 'Some content' );
$m->submit;
is( $m->status, 200, "request successful" );

$m->content_contains( "$name was dropped, sha1 is $sha1.", 'dropped message' );
$m->follow_link_ok( { text => "Download $name" } );
is( $m->content, 'Large attachment dropped', 'dropped $name' );
