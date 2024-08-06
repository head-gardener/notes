# Pipes

Pipes allow to build one-directional communication channels between
related processes. They re available in shells through the `|` symbol,
or as `pipe()` and `pipe2()` syscalls. Pipes can be represented as disk
references using named pipes or FIFO files, which are created using
`mkfifo`.

## Pipe buffer

An important feature of pipes is the max size of an atomic write. The
`PIPE_BUF` constant (man 7 pipe) determines it and sets it to 4096
bytes. Please, read the man carefully if you want to rely on this
guarantee. The default size of the pipe buffer (which is a ring buffer
with slots), is the number of slots multiplied by the `PIPE_BUF`
constant, which is 16 and 4KiB by default, giving us 64KiB. Pipes get
used instead of files due to their more convenient API.

## `SIGPIPE`

A process receives `SIGPIPE` when writing to a pipe with a dead reader.
Default behaviour in such case is to exit, sending `SIGPIPE` to the next
producer in line. Thus exits cascade through pipelines. When a pipeline
terminates, shell sets `$?` to the return code of the last command in
the pipeline (i.e. rightmost) and populates `$PIPESTATUS` array with all
return codes of the pipeline. `$?` containing the result of the last
command can lead to unexpected results, where an important command in
the pipeline fails without it getting reflected in the return of the
pipeline. Use `set -o pipefail` to propagate any fails in the pipeline
to the return value.

## Using pipes as kernel space buffers

In some situations you can improve performance of low-level code by
using zero-copy operations like `splice()`, `vmsplice()` and `tee()` and
treating pipes as 64KiB kernel space buffers.

-   `splice()` -- moves data from the buffer to an arbitrary file
    descriptor, or vice versa, or from one buffer to another
    (`man 2 splice`)
-   `vmsplice()` -- "copies" data from user space into the buffer
    (`man 2 vmsplice`)
-   `tee()` - allocates internal kernel buffer (`man 2 tee`)
