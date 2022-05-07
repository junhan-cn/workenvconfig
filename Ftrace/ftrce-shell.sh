#!/bin/bash

usag() {
    echo "描述:"
    echo "-f 指定跟踪的函数"
    echo "-x 指定执行的命令"
    exit

}

while getopts 'f:x:h' arg; do
    case $arg in
    f) strace_function="$OPTARG" ;;
    x) exec_function="$OPTARG" ;;
    h) usag ;;
    esac
done

main() {
    debugfs=/sys/kernel/debug
    echo nop >$debugfs/tracing/current_tracer
    echo 0 >$debugfs/tracing/tracing_on
    echo $$ >$debugfs/tracing/set_ftrace_pid
    echo function_graph >$debugfs/tracing/current_tracer
    echo $strace_function >$debugfs/tracing/set_graph_function
    echo 1 >$debugfs/tracing/tracing_on

    exec $exec_function
}

if [[ -n "$strace_function" && -n "$exec_function" ]]; then
    main
fi
