package Calendar::Hijri;

use warnings;
use strict;

=head1 NAME

Calendar::Hijri - Interface to Islamic Calendar.

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

use Carp;
use Readonly;
use Time::Local;
use Data::Dumper;
use Time::localtime;
use List::Util qw/min/;
use POSIX qw/floor ceil/;
use Date::Calc qw/Delta_Days Day_of_Week Add_Delta_Days/;

Readonly my $ISLAMIC_EPOCH   => 1948439.5;
Readonly my $GREGORIAN_EPOCH => 1721425.5;

Readonly my $MONTHS =>
[
    undef,
    q/Muharram/, q/Safar/   , q/Rabi' al-awwal/, q/Rabi' al-thani/, q/Jumada al-awwal/,  q/Jumada al-thani/,
    q/Rajab/   , q/Sha'aban/, q/Ramadan/       , q/Shawwal/       , q/Dhu al-Qi'dah/   , q/Dhu al-Hijjah/  ,
];

Readonly my $LEAP_YEAR_MOD  => [ 2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29 ];

sub new 
{
    my $class = shift;
    my $yyyy  = shift;
    my $mm    = shift;
    my $dd    = shift;
    my $self  = {};
    bless $self, $class;

    if (defined($yyyy) && defined($mm) && defined($dd))
    {
        _validate_date($yyyy, $mm, $dd)
    }
    else
    {
        ($yyyy, $mm, $dd) = $self->today();
    }

    $self->{yyyy} = $yyyy;
    $self->{mm}   = $mm;
    $self->{dd}   = $dd;

    return $self;
}

=head1 DESCRIPTION

Hijri Calendar begins with the migration from Mecca to Medina of Mohammad (pbuh),  the Prophet
of Islam, an event  known  as the Hegira. The initials A.H.  before a date mean "anno Hegirae"
or "after Hegira".  The  first  day  of the year is fixed in the Quran as the first day of the
month of Muharram. In 17 AH Umar I, the second caliph, established the beginning of the era of
the Hegira (1 Muharram 1 AH) as the date that is 16 July 622 CE in the Julian Calendar.

The  years are lunar and consist of 12 lunar months. There is no intercalary period, since the
Quran ( Sura IX, verses 36,37 )  sets  the calendar year at 12 months. Because the year in the
Hijri  calendar is shorter than a solar year, the months drift with respect to the seasons, in
a cycle 32.50 years.

NOTE: The Hijri date produced by this module can have +1/-1 day error.

=head1 MONTHS

    +--------+-----------------+
    | Number | Name            |
    +--------+-----------------+
    |   1    | Muharram        |
    |   2    | Safar           |
    |   3    | Rabi' al-awwal  |
    |   4    | Rabi' al-thani  |
    |   5    | Jumada al-awwal |
    |   6    | Jumada al-thani |
    |   7    | Rajab           |
    |   8    | Sha'aban        |
    |   9    | Ramadan         |
    |  10    | Shawwal         |
    |  11    | Dhu al-Qi'dah   |
    |  12    | Dhu al-Hijjah   |
    +--------+-----------------+

=head1 METHODS

=head2 today()

Return today's date is Hijri Calendar as list in the format yyyy,mm,dd.

    use strict; use warnings;
    use Calendar::Hijri;

    my $calendar = Calendar::Hijri->new();
    my ($yyyy, $mm, $dd) = $calendar->today();
    print "Year [$yyyy] Month [$mm] Day [$dd]\n";

=cut

sub today
{
    my $self  = shift;
    my $today = localtime; 
    
    return $self->from_gregorian($today->year+1900, $today->mon+1, $today->mday);
}

=head2 as_string()

Return Hijri date in human readable format.

    use strict; use warnings;
    use Calendar::Hijri;

    my $calendar = Calendar::Hijri->new(1432, 7, 27);
    print "Hijri date is " . $calendar->as_string() . "\n";

=cut

sub as_string
{
    my $self = shift;
    return sprintf("%02d, %s %04d", $self->{dd}, $MONTHS->[$self->{mm}], $self->{yyyy});
}

