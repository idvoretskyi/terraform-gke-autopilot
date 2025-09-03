#!/bin/bash

# Script to reproduce current test state before fixes
set -e

echo "=== Testing Current Integration Tests State ==="

# Test 1: Run unit tests
echo "Running unit tests..."
cd tests
chmod +x unit_test.sh
./unit_test.sh || echo "Unit tests completed with issues"

echo ""
echo "=== Running Go integration tests ==="

# Test 2: Try to run Go tests
echo "Running Go integration tests..."
go test -v ./... || echo "Go tests completed with issues"

echo ""
echo "=== Test reproduction complete ==="