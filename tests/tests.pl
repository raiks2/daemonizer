#!/usr/bin/perl

my @failed_tests;

sub test_stopped_app_cannot_be_stopped_twice {
    my $output = qx(daemonizer sleeper stop 2>&1);
    if ($output !~ /seems to be stopped/) {
        push @failed_tests, 'test_stopped_app_cannot_be_stopped_twice';
    }
}

sub test_already_running_app_cannot_be_run_twice {
    start_app();
    my $output = qx(daemonizer sleeper start 2>&1);
    if ($output !~ /is already running/) {
        push @failed_tests, 'test_already_running_app_cannot_be_run_twice';
    }
    stop_app();
}

sub test_when_app_is_running_show_command_displays_correct_pid {
    start_app();
    my ($pid) = qx(daemonizer sleeper show | grep PID) =~/PID = (\d+)/;
    push @failed_tests, 'test_when_app_is_running_show_command_displays_correct_pid' if $pid !~ /\d+/;
    my $ps_command = "ps -o pid= -o ppid= -o pgid= -o sid= -o args= -p $pid";
    push @failed_tests, 'test_when_app_is_running_show_command_displays_correct_pid' if qx($ps_command) !~ m|/usr/bin/perl -e sleep 60|;
    stop_app();
}

sub start_app {
    print "    Starting app...\n";
    qx(daemonizer sleeper start);
}

sub stop_app {
    print "    Stopping app...\n";
    qx(daemonizer sleeper stop);
}

sub run_tests {

    my $tests = {
        'test_stopped_app_cannot_be_stopped_twice' => \&test_stopped_app_cannot_be_stopped_twice,
        'test_already_running_app_cannot_be_run_twice' => \&test_already_running_app_cannot_be_run_twice,
        'test_when_app_is_running_show_command_displays_correct_pid' => \&test_when_app_is_running_show_command_displays_correct_pid
    };

    for my $test_name (keys %$tests) {
        print "Running $test_name...\n";
        $tests->{$test_name}->();
    }

    if (@failed_tests) {
        local $" = ', ';
        print "The following tests failed: @failed_tests\n";
    } else {
        print "All tests are OK\n";
    }
}

run_tests();