=head2 is_leap_year()

Return 1 or 0 depending on whether the given year is a leap year or not in Hijri Calendar.

    use strict; use warnings;
    use Calendar::Hijri;

    my $calendar = Calendar::Hijri->new(1432, 7, 27);
    ($calendar->is_leap_year())
    ?
    (print "YES Leap Year\n")
    :
    (print "NO Leap Year\n");

=cut

sub is_leap_year
{
    my $self = shift;
    my $yyyy = shift;
    $yyyy = $self->{yyyy} unless defined $yyyy;

    return unless defined $yyyy;

    my $mod = $yyyy%30;
    return 1 if grep/$mod/,@$LEAP_YEAR_MOD;
    return 0;
}

=head2 days_in_year()

Returns the number of days in the given year of Hijri Calendar.

    use strict; use warnings;
    use Calendar::Hijri;

    my $calendar = Calendar::Hijri->new(1432, 7, 27);
    print "Total number of days in year 1432: " . $calendar->days_in_year() . "\n";

=cut

sub days_in_year
{
    my $self = shift;
    my $yyyy = shift;
    $yyyy = $self->{yyyy} unless defined $yyyy;

    return unless defined $yyyy;

    ($self->is_leap_year($yyyy))
    ?
    (return 355)
    :
    (return 354);
}

=head2 days_in_month()

Return number of days in the given year and month of Hijri Calendar.

    use strict; use warnings;
    use Calendar::Hijri;

    my $calendar = Calendar::Hijri->new(1432,7,26);
    print "Days is Rajab   1432: [" . $calendar->days_in_month() . "]\n";

    print "Days is Shawwal 1432: [" . $calendar->days_in_month(1432, 8) . "]\n";

=cut

sub days_in_month
{
    my $self = shift;
    my $yyyy = shift;
    my $mm   = shift;

    $mm = $self->{mm}     unless defined $mm;
    $yyyy = $self->{yyyy} unless defined $yyyy;

    return unless (defined($mm) && defined($yyyy));

    return 30 if (($mm%2 == 1) || (($mm == 12) && ($self->is_leap_year($yyyy))));
    return 29;
}

=head2 days_so_far()

    use strict; use warnings;
    use Calendar::Hijri;

    my $calendar = Calendar::Hijri->new(1432, 7, 27);
    print "Days before 01 Rajab 1432: " . $calendar->days_so_far() . "\n";

=cut

sub days_so_far
{
    my $self = shift;
    my $yyyy = shift;
    my $mm   = shift;

    $mm   = $self->{mm}   unless defined $mm;
    $yyyy = $self->{yyyy} unless defined $yyyy;
    return unless (defined($mm) && defined($yyyy));

    my $days = 0;
    foreach (1..$mm) 
    {
        $days += $self->days_in_month($yyyy, $_);
    }
    return $days;
}

=head2 add_day()

Returns new date in Hijri Calendar after adding the given number of day(s) to the original date.

    my $calendar = Calendar::Hijri->new(1432, 7, 27);
    print "Hijri Date 1:" . $calendar->as_string() . "\n";
    $calendar->add_day(2);
    print "Hijri Date 2:" . $calendar->as_string() . "\n";

=cut

sub add_day
{
    my $self  = shift;
    my $day   = shift;
    my $dd    = shift;
    my $mm    = shift;
    my $yyyy  = shift;

    $dd   = $self->{dd}   unless defined $dd;
    $mm   = $self->{mm}   unless defined $mm;
    $yyyy = $self->{yyyy} unless defined $yyyy;

    return unless (defined($dd) && defined($mm) && defined($yyyy));

    foreach (1..$day)
    {
        ($dd, $mm, $yyyy) = _add_day($self->days_in_month($yyyy, $mm), $dd, $mm, $yyyy);
    }
    return ($dd, $mm, $yyyy);
}

=head2 get_calendar()

