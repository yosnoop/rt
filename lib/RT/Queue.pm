

# $Header$

# Autogenerated by DBIx::SearchBuilder factory (by <jesse@bestpractical.com>)
# WARNING: THIS FILE IS AUTOGENERATED. ALL CHANGES TO THIS FILE WILL BE LOST.  
# 
# !! DO NOT EDIT THIS FILE !!
#


=head1 NAME

RT::Queue


=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=cut

package RT::Queue;
use RT::Record; 


use vars qw( @ISA );
@ISA= qw( RT::Record );

sub _Init {
  my $self = shift; 

  $self->Table('Queues');
  $self->SUPER::_Init(@_);
}





=item Create PARAMHASH

Create takes a hash of values and creates a row in the database:

  varchar(120) 'Name'.
  varchar(120) 'Description'.
  varchar(120) 'CorrespondAddress'.
  varchar(120) 'CommentAddress'.
  int(11) 'InitialPriority'.
  int(11) 'FinalPriority'.
  int(11) 'DefaultDueIn'.
  smallint(6) 'Disabled'.

=cut




sub Create {
    my $self = shift;
    my %args = ( 
                Name => '',
                Description => '',
                CorrespondAddress => '',
                CommentAddress => '',
                InitialPriority => '',
                FinalPriority => '',
                DefaultDueIn => '',
                Disabled => '0',

		  @_);
    $self->SUPER::Create(
                         Name => $args{'Name'},
                         Description => $args{'Description'},
                         CorrespondAddress => $args{'CorrespondAddress'},
                         CommentAddress => $args{'CommentAddress'},
                         InitialPriority => $args{'InitialPriority'},
                         FinalPriority => $args{'FinalPriority'},
                         DefaultDueIn => $args{'DefaultDueIn'},
                         Disabled => $args{'Disabled'},
);

}



=item id

Returns the current value of id. 
(In the database, id is stored as int(11).)


=cut


=item Name

Returns the current value of Name. 
(In the database, Name is stored as varchar(120).)



=item SetName VALUE


Set Name to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Name will be stored as a varchar(120).)


=cut


=item Description

Returns the current value of Description. 
(In the database, Description is stored as varchar(120).)



=item SetDescription VALUE


Set Description to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Description will be stored as a varchar(120).)


=cut


=item CorrespondAddress

Returns the current value of CorrespondAddress. 
(In the database, CorrespondAddress is stored as varchar(120).)



=item SetCorrespondAddress VALUE


Set CorrespondAddress to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, CorrespondAddress will be stored as a varchar(120).)


=cut


=item CommentAddress

Returns the current value of CommentAddress. 
(In the database, CommentAddress is stored as varchar(120).)



=item SetCommentAddress VALUE


Set CommentAddress to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, CommentAddress will be stored as a varchar(120).)


=cut


=item InitialPriority

Returns the current value of InitialPriority. 
(In the database, InitialPriority is stored as int(11).)



=item SetInitialPriority VALUE


Set InitialPriority to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, InitialPriority will be stored as a int(11).)


=cut


=item FinalPriority

Returns the current value of FinalPriority. 
(In the database, FinalPriority is stored as int(11).)



=item SetFinalPriority VALUE


Set FinalPriority to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, FinalPriority will be stored as a int(11).)


=cut


=item DefaultDueIn

Returns the current value of DefaultDueIn. 
(In the database, DefaultDueIn is stored as int(11).)



=item SetDefaultDueIn VALUE


Set DefaultDueIn to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, DefaultDueIn will be stored as a int(11).)


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


=item Disabled

Returns the current value of Disabled. 
(In the database, Disabled is stored as smallint(6).)



=item SetDisabled VALUE


Set Disabled to VALUE. 
Returns (1, 'Status message') on success and (0, 'Error Message') on failure.
(In the database, Disabled will be stored as a smallint(6).)


=cut



sub _ClassAccessible {
    {
     
        id =>
		{read => 1, type => 'int(11)', default => ''},
        Name => 
		{read => 1, write => 1, type => 'varchar(120)', default => ''},
        Description => 
		{read => 1, write => 1, type => 'varchar(120)', default => ''},
        CorrespondAddress => 
		{read => 1, write => 1, type => 'varchar(120)', default => ''},
        CommentAddress => 
		{read => 1, write => 1, type => 'varchar(120)', default => ''},
        InitialPriority => 
		{read => 1, write => 1, type => 'int(11)', default => ''},
        FinalPriority => 
		{read => 1, write => 1, type => 'int(11)', default => ''},
        DefaultDueIn => 
		{read => 1, write => 1, type => 'int(11)', default => ''},
        Creator => 
		{read => 1, auto => 1, type => 'int(11)', default => ''},
        Created => 
		{read => 1, auto => 1, type => 'datetime', default => ''},
        LastUpdatedBy => 
		{read => 1, auto => 1, type => 'int(11)', default => ''},
        LastUpdated => 
		{read => 1, auto => 1, type => 'datetime', default => ''},
        Disabled => 
		{read => 1, write => 1, type => 'smallint(6)', default => '0'},

 }
};


        eval "require RT::Queue_Overlay";
        if ($@ && $@ !~ /^Can't locate/) {
            die $@;
        };

        eval "require RT::Queue_Local";
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

RT::Queue_Overlay, RT::Queue_Local

=cut


1;
