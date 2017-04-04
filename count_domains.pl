#!/usr/bin/perl
package MyDomainCounter;

# The module counts domain names from a file with emails and prints ordered results to STDOUT

use Modern::Perl;
use File::Basename qw(dirname);
use Mail::RFC822::Address qw(valid);
use Net::IDN::Encode qw(domain_to_unicode);
use Encode qw(_utf8_off);

# Run if it started from command line
__PACKAGE__->run(@ARGV) unless caller();

sub run {
    my ( $class, @my_argv ) = @_;

    die "File name is expected!" if scalar(@my_argv) < 1;

    my $file_path = $class->get_file_path( $my_argv[0] );

    open( my $file_handler, '<:encoding(UTF-8)', $file_path )
      || die "Cannot open file $file_path";

    my ( $domains, $invalid_emails_cnt ) =
      $class->processing_emails($file_handler);

    close($file_handler);

    print $class->prepare_results( $domains, $invalid_emails_cnt );
}

# Check if file exist and can be read; return file with path if success
sub get_file_path {
    my ( $class, $file_name ) = @_;

    die "File name is expected!" unless $file_name;
    my $dir_name  = File::Basename::dirname(__FILE__);
    my $file_path = $dir_name . '/' . $file_name;

    die "File ($file_path) does not exist or cannot be read!"
      if !-e $file_path || !-f $file_path || !-r $file_path;

    return $file_path;
}

# Read lines from stream, validate emails and extract domains
# return hash reference of domains and amount invalid emails
sub processing_emails {
    my ( $class, $fh ) = @_;

    my $invalid_emails_cnt = 0;
    my %result;

    while ( my $email = <$fh> ) {
        $email = $class->trim($email);
        if ($email) {
            if ( my $domain = $class->extract_domain($email) ) {
                $result{$domain}++;
            }
            else {
                $invalid_emails_cnt++;
            }
        }
    }

    return ( \%result, $invalid_emails_cnt );

}

# Convert counted domains and invalid emails amount to a string
# $domains - hash reference of domains (key - domain, value - amount of emails}
sub prepare_results {
    my ( $class, $domains, $invalid_emails_cnt, $stream ) = @_;

    $invalid_emails_cnt ||= 0;
    my $result = '';
    foreach
      my $domain ( sort { $domains->{$b} <=> $domains->{$a} } keys %$domains )
    {
        $result .= "$domain $domains->{$domain}\n";
    }
    $result .= "INVALID $invalid_emails_cnt\n";
    return $result;
}

# Extract domain name from email and convert Punycode into Unicode if nessecery
# param $email
# return $domain
sub extract_domain {
    my ( $class, $email ) = @_;

    my $domain = '';
    if ( Mail::RFC822::Address::valid($email) ) {
        ( $domain = $email ) =~ s/^.+?@//;
        if ( $domain =~ /xn--/ ) {
            $domain = Net::IDN::Encode::domain_to_unicode($domain);
        }
        Encode::_utf8_off($domain);
    }
    return $domain;
}

# Replace empty chars at the ends of string
sub trim {
    my ( $class, $str ) = @_;

    $str =~ s/^\s+|\s+$//g;
    return $str;
}

__END__
