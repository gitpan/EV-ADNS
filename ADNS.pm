=head1 NAME

EV::ADNS - lightweight asynchronous dns queries using EV and libadns

=head1 SYNOPSIS

 use EV;
 use EV::ADNS;

 EV::ADNS::submit "example.com", EV::ADNS::r_a, 0, sub {
    my ($status, $expires, @a) = @_;
    warn $a[0]; # "127.13.166.3" etc.
 };

 EV::loop;

=head1 DESCRIPTION

This is a simple interface to libadns (asynchronous dns) that
integrates well and automatically into the EV event loop. The
documentation for libadns is vital to understand this module, see
L<http://www.chiark.greenend.org.uk/~ian/adns/>.

You can use it only with EV (directly or indirectly, e.g. via
L<Glib::EV>). Apart from loading and using the C<submit> function you need
not do anything (except run an EV event loop).

=head1 OVERVIEW

All the constants/enums from F<adns.h> are available in the EV::ADNS
namespace, without the C<adns_> prefix, e.g. C<adns_r_a> becomes
C<EV::ADNS::r_a>, C<adns__qtf_deref> becomes C<EV::ADNS::_qtf_deref> and
so on.

=head1 FUNCTIONS

=over 4

=item $query = EV::ADNS::submit "domain", $rrtype, $flags, $cb

Submits a new request to be handled. See the C<adns_submit> C function
description for more details. The function optionally returns a query
object which can be used to cancel an in-progress request. You do not need
to store the query object, even if you ignore it the query will proceed.

The callback will be invoked with a result status, the time the resource
record validity expires and zero or more resource records, one scalar per
result record. Example:

   sub adns_cb {
      my ($status, $expires, @rr) = @_;
      if ($status == EV::ADNS::s_ok) {
         use JSON::XS;
         warn encode_json \@rr;
      }
   }

The format of result records varies considerably, here is some cursory
documentation of how each record will look like, depending on the query
type:

=over 4

=item EV::ADNS::rr_a

An IPv4 address in dotted quad (string) form.

=item EV::ADNS::r_ns_raw, EV::ADNS::r_cname, EV::ADNS::r_ptr, EV::ADNS::r_ptr_raw

The resource record as a simple string.

=item EV::ADNS::r_txt

An arrayref of strings.

=item EV::ADNS::r_ns

A "host address", a hostname with any number of addresses (hint records).

Currently only the hostname will be stored, so this is alway an arrayref
with a single element of the hostname. Future versions might add
additional address entries.

=item EV::ADNS::r_hinfo

An arrayref consisting of the two strings.

=item EV::ADNS::r_rp, EV::ADNS::r_rp_raw

An arrayref with two strings.

=item EV::ADNS::r_mx

An arrayref consisting of the priority and a "host address" (see
C<EV::ADNS::r_ns>). Example:

   [10, "mail10.example.com"]

=item EV::ADNS::r_mx_raw

An arrayref consisting of the priority and the hostname, e.g. C<[10,
"mail.example.com"]>.

=item EV::ADNS::r_soa, EV::ADNS::r_soa_raw

An arrayref consisting of the primary nameserver, admin name, serial,
refresh, retry expire and minimum times, e.g.:

  ["ns.example.net", "hostmaster@example.net", 2000001102, 86400, 21600, 2592000, 172800]

The "raw" form doesn't mangle the e-mail address.

=item EV::ADNS::r_srv_raw

An arrayref consisting of the priority, weight, port and hostname, e.g.:

   [10, 10, 5060, "sip1.example.net"]

=item EV::ADNS::r_srv

The same as C<EV::ADNS::r_srv_raw>, but the hostname is replaced by a "host
address" (see C<EV::ADNS::r_ns>).

=item EV::ADNS::r_unknown

A single octet string with the raw contents.

=item anything else

Currently C<undef>.

=back

=item $query->cancel

Cancels a request that is in progress.

=back

=cut

package EV::ADNS;

use Carp ();
use EV ();

BEGIN {
   $VERSION = '1.0';

   require XSLoader;
   XSLoader::load (EV::ADNS, $VERSION);
}

=head1 SEE ALSO

L<EV>, L<Net::ADNS> another interface to adns, maybe better, but without
real support to integrate it into other event loops.

=head1 AUTHOR

 Marc Lehmann <schmorp@schmorp.de>
 http://home.schmorp.de/

=cut

1

