#!/usr/bin/perl -w
# BEGIN BPS TAGGED BLOCK {{{
# 
# COPYRIGHT:
#  
# This software is Copyright (c) 1996-2004 Best Practical Solutions, LLC 
#                                          <jesse.com>
# 
# (Except where explicitly superseded by other copyright notices)
# 
# 
# LICENSE:
# 
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from www.gnu.org.
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
# 
# 
# CONTRIBUTION SUBMISSION POLICY:
# 
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to Best Practical Solutions, LLC.)
# 
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# Request Tracker, to Best Practical Solutions, LLC, you confirm that
# you are the copyright holder for those contributions and you grant
# Best Practical Solutions,  LLC a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.
# 
# END BPS TAGGED BLOCK }}}

=head1 NAME

rt-mailgate - Mail interface to RT3.

=cut

use strict;
use Test::More tests => 109;

use RT;
RT::LoadConfig();
RT::Init();
use RT::I18N;
use Digest::MD5 qw(md5_base64);

no warnings 'once';
my $url = join( ':', grep $_, "http://localhost", $RT::WebPort ) . $RT::WebPath ."/";

# Make sure that when we call the mailgate wrong, it tempfails

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url http://this.test.for.non-connection.is.expected.to.generate.an.error"), "Opened the mailgate - The error below is expected - $@");
print MAIL <<EOF;
From: root\@localhost
To: rt\@$RT::rtname
Subject: This is a test of new ticket creation

Foob!
EOF
close (MAIL);

# Check the return value
is ( $? >> 8, 75, "The error message above is expected The mail gateway exited with a failure. yay");


# {{{ Test new ticket creation by root who is privileged and superuser

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate  --debug --url $url --queue general --action correspond"), "Opened the mailgate - $!");
print MAIL <<EOF;
From: root\@localhost
To: rt\@$RT::rtname
Subject: This is a test of new ticket creation

Blah!
Foob!
EOF
close (MAIL);

#Check the return value
is ($? >> 8, 0, "The mail gateway exited normally. yay");

use RT::Tickets;
my $tickets = RT::Tickets->new($RT::SystemUser);
$tickets->OrderBy(FIELD => 'id', ORDER => 'DESC');
$tickets->Limit(FIELD => 'id', OPERATOR => '>', VALUE => '0');
my $tick = $tickets->First();
ok (UNIVERSAL::isa($tick,'RT::Ticket'));
ok ($tick->Id, "found ticket ".$tick->Id);
ok ($tick->Subject eq 'This is a test of new ticket creation', "Created the ticket");

# }}}

# {{{ Test new ticket creation without --action argument

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --debug --url $url --queue general"), "Opened the mailgate - $!");
print MAIL <<EOF;
From: root\@localhost
To: rt\@$RT::rtname
Subject: using mailgate without --action arg

Blah!
Foob!
EOF
close (MAIL);

#Check the return value
is ($? >> 8, 0, "The mail gateway exited normally. yay");

$tickets = RT::Tickets->new($RT::SystemUser);
$tickets->OrderBy(FIELD => 'id', ORDER => 'DESC');
$tickets->Limit(FIELD => 'id', OPERATOR => '>', VALUE => '0');
$tick = $tickets->First;
isa_ok ($tick,'RT::Ticket');
ok ($tick->Id, "found ticket ".$tick->Id);
is ($tick->Subject, 'using mailgate without --action arg', "using mailgate without --action arg");

# }}}

# {{{This is a test of new ticket creation as an unknown user

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue general --action correspond"), "Opened the mailgate - $!");
print MAIL <<EOF;
From: doesnotexist\@$RT::rtname
To: rt\@$RT::rtname
Subject: This is a test of new ticket creation as an unknown user

Blah!
Foob!
EOF
close (MAIL);
#Check the return value
is ($? >> 8, 0, "The mail gateway exited normally. yay");

$tickets = RT::Tickets->new($RT::SystemUser);
$tickets->OrderBy(FIELD => 'id', ORDER => 'DESC');
$tickets->Limit(FIELD => 'id' ,OPERATOR => '>', VALUE => '0');
$tick = $tickets->First();
ok ($tick->Id, "found ticket ".$tick->Id);
ok ($tick->Subject ne 'This is a test of new ticket creation as an unknown user', "failed to create the new ticket from an unprivileged account");
my $u = RT::User->new($RT::SystemUser);
$u->Load("doesnotexist\@$RT::rtname");
ok( !$u->Id, " user does not exist and was not created by failed ticket submission");


# }}}

# {{{ now everybody can create tickets.  can a random unkown user create tickets?

