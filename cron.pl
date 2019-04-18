#!/usr/bin/perl -w
# last updated : 2019/01/14 11:29:48
# Execute commands at specified times every day like crontab.
# (C) Tomoaki Matsumoto <matsu@hosei.ac.jp>
#
# Calling sequence: 
# nohup cron.pl > log.cron 2>&1 &
#
# Configuration file:
# $HOME/.crontab
#
use strict;
use Time::Local 'timelocal';
use POSIX 'strftime';
use POSIX ":sys_wait_h";

my $DEBUG = 0;
my $VERBOSE = 1;
my $CRONTAB = $ENV{HOME} . '/.crontab';
$| = 1;				# non-buffering of STDOUT

my @min = ();
my @hour = ();
my @cmd = ();

&read_crontab(\@min, \@hour, \@cmd);

if ($DEBUG) {
    print "*** Reading " .$CRONTAB. "\n";
    for (my $n=0; $n <= $#cmd; $n++) {
	print '*** ', join(' ', ($min[$n], $hour[$n], $cmd[$n])), "\n";
    }
}

&watchdog_loop(\@min, \@hour, \@cmd);


# Read $CRONTAB file.
#
# @min, @hour = lists of a time for executing a command (OUT)
# @cmd = list of commands (OUT)
#
sub read_crontab {
    my ($rmin, $rhour, $rcmd) = @_;
    open( my $fh, $CRONTAB ) or die $!;
    while (my $line = <$fh>) {
	next if ($line =~ /^#/);
	next if ($line =~ /^\s$/);
	chop $line;
	$line =~ s/^\s+//;	# remove WSs in head
	my ($min, $hour, $cmd) = split(/\s+/, $line, 3);
	push (@$rmin, $min);
	push (@$rhour, $hour);
	push (@$rcmd, $cmd);
    }
    close $fh;
}

# main loop for time
#
# @min, @hour, @cmd = lists of a time and command (IN)
#
sub watchdog_loop {
    my ($rmin, $rhour, $rcmd) = @_;
    my $sec_interval = 60;	# interval of check in sec
    my $day_insec = 24*60*60;
    my @done_time = (-1) x $#$rcmd;
    &get_done_time(\@done_time, $rmin, $rhour);
    while (1) {
	my $now = time;
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime($now);
	for (my $n=0; $n <= $#$rcmd; $n++) {
	    my ($cmin, $chour, $cmd) = ($$rmin[$n], $$rhour[$n], $$rcmd[$n]);
	    my $ctime = timelocal($sec, $cmin, $chour, $mday, $mon, $year);
	    if ($DEBUG) { print "*** Skip cmd ", $n, " ", 
			     &get_time2str($now), ' ', 
			     &get_time2str($ctime), ' ', 
			     &get_time2str($done_time[$n]), "\n"};
	    if ($now >= $ctime && $now >= $done_time[$n] + $day_insec) {
		$done_time[$n] = $now;
		unless (fork()) { # child process
		    if ($VERBOSE) {print '*** Command start ', &get_time2str(time()), ' ', $cmd, "\n";}
		    system($cmd); # wait untill command finishes
		    if ($VERBOSE) {print '*** Command end   ', &get_time2str(time()), ' ', $cmd, "\n";}
		    exit 0;
		}
	    }
	}
	sleep $sec_interval;
	&kill_zombi();
    }
}

# get dome_time (time before 24 hours of command time)
#
# @dtime = done_time (OUT)
# @min, @hour = lists of a time (IN)
#
sub get_done_time {
    my ($rdtime, $rmin, $rhour) = @_;
    my $now = time;
    my $day = 24*3600;
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime($now);
    for (my $n=0; $n <= $#$rmin; $n++) {
	my ($cmin, $chour) = ($$rmin[$n], $$rhour[$n]);
	$$rdtime[$n] = timelocal($sec, $cmin, $chour, $mday, $mon, $year);
	$$rdtime[$n] -= $day if ($$rdtime[$n] > $now);
	if ($DEBUG) {print '*** dtime ', &get_time2str($$rdtime[$n]), "\n"};
    }

}

# convert time to a formatted string
sub get_time2str {
    my $time = $_[0];
    return scalar( strftime "%Y/%m/%d %H:%M:%S", localtime($time));
}

# wait all the zombi processes (finished processes) if they exist.
sub kill_zombi {
    my $kid;
    do {
        $kid = waitpid(-1, WNOHANG); #  non-blocking wait
    } while $kid > 0;		     # kid is -1 if no child process
}
