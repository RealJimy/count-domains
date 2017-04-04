#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 38;
use Test::Exception;

require_ok('count_domains.pl');


# trim
can_ok('MyDomainCounter', 'trim');
ok(MyDomainCounter->trim("qwe\n") eq "qwe");
ok(MyDomainCounter->trim("\t q \n we  \r\n ") eq "q \n we");


# extract_domain
my %emails_for_test = (
    'info@mail.ru'                      => 'mail.ru',
    'support@vk.com'                    => 'vk.com',
    'ddd@rambler.ru'                    => 'rambler.ru',
    'roxette@mail.ru'                   => 'mail.ru',
    'sdfsdf@@@@@rdfdf'                  => '',
    '@rdfdf'                            => '',
    '@rdfdf.com'                        => '',
    '.@rdfdf.com'                       => '',
    'sdfsdf@'                           => '',
    'example@localhost'                 => 'localhost',
    'example@99.88.77.66'               => '99.88.77.66',
    'иван@иванов.рф'                    => 'иванов.рф',
    'иван@reg.рф'                       => 'reg.рф',
    'иван@рег.рф'                       => 'рег.рф',
    'ivan@xn--c1ad6a.xn--p1ai'          => 'рег.рф',
    'info@email.com.ru'                 => 'email.com.ru',
    'in-fo@email.рег.рф'                => 'email.рег.рф',
    'in.fo@email.xn--c1ad6a.xn--p1ai'   => 'email.рег.рф',
);
can_ok('MyDomainCounter', 'extract_domain');
foreach my $email (keys %emails_for_test) {
    ok(MyDomainCounter->extract_domain($email) eq $emails_for_test{$email}) or note("Wrong domain from $email");
}
ok(MyDomainCounter->extract_domain() eq '', "Domain from empty");


# prepare_results
my %domains = (
    'abc.com' => 3,
    'def.com' => 2,
);
can_ok('MyDomainCounter', 'prepare_results');
ok(MyDomainCounter->prepare_results(\%domains, 5) eq "abc.com 3\ndef.com 2\nINVALID 5\n");
ok(MyDomainCounter->prepare_results(\%domains) eq "abc.com 3\ndef.com 2\nINVALID 0\n");
ok(MyDomainCounter->prepare_results() eq "INVALID 0\n");


# get_file_path
can_ok('MyDomainCounter', 'get_file_path');
dies_ok {MyDomainCounter->get_file_path()} 'expecting to die';
dies_ok {MyDomainCounter->get_file_path('qwerty')} 'expecting to die';
dies_ok {MyDomainCounter->get_file_path('..')} 'expecting to die';
dies_ok {MyDomainCounter->get_file_path('/')} 'expecting to die';
open(my $fht, '>>', 'test');
close($fht);
ok(MyDomainCounter->get_file_path('test') eq "./test");
unlink 'test';


# processing_emails
can_ok('MyDomainCounter', 'processing_emails');
my $test_file =
'info@mail.ru
support@vk.com
	ddd@rambler.ru
roxette@mail.ru
sdfsdf@@@@@rdfdf
@rdfdf
@rdfdf.com
.@rdfdf.com
sdfsdf@
example@localhost 
 example@99.88.77.66
иван@иванов.рф
иван@reg.рф 
иван@рег.рф

ivan@xn--c1ad6a.xn--p1ai
info@email.com.ru
info@email.рег.рф
in.fo@email.xn--c1ad6a.xn--p1ai
';
my $processing_emails_result_expected = {
    'email.рег.рф'  => 2,
    'mail.ru'       => 2,
    'рег.рф'        => 2,
    'vk.com'        => 1,
    '99.88.77.66'   => 1,
    'rambler.ru'    => 1,
    'email.com.ru'  => 1,
    'localhost'     => 1,
    'иванов.рф'     => 1,
    'reg.рф'        => 1,
};
my $test_file_name = './email.txt';
open( my $test_fh, '+>>', $test_file_name);
print $test_fh $test_file;
seek($test_fh, 0, 0);
my ($processing_emails_result_fact, $invalid_emails) = MyDomainCounter->processing_emails($test_fh);
is_deeply($processing_emails_result_fact, $processing_emails_result_expected);
ok($invalid_emails == 5);
close $test_fh;
unlink $test_file_name;


# run
dies_ok {MyDomainCounter->run()} 'expecting to die';




