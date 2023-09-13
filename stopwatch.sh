#!/bin/bash

start_time=0
end_time=0

start_stopwatch() {
    start_time=$(date +%s)
    echo "Stopwatch started."
}

stop_stopwatch() {
    end_time=$(date +%s)
    echo "Stopwatch stopped."
    calculate_elapsed_time
}
calculate_elapsed_time() {
    elapsed_time=$((end_time - start_time))
    echo "Elapsed time: $elapsed_time seconds"
}

echo "Press Enter to start the stopwatch..."
read -r

start_stopwatch

echo "Press Enter to stop the stopwatch..."
read -r

stop_stopwatch
