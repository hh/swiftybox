#!/bin/bash

# SwiftyλBox Performance Benchmark
# Compares direct function calls vs fork+exec

echo "SwiftyλBox Performance Benchmark"
echo "================================="
echo ""

ITERATIONS=10000
SWIFTYBOX="./build/debug/swiftybox"

# Build if needed
if [ ! -f "$SWIFTYBOX" ]; then
    echo "Building SwiftyλBox..."
    swift build
fi

echo "Running $ITERATIONS iterations of each command..."
echo ""

# Benchmark echo
echo "Benchmarking echo command:"
echo "  Traditional /bin/echo..."
time for i in $(seq 1 $ITERATIONS); do
    /bin/echo "test" > /dev/null
done

echo "  SwiftyλBox echo..."
time for i in $(seq 1 $ITERATIONS); do
    $SWIFTYBOX echo "test" > /dev/null
done

echo ""

# Benchmark pwd
echo "Benchmarking pwd command:"
echo "  Traditional /bin/pwd..."
time for i in $(seq 1 $ITERATIONS); do
    /bin/pwd > /dev/null
done

echo "  SwiftyλBox pwd..."
time for i in $(seq 1 $ITERATIONS); do
    $SWIFTYBOX pwd > /dev/null
done

echo ""

# Benchmark true
echo "Benchmarking true command:"
echo "  Traditional /bin/true..."
time for i in $(seq 1 $ITERATIONS); do
    /bin/true
done

echo "  SwiftyλBox true..."
time for i in $(seq 1 $ITERATIONS); do
    $SWIFTYBOX true
done

echo ""
echo "================================="
echo "Benchmark complete!"
echo ""
echo "Note: SwiftyλBox uses direct function calls (λ)"
echo "Traditional commands use fork+exec"
