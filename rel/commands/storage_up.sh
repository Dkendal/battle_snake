#!/bin/sh
ERL_OPTS="$ERL_OPTS -start_epmd true"
ERL_OPTS="$ERL_OPTS -args_file $VMARGS_PATH"
$RELEASE_ROOT_DIR/bin/bs command Elixir.Bs.ReleaseTasks storage_up
ERL_OPTS=$ORIG_ERL_OPTS