Return  Hijri  Calendar  for the given month and year. In case of missing  month  and year, it
would return current month Hijri Calendar.

    use strict; use warnings;
    use Calendar::Hijri;

    my $calendar = Calendar::Hijri->new(1432, 7, 27);
    print $calendar->get_calendar();

=cut

sub get_calendar
{
    my $self = shift;
    my $yyyy = shift;    
    my $mm   = shift;

    $yyyy = $self->{yyyy} unless defined $yyyy;    
    $mm   = $self->{mm}   unless defined $mm;

    my ($calendar, $start_index, $days);
    $calendar = sprintf("\n\t%s [%04d]\n", $MONTHS->[$mm], $yyyy);
    $calendar .= "\nSat  Sun  Mon  Tue  Wed  Thu  Fri\n";

    $start_index = $self->start_index($yyyy, $mm);
    $days = $self->days_in_month($yyyy, $mm);
    map { $calendar .= "     " } (1..$start_index);
    foreach (1 .. $days) 
    {
        $calendar .= sprintf("%3d  ", $_);
        $calendar .= "\n" unless (($start_index+$_)%7);
    }
    return sprintf("%s\n\n", $calendar);
}

=head2 from_gregorian()

Converts given Gregorian date to Hijri date.

    use Calendar::Hijri;

    my $calendar = Calendar::Hijri->new();
    my ($yyyy, $mm, $dd) = $calendar->from_gregorian(2011, 3, 22);

=cut

sub from_gregorian
{
    my $self = shift;
    my $yyyy = shift;
    my $mm   = shift;
    my $dd   = shift;

    return $self->from_julian(_gregorian_to_julian($yyyy, $mm, $dd));
}


=head2 to_gregorian()

Converts Hijri date to Gregorian date.

    use Calendar::Hijri;

    my $calendar = Calendar::Hijri->new();
    my ($yyyy, $mm, $dd) = $calendar->to_gregorian();

=cut

sub to_gregorian
{
    my $self = shift;
    my $yyyy = shift;
    my $mm   = shift;
    my $dd   = shift;

    $yyyy = $self->{yyyy} unless defined $yyyy;
    $mm   = $self->{mm}   unless defined $mm;
    $dd   = $self->{dd}   unless defined $dd;

    return _julian_to_gregorian($self->to_julian($yyyy, $mm, $dd));
}

=head2 to_julian()

Converts Hijri date to Julian date.

    use Calendar::Hijri;

    my $calendar = Calendar::Hijri->new();
    my $julian   = $calendar->to_julian();

=cut

sub to_julian
{
    my $self = shift;
    my $yyyy = shift;
    my $mm   = shift;
    my $dd   = shift;

    $yyyy = $self->{yyyy} unless defined $yyyy;
    $mm   = $self->{mm}   unless defined $mm;
    $dd   = $self->{dd}   unless defined $dd;

    return ($dd +
            ceil(29.5 * ($mm - 1)) +
            ($yyyy - 1) * 354 +
            floor((3 + (11 * $yyyy)) / 30) +
            $ISLAMIC_EPOCH) - 1;
}

sub from_julian
{
    my $self   = shift;
    my $julian = shift;

    $julian = floor($julian) + 0.5;
    my $yyyy = floor(((30 * ($julian - $ISLAMIC_EPOCH)) + 10646) / 10631);
    my $mm   = min(12, ceil(($julian - (29 + $self->to_julian($yyyy, 1, 1))) / 29.5) + 1);
    my $dd   = ($julian - $self->to_julian($yyyy, $mm, 1)) + 1;

    return ($yyyy, $mm, $dd);
}

sub start_index
{
    my $self = shift;
    my $yyyy = shift;
    my $mm   = shift;

    $yyyy = $self->{yyyy} unless defined $yyyy;    
    $mm   = $self->{mm}   unless defined $mm;

    my ($g_y, $g_m, $g_d) = $self->to_gregorian($yyyy, 1, 1);
    my $dow = Day_of_Week($g_y, $g_m, $g_d);

    return $dow if $mm == 1;
    my $days = $self->days_so_far($yyyy, $mm-1);

    for (1..$days)
    {
        if ($dow != 6)
        {
            $dow++;
        }
        else
        {
            $dow = 0;
        }
    }
    return $dow
}

