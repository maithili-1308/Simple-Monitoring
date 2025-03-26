#!/bin/bash

# Exit if any command fails
set -e

echo "🚀 Starting system load test..."

# Install required tools
echo "📦 Installing stress, iperf3, and other utilities..."
if command -v apt &> /dev/null; then
    sudo apt update -y && sudo apt install -y stress iperf3
elif command -v yum &> /dev/null; then
    sudo yum install -y epel-release
    sudo yum install -y stress iperf3
else
    echo "❌ Unsupported package manager! Install 'stress' and 'iperf3' manually."
    exit 1
fi

# Function to generate CPU load
generate_cpu_load() {
    echo "🔥 Generating CPU load..."
    stress --cpu 4 --timeout 60 &  # Uses 4 CPU cores for 60 seconds
}

# Function to generate Memory load
generate_memory_load() {
    echo "🧠 Allocating RAM..."
    stress --vm 2 --vm-bytes 256M --timeout 60 &  # Uses 2 workers, each allocating 256MB RAM
}

# Function to generate Disk I/O load
generate_disk_load() {
    echo "💾 Generating Disk I/O load..."
    dd if=/dev/zero of=/tmp/disk_load_test bs=1M count=500 oflag=direct &  # Writes 500MB file
    sleep 10
    rm -f /tmp/disk_load_test
}

# Function to generate Network load
generate_network_load() {
    echo "🌐 Generating Network load..."
    iperf3 -s -D  # Start iperf3 server in background
    iperf3 -c 127.0.0.1 -t 30 &  # Send traffic for 30 seconds
}

# Run all load tests in parallel
generate_cpu_load
generate_memory_load
generate_disk_load
generate_network_load

# Wait for tests to complete
wait

echo "✅ Load test completed! Check Netdata at: http://$(hostname -I | awk '{print $1}'):19999/"

exit 0
