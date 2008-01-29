# BEGIN BPS TAGGED BLOCK {{{
#
# COPYRIGHT:
#
# This software is Copyright (c) 1996-2007 Best Practical Solutions, LLC
#                                          <jesse@bestpractical.com>
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
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.gnu.org/copyleft/gpl.html.
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
# BEGIN LICENSE BLOCK
#
# Copyright (c) 1996-2003 Jesse Vincent <jesse@bestpractical.com>
#
# (Except where explictly superceded by other copyright notices)
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
# Unless otherwise specified, all modifications, corrections or
# extensions to this work which alter its source code become the
# property of Best Practical Solutions, LLC when submitted for
# inclusion in the work.
#
#
# END LICENSE BLOCK

use warnings;
use strict;

package RT::URI::t;

use RT::Model::Ticket;
use RT::URI::base;

use base qw/RT::URI::fsck_com_rt/;

my $scheme = "t";

=head2 parse_uri URI

When handed an t: URI, figures out if it is an RT ticket.  This is an
alternate short form of specifying a full ticket URI.


=cut

sub parse_uri {
    my $self = shift;
    my $uri  = shift;

    # "t:<articlenum>"
    # Pass this off to fsck_com_rt, which is equipped to deal with
    # tickets after stripping off the t: prefix.

    if ( $uri =~ /^$scheme:(\d+)/ ) {
        return $self->SUPER::parse_uri($1);
    } else {
        $self->{'uri'} = $uri;
        return undef;
    }
}

=head2 Scheme

Return the URI scheme 

=cut

sub scheme {
    return $scheme;
}

1;
