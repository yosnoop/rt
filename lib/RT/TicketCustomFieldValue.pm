

# $Header$

# Autogenerated by DBIx::SearchBuilder factory (by <jesse@bestpractical.com>)
# WARNING: THIS FILE IS AUTOGENERATED. ALL CHANGES TO THIS FILE WILL BE LOST.  
# 
# !! DO NOT EDIT THIS FILE !!
#


=head1 NAME

RT::TicketCustomFieldValue


=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut

package RT::TicketCustomFieldValue;
use RT::Record; 
use RT::CustomFields;
use RT::Tickets;


use vars qw( @ISA );
@ISA= qw( RT::Record );

sub _Init {
  my $self = shift; 

  $self->Table('TicketCustomFieldValues');
  $self->SUPER::_Init(@_);
}





=item Create PARAMHASH

Create takes a hash of values and creates a row in the database:

  int(11) 'Ticket'.
  int(11) 'CustomField'.
  varchar(255) 'Content'.

=cut




sub Create {
    my $self = shift;
    my %args = ( 
                Ticket => '0',
                CustomField => '0',
                Content => '',

		  @_);
    $self->SUPER::Create(
                         Ticket => $args{'Ticket'},
                         CustomField => $args{'CustomField'},
                         Content => $args{'Content'},
);

}



=item id

Returns the current value of id. 
(In the database, id is stored as int(11).)


=cut


=item Ticket

Returns the current value of Ticket. 
(In the database, Ticket is stored as int(11).)



=item SetTicket VALUE


Set Ticket to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Ticket will be stored as a int(11).)


=cut


=item TicketObj

Returns the Tickets Object which has the id returned by Ticket


=cut

sub TicketObj {
	my $self = shift;
	my $Ticket = new RT::Tickets($self->CurrentUser);
	$Ticket->Load($self->Ticket());
	return($Ticket);
}

=item CustomField

Returns the current value of CustomField. 
(In the database, CustomField is stored as int(11).)



=item SetCustomField VALUE


Set CustomField to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, CustomField will be stored as a int(11).)


=cut


=item CustomFieldObj

Returns the CustomFields Object which has the id returned by CustomField


=cut

sub CustomFieldObj {
	my $self = shift;
	my $CustomField = new RT::CustomFields($self->CurrentUser);
	$CustomField->Load($self->CustomField());
	return($CustomField);
}

=item Content

Returns the current value of Content. 
(In the database, Content is stored as varchar(255).)



=item SetContent VALUE


Set Content to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Content will be stored as a varchar(255).)


=cut


=item Creator

Returns the current value of Creator. 
(In the database, Creator is stored as int(11).)


=cut


=item Created

Returns the current value of Created. 
(In the database, Created is stored as datetime.)


=cut


=item LastUpdatedBy

Returns the current value of LastUpdatedBy. 
(In the database, LastUpdatedBy is stored as int(11).)


=cut


=item LastUpdated

Returns the current value of LastUpdated. 
(In the database, LastUpdated is stored as datetime.)


=cut



sub _ClassAccessible {
    {
     
        id =>
		{read => 1, type => 'int(11)', default => ''},
        Ticket => 
		{read => 1, write => 1, type => 'int(11)', default => '0'},
        CustomField => 
		{read => 1, write => 1, type => 'int(11)', default => '0'},
        Content => 
		{read => 1, write => 1, type => 'varchar(255)', default => ''},
        Creator => 
		{read => 1, auto => 1, type => 'int(11)', default => ''},
        Created => 
		{read => 1, auto => 1, type => 'datetime', default => ''},
        LastUpdatedBy => 
		{read => 1, auto => 1, type => 'int(11)', default => ''},
        LastUpdated => 
		{read => 1, auto => 1, type => 'datetime', default => ''},

 }
};


        eval "require RT::TicketCustomFieldValue_Overlay";
        if ($@ && $@ !~ /^Can't locate/) {
            die $@;
        };

        eval "require RT::TicketCustomFieldValue_Local";
        if ($@ && $@ !~ /^Can't locate/) {
            die $@;
        };




=head1 SEE ALSO

This class allows "overlay" methods to be placed
into the following files _Overlay is for a System overlay by the original author,
while _Local is for site-local customizations.  

These overlay files can contain new subs or subs to replace existing subs in this module.

If you'll be working with perl 5.6.0 or greater, each of these files should begin with the line 

   no warnings qw(redefine);

so that perl does not kick and scream when you redefine a subroutine or variable in your overlay.

RT::TicketCustomFieldValue_Overlay, RT::TicketCustomFieldValue_Local

=cut


1;