sub _gregorian_to_julian
{
    my $yyyy = shift;
    my $mm   = shift;
    my $dd   = shift;

    return ($GREGORIAN_EPOCH - 1) +
           (365 * ($yyyy - 1)) +
           floor(($yyyy - 1) / 4) +
           (-floor(($yyyy - 1) / 100)) +
           floor(($yyyy - 1) / 400) +
           floor((((367 * $mm) - 362) / 12) +
           (($mm <= 2) ? 0 : (_is_leap($yyyy) ? -1 : -2)) +
           $dd);
}

sub _julian_to_gregorian
{
    my $julian = shift;

    my $wjd        = floor($julian - 0.5) + 0.5;
    my $depoch     = $wjd - $GREGORIAN_EPOCH;
    my $quadricent = floor($depoch / 146097);
    my $dqc        = $depoch % 146097;
    my $cent       = floor($dqc / 36524);
    my $dcent      = $dqc % 36524;
    my $quad       = floor($dcent / 1461);
    my $dquad      = $dcent % 1461;
    my $yindex     = floor($dquad / 365);
    my $yyyy       = ($quadricent * 400) + ($cent * 100) + ($quad * 4) + $yindex;

    $yyyy++ unless (($cent == 4) || ($yindex == 4));

    my $yearday = $wjd - _gregorian_to_julian($yyyy, 1, 1);
    my $leapadj = (($wjd < _gregorian_to_julian($yyyy, 3, 1)) ? 0 : ((_is_leap($yyyy) ? 1 : 2)));
    my $mm      = floor(((($yearday + $leapadj) * 12) + 373) / 367);
    my $dd      = ($wjd - _gregorian_to_julian($yyyy, $mm, 1)) + 1;

    return ($yyyy, $mm, $dd);
}

sub _is_leap
{
    my $yyyy = shift;

    return (($yyyy % 4) == 0) &&
            (!((($yyyy % 100) == 0) && (($yyyy % 400) != 0)));
}

# days: Total number of days in the given month mm.
sub _add_day
{
    my $days = shift;
    my $dd   = shift;
    my $mm   = shift;
    my $yyyy = shift;
    return unless (defined($dd) && defined($mm) && defined($yyyy));

    $dd++;
    if ($dd >= 29)
    {
        if ($dd > $days)
        {
            $dd = 1;
            $mm++;
            if ($mm > 12)
            {
                $mm = 1;
                $yyyy++;
            }
        }
    }
    return ($dd, $mm, $yyyy);
}

sub _validate_date
{
    my $yyyy = shift;
    my $mm   = shift;
    my $dd   = shift;

    croak("ERROR: Invalid year [$yyyy].\n")
        unless (defined($yyyy) && ($yyyy =~ /^\d{4}$/) && ($yyyy > 0));
    croak("ERROR: Invalid month [$mm].\n")
        unless (defined($mm) && ($mm =~ /^\d{1,2}$/) && ($mm >= 1) && ($mm <= 12));
    croak("ERROR: Invalid day [$dd].\n")
        unless (defined($dd) && ($dd =~ /^\d{1,2}$/) && ($dd >= 1) && ($dd <= 30));
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-calendar-hijri at rt.cpan.org>, or through
the  web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Calendar-Hijri>. I will
be  notified ,  and  then  you'll  automatically be notified of progress on your bug as I make
changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Calendar::Hijri

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Calendar-Hijri>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Calendar-Hijri>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Calendar-Hijri>

=item * Search CPAN

L<http://search.cpan.org/dist/Calendar-Hijri/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This  program  is  free  software; you can redistribute it and/or modify it under the terms of
either :  the  GNU General Public License as published by the Free Software Foundation; or the
Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed  in  the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

1; # End of Calendar::Hijri