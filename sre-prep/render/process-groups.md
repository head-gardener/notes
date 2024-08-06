# Process groups, jobs and sessions {#process-groups,-jobs-and-sessions}

A new process group is created every time we execute a command or a
pipeline of commands in a shell. Inside a shell, a process group is
usually called a job. In its turn, each process group belongs to a
session. As such, a process group is a set of processes, and a session
is a set of related process groups. This information about a process can
be gathered from `/proc/$PID/stat`.

## Process groups

A process group has its process group identificator `PGID` and a leader
who created this group. The `PID` of the group leader is equal to the
corresponding `PGID`. A process group lives as long as it has at least
one member. All members of a process group can be killed or waited for
using its `PGID`.

## Sessions

For its part, a session is a collection of process groups. All members
of a session identify themselves by the identical `SID`, which, as in a
process group, also inherited from the session leader. All processes in
the session share a single controlling terminal.

## Shell job controol

Shells start processes in a single session, every pipeline gets a new
job (process group). A session has shared controlling terminal, which is
relied upon for listening for terminal exits and some signals (`SIGINT`,
`SIGSTP` and `SIGHUP`). A session also has a single foreground job.
Every other job is either stopped (after `C-z`, i.e. `SIGSTP`) or runs
in the background (`bg %1`). When exiting, a shell will send `SIGHUP` to
all jobs it has started and keeps track of. To make a job survive shell
exit (when working with remote shells for example) `nohup` or `disown`
can be used. `nohup` redirects standard fd\'s to files and sets
`SIG_INT` flag, that ignores `SIGHUP`, before running `execve()`.
`disown` makes the shell forget about a job, thus preventing it from
sending `SIGHUP`.

## Daemons

Daemons are long running processes running in the background without a
controlling terminal, thus never receiving terminal-related signals from
the kernel, like `SIGINT`, `SIGSTP` and `SIGHUP`. Daemons can be started
manually using the double-fork technique, implemented in gnu\'s `libc`
as `daemon()`, or using `systemd`, which handless all redirection and
other nice features.