my $g = RT::Group->new($RT::SystemUser);
$g->LoadSystemInternalGroup('Everyone');
ok( $g->Id, "Found 'everybody'");

my ($val,$msg) = $g->PrincipalObj->GrantRight(Right => 'CreateTicket');
ok ($val, "Granted everybody the right to create tickets - $msg");


$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue general --action correspond"), "Opened the mailgate - $!");
print MAIL <<EOF;
From: doesnotexist\@$RT::rtname
To: rt\@$RT::rtname
Subject: This is a test of new ticket creation as an unknown user

Blah!
Foob!
EOF
close (MAIL);
#Check the return value
is ($? >> 8, 0, "The mail gateway exited normally. yay");


$tickets = RT::Tickets->new($RT::SystemUser);
$tickets->OrderBy(FIELD => 'id', ORDER => 'DESC');
$tickets->Limit(FIELD => 'id' ,OPERATOR => '>', VALUE => '0');
$tick = $tickets->First();
ok ($tick->Id, "found ticket ".$tick->Id);
ok ($tick->Subject eq 'This is a test of new ticket creation as an unknown user', "failed to create the new ticket from an unprivileged account");
 $u = RT::User->new($RT::SystemUser);
$u->Load("doesnotexist\@$RT::rtname");
ok( $u->Id != 0, " user does not exist and was created by ticket submission");

# }}}


# {{{  can another random reply to a ticket without being granted privs? answer should be no.


