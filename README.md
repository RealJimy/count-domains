Count domains
=============

What is that?
-------------
It's a Perl script which can read e-mail address list from file and calculate the frequency of using domain names

Usage
-----
$ perl count_domains.pl emails.txt

Dependencies
------------
- Encode
- File::Basename
- Mail::RFC822::Address
- Modern::Perl
- Net::IDN::Encode
