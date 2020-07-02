# Synopsis:

daemonizer is an application lifecycle management framework. It starts and stops applications and
displays information about them. A typical use case is when you have a program that you
would like to run as a UNIX daemon while being able to check its logs and stop when needed
(a web server or a microservice are good examples).

Without daemonizer doing it is a laborious task. You will have to do the following manually:

1) Start the application and send it to the background
2) Redirect its output to file and remember its location
3) Find the application's PID by looking through the list of processes
4) Make sure the app is not run multiple times
5) Invent the procedure and a shell script to gracefully stop the app
6) Invent the procedure to kill the app when it doesn't respond to a graceful shutdown request

...and lots of other things that daemonizer takes care of!

# Installation:

1) Unpack daemonizer'es archive into any directory
2) Change the PATH variable in `~/.bashrc` (assuming you unpacked daemonizer to `/home/${username}/opt/daemonizer`"):

`$ export PATH=/opt/daemonizer:$PATH`

# Component's responsibility:

daemonizer consists of several components each having its own scope and responsibility.

1) daemonizer - defines environment variables, starts the runner
2) runner - manages application lifecycle (starting/stopping/checking if alive), calls a startup
script via deamonizer if the "start" command is specified and hands unrecognized commands to
the startup script
3) daemonizer - makes an app a deamon if needed detaching from a controlling terminal. Terminates
an application if someone deletes its PID. Can be used outside of the daemonizer framework.
4) startup script - executes a command passed to it or executes an application if no command is
provided
5) post-start script (optional) - runs a sequence of actions required for the program to become
fully initialized (e.g. adding entries to the database in case of microservices).

There's a special startup script called "core" which serves a special purpose showing information
about the framework (for example, the list of startup scripts).

Important: currently daemonizer is capable of handling only a single instance of each application (you
need to create a separate startup script for each of them).

# Examples:

Note: there is a sample script called "sleeper" that can be used to verify the functionality. It just
sleeps for 60 seconds and then exits.
```
$ daemonizer sleeper start
$ daemonizer sleeper show     # Shows a PID and a log file location
$ daemonizer sleeper showlog  # Prints a log file content
$ daemonizer sleeper stop
```
In addition, your startup script might want to send, for example, SIGHUP to the controlled application
in order to force it to reload the changed configuration. Or it might want to check the service's
health by callingone of its endpoints. This is possible with daemonizer. To make sure the startup
script supports custom commands, run the following (for the "sleeper"):

`$ daemonizer sleeper listcommands # Prints a list of the application-specific commands`

Then you can use such a command:
```
$ daemonizer stc-ws check    # Check the REST API health by calling one of its endpoints
$ daemonizer stc-ws showmem  # Show memory utilization
```
You might want to see all startup scripts:
```
$ daemonizer core showscripts # Prints a list of startup scripts
```