#($val,$msg) = $g->PrincipalObj->GrantRight(Right => 'CreateTicket');
#ok ($val, "Granted everybody the right to create tickets - $msg");

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue general --action correspond"), "Opened the mailgate - $!");
print MAIL <<EOF;
From: doesnotexist-2\@$RT::rtname
To: rt\@$RT::rtname
Subject: [$RT::rtname #@{[$tick->Id]}] This is a test of a reply as an unknown user

Blah!  (Should not work.)
Foob!
EOF
close (MAIL);
#Check the return value
is ($? >> 8, 0, "The mail gateway exited normally. yay");

$u = RT::User->new($RT::SystemUser);
$u->Load('doesnotexist-2@$RT::rtname');
ok( !$u->Id, " user does not exist and was not created by ticket correspondence submission");
# }}}


# {{{  can another random reply to a ticket after being granted privs? answer should be yes


($val,$msg) = $g->PrincipalObj->GrantRight(Right => 'ReplyToTicket');
ok ($val, "Granted everybody the right to reply to  tickets - $msg");

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue general --action correspond"), "Opened the mailgate - $!");
print MAIL <<EOF;
From: doesnotexist-2\@$RT::rtname
To: rt\@$RT::rtname
Subject: [$RT::rtname #@{[$tick->Id]}] This is a test of a reply as an unknown user

Blah!
Foob!
EOF
close (MAIL);
#Check the return value
is ($? >> 8, 0, "The mail gateway exited normally. yay");


$u = RT::User->new($RT::SystemUser);
$u->Load("doesnotexist-2\@$RT::rtname");
ok( $u->Id != 0, " user exists and was created by ticket correspondence submission");

# }}}

# {{{  can another random comment on a ticket without being granted privs? answer should be no.


#($val,$msg) = $g->PrincipalObj->GrantRight(Right => 'CreateTicket');
#ok ($val, "Granted everybody the right to create tickets - $msg");

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue general --action comment"), "Opened the mailgate - $!");
print MAIL <<EOF;
From: doesnotexist-3\@$RT::rtname
To: rt\@$RT::rtname
Subject: [$RT::rtname #@{[$tick->Id]}] This is a test of a comment as an unknown user

Blah!  (Should not work.)
Foob!
EOF
close (MAIL);

#Check the return value
is ($? >> 8, 0, "The mail gateway exited normally. yay");

$u = RT::User->new($RT::SystemUser);
$u->Load("doesnotexist-3\@$RT::rtname");
ok( !$u->Id, " user does not exist and was not created by ticket comment submission");

# }}}
# {{{  can another random reply to a ticket after being granted privs? answer should be yes


($val,$msg) = $g->PrincipalObj->GrantRight(Right => 'CommentOnTicket');
ok ($val, "Granted everybody the right to reply to  tickets - $msg");

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue general --action comment"), "Opened the mailgate - $!");
print MAIL <<EOF;
From: doesnotexist-3\@$RT::rtname
To: rt\@$RT::rtname
Subject: [$RT::rtname #@{[$tick->Id]}] This is a test of a comment as an unknown user

Blah!
Foob!
EOF
close (MAIL);

#Check the return value
is ($? >> 8, 0, "The mail gateway exited normally. yay");

$u = RT::User->new($RT::SystemUser);
$u->Load("doesnotexist-3\@$RT::rtname");
ok( $u->Id != 0, " user exists and was created by ticket comment submission");

# }}}

# {{{ Testing preservation of binary attachments

# Get a binary blob (Best Practical logo) 

# Create a mime entity with an attachment

use MIME::Entity;
my $entity = MIME::Entity->build( From => 'root@localhost',
                                 To => 'rt@localhost',
                                Subject => 'binary attachment test',
                                Data => ['This is a test of a binary attachment']);

# currently in lib/t/autogen

my $LOGO_FILE = $RT::MasonComponentRoot.'/NoAuth/images/bplogo.gif';

$entity->attach(Path => $LOGO_FILE,
                Type => 'image/gif',
                Encoding => 'base64');

# Create a ticket with a binary attachment
$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue general --action correspond"), "Opened the mailgate - $!");

$entity->print(\*MAIL);

close (MAIL);

#Check the return value
is ($? >> 8, 0, "The mail gateway exited normally. yay");

$tickets = RT::Tickets->new($RT::SystemUser);
$tickets->OrderBy(FIELD => 'id', ORDER => 'DESC');
$tickets->Limit(FIELD => 'id', OPERATOR => '>', VALUE => '0');
 $tick = $tickets->First();
ok (UNIVERSAL::isa($tick,'RT::Ticket'));
ok ($tick->Id, "found ticket ".$tick->Id);
ok ($tick->Subject eq 'binary attachment test', "Created the ticket - ".$tick->Id);

my $file = `cat $LOGO_FILE`;
ok ($file, "Read in the logo image");


diag( "for the raw file the content is ". md5_base64($file) );



# Verify that the binary attachment is valid in the database
my $attachments = RT::Attachments->new($RT::SystemUser);
$attachments->Limit(FIELD => 'ContentType', VALUE => 'image/gif');
ok ($attachments->Count == 1, 'Found only one gif in the database');
my $attachment = $attachments->First;
ok($attachment->Id);
my $acontent = $attachment->Content;

diag( "coming from the database, the content is ". md5_base64($acontent) );

is( $acontent, $file, 'The attachment isn\'t screwed up in the database.');
# Log in as root
use Getopt::Long;
use LWP::UserAgent;


# Grab the binary attachment via the web ui
my $ua      = LWP::UserAgent->new();

my $full_url = "$url/Ticket/Attachment/".$attachment->TransactionId."/".$attachment->id."/bplogo.gif?&user=root&pass=password";
my $r = $ua->get( $full_url);


# Verify that the downloaded attachment is the same as what we uploaded.
is($file, $r->content, 'The attachment isn\'t screwed up in download');



# }}}

# {{{ Simple I18N testing

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue general --action correspond"), "Opened the mailgate - $!");
                                                                         
print MAIL <<EOF;
From: root\@localhost
To: rtemail\@$RT::rtname
Subject: This is a test of I18N ticket creation
Content-Type: text/plain; charset="utf-8"

2 accented lines
\303\242\303\252\303\256\303\264\303\273
\303\241\303\251\303\255\303\263\303\272
bye
EOF
close (MAIL);

#Check the return value
is ($? >> 8, 0, "The mail gateway exited normally. yay");

my $unitickets = RT::Tickets->new($RT::SystemUser);
$unitickets->OrderBy(FIELD => 'id', ORDER => 'DESC');
$unitickets->Limit(FIELD => 'id', OPERATOR => '>', VALUE => '0');
my $unitick = $unitickets->First();
ok (UNIVERSAL::isa($unitick,'RT::Ticket'));
ok ($unitick->Id, "found ticket ".$unitick->Id);
ok ($unitick->Subject eq 'This is a test of I18N ticket creation', "Created the ticket - ". $unitick->Subject);



my $unistring = "\303\241\303\251\303\255\303\263\303\272";
Encode::_utf8_on($unistring);
is ($unitick->Transactions->First->Content, $unitick->Transactions->First->Attachments->First->Content, "Content is ". $unitick->Transactions->First->Attachments->First->Content);
ok($unitick->Transactions->First->Attachments->First->Content =~ /$unistring/i, $unitick->Id." appears to be unicode ". $unitick->Transactions->First->Attachments->First->Id);
# supposedly I18N fails on the second message sent in.

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue general --action correspond"), "Opened the mailgate - $!");
                                                                         
print MAIL <<EOF;
From: root\@localhost
To: rtemail\@$RT::rtname
Subject: This is a test of I18N ticket creation
Content-Type: text/plain; charset="utf-8"

2 accented lines
\303\242\303\252\303\256\303\264\303\273
\303\241\303\251\303\255\303\263\303\272
bye
EOF
close (MAIL);

#Check the return value
is ($? >> 8, 0, "The mail gateway exited normally. yay");

my $tickets2 = RT::Tickets->new($RT::SystemUser);
$tickets2->OrderBy(FIELD => 'id', ORDER => 'DESC');
$tickets2->Limit(FIELD => 'id', OPERATOR => '>', VALUE => '0');
my $tick2 = $tickets2->First();
ok (UNIVERSAL::isa($tick2,'RT::Ticket'));
ok ($tick2->Id, "found ticket ".$tick2->Id);
ok ($tick2->Subject eq 'This is a test of I18N ticket creation', "Created the ticket");



$unistring = "\303\241\303\251\303\255\303\263\303\272";
Encode::_utf8_on($unistring);

ok ($tick2->Transactions->First->Content =~ $unistring, "It appears to be unicode - ".$tick2->Transactions->First->Content);

# }}}


($val,$msg) = $g->PrincipalObj->RevokeRight(Right => 'CreateTicket');
ok ($val, $msg);

##=for later

SKIP: {
skip "Advanced mailgate actions require an unsafe configuration", 47 unless $RT::UnsafeEmailCommands;

#create new queue to be shure we don't mess with rights
use RT::Queue;
my $queue = RT::Queue->new($RT::SystemUser);
my ($qid) = $queue->Create( Name => 'ext-mailgate');
ok( $qid, 'queue created for ext-mailgate tests' );

# {{{ Check take and resolve actions

# create ticket that is owned by nobody
use RT::Ticket;
$tick = RT::Ticket->new($RT::SystemUser);
my ($id) = $tick->Create( Queue => 'ext-mailgate', Subject => 'test');
ok( $id, 'new ticket created' );
is( $tick->Owner, $RT::Nobody->Id, 'owner of the new ticket is nobody' );

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue ext-mailgate --action take"), "Opened the mailgate - $!");
print MAIL <<EOF;
From: root\@localhost
Subject: [$RT::rtname \#$id] test

EOF
close (MAIL);
is ($? >> 8, 0, "The mail gateway exited normally");

$tick = RT::Ticket->new($RT::SystemUser);
$tick->Load( $id );
is( $tick->Id, $id, 'load correct ticket');
is( $tick->OwnerObj->EmailAddress, 'root@localhost', 'successfuly take ticket via email');

# check that there is no text transactions writen
is( $tick->Transactions->Count, 2, 'no superfluous transactions');

my $status;
($status, $msg) = $tick->SetOwner( $RT::Nobody->Id, 'Force' );
ok( $status, 'successfuly changed owner: '. ($msg||'') );
is( $tick->Owner, $RT::Nobody->Id, 'set owner back to nobody');



$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $RT::WebURL --queue ext-mailgate --action take-correspond"), "Opened the mailgate - $@");
print MAIL <<EOF;
From: root\@localhost
Subject: [$RT::rtname \#$id] correspondence

test
EOF
close (MAIL);
is ($? >> 8, 0, "The mail gateway exited normally");

DBIx::SearchBuilder::Record::Cachable->FlushCache;

$tick = RT::Ticket->new($RT::SystemUser);
$tick->Load( $id );
is( $tick->Id, $id, "load correct ticket #$id");
is( $tick->OwnerObj->EmailAddress, 'root@localhost', 'successfuly take ticket via email');
my $txns = $tick->Transactions;
$txns->Limit( FIELD => 'Type', VALUE => 'Correspond');
$txns->OrderBy( FIELD => 'id', ORDER => 'DESC' );
# +1 because of auto open
is( $tick->Transactions->Count, 6, 'no superfluous transactions');
is( $txns->First->Subject, "[$RT::rtname \#$id] correspondence", 'successfuly add correspond within take via email' );

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue ext-mailgate --action resolve --debug"), "Opened the mailgate - $!");
print MAIL <<EOF;
From: root\@localhost
Subject: [$RT::rtname \#$id] test

EOF
close (MAIL);
is ($? >> 8, 0, "The mail gateway exited normally");

DBIx::SearchBuilder::Record::Cachable->FlushCache;

$tick = RT::Ticket->new($RT::SystemUser);
$tick->Load( $id );
is( $tick->Id, $id, 'load correct ticket');
is( $tick->Status, 'resolved', 'successfuly resolved ticket via email');
is( $tick->Transactions->Count, 7, 'no superfluous transactions');

use RT::User;
my $user = RT::User->new( $RT::SystemUser );
my ($uid) = $user->Create( Name => 'ext-mailgate',
			   EmailAddress => 'ext-mailgate@localhost',
			   Privileged => 1,
			   Password => 'qwe123',
			 );
ok( $uid, 'user created for ext-mailgate tests' );
ok( !$user->HasRight( Right => 'OwnTicket', Object => $queue ), "User can't own ticket" );

$tick = RT::Ticket->new($RT::SystemUser);
($id) = $tick->Create( Queue => $qid, Subject => 'test' );
ok( $id, 'create new ticket' );

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue ext-mailgate --action take"), "Opened the mailgate - $!");
print MAIL <<EOF;
From: ext-mailgate\@localhost
Subject: [example.com \#$id] test

EOF
close (MAIL);
is ( $? >> 8, 0, "mailgate exited normally" );
DBIx::SearchBuilder::Record::Cachable->FlushCache;

cmp_ok( $tick->Owner, '!=', $user->id, "we didn't change owner" );

($status, $msg) = $user->PrincipalObj->GrantRight( Object => $queue, Right => 'ReplyToTicket' );
ok( $status, "successfuly granted right: $msg" );
my $ace_id = $status;
ok( $user->HasRight( Right => 'ReplyToTicket', Object => $tick ), "User can reply to ticket" );

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue ext-mailgate --action correspond-take"), "Opened the mailgate - $!");
print MAIL <<EOF;
From: ext-mailgate\@localhost
Subject: [example.com \#$id] test

correspond-take
EOF
close (MAIL);
is ( $? >> 8, 0, "mailgate exited normally" );
DBIx::SearchBuilder::Record::Cachable->FlushCache;

cmp_ok( $tick->Owner, '!=', $user->id, "we didn't change owner" );
is( $tick->Transactions->Count, 3, "one transactions added" );

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue ext-mailgate --action take-correspond"), "Opened the mailgate - $!");
print MAIL <<EOF;
From: ext-mailgate\@localhost
Subject: [example.com \#$id] test

correspond-take
EOF
close (MAIL);
is ( $? >> 8, 0, "mailgate exited normally" );
DBIx::SearchBuilder::Record::Cachable->FlushCache;

cmp_ok( $tick->Owner, '!=', $user->id, "we didn't change owner" );
is( $tick->Transactions->Count, 3, "no transactions added, user can't take ticket first" );

# revoke ReplyToTicket right
use RT::ACE;
my $ace = RT::ACE->new($RT::SystemUser);
$ace->Load( $ace_id );
$ace->Delete;
my $acl = RT::ACL->new($RT::SystemUser);
$acl->Limit( FIELD => 'RightName', VALUE => 'ReplyToTicket' );
$acl->LimitToObject( $RT::System );
while( my $ace = $acl->Next ) {
	$ace->Delete;
}

ok( !$user->HasRight( Right => 'ReplyToTicket', Object => $tick ), "User can't reply to ticket any more" );


my $group = RT::Group->new( $RT::SystemUser );
ok( $group->LoadQueueRoleGroup( Queue => $qid, Type=> 'Owner' ), "load queue owners role group" );
$ace = RT::ACE->new( $RT::SystemUser );
($ace_id, $msg) = $group->PrincipalObj->GrantRight( Right => 'ReplyToTicket', Object => $queue );
ok( $ace_id, "Granted queue owners role group with ReplyToTicket right" );

($status, $msg) = $user->PrincipalObj->GrantRight( Object => $queue, Right => 'OwnTicket' );
ok( $status, "successfuly granted right: $msg" );
($status, $msg) = $user->PrincipalObj->GrantRight( Object => $queue, Right => 'TakeTicket' );
ok( $status, "successfuly granted right: $msg" );

$! = 0;
ok(open(MAIL, "|$RT::BinPath/rt-mailgate --url $url --queue ext-mailgate --action take-correspond"), "Opened the mailgate - $!");
print MAIL <<EOF;
From: ext-mailgate\@localhost
Subject: [example.com \#$id] test

take-correspond with reply right granted to owner role
EOF
close (MAIL);
is ( $? >> 8, 0, "mailgate exited normally" );
DBIx::SearchBuilder::Record::Cachable->FlushCache;

$tick->Load( $id );
is( $tick->Owner, $user->id, "we changed owner" );
ok( $user->HasRight( Right => 'ReplyToTicket', Object => $tick ), "owner can reply to ticket" );
is( $tick->Transactions->Count, 5, "transactions added" );


# }}}
};


1;
