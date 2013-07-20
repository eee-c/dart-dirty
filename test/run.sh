#!/bin/bash

set -e

#####
# Unit Tests
dart test/dirty_test.dart

#####
# Type Analysis

echo
echo "dartanalyzer lib/dirty.dart"
dartanalyzer lib/dirty.dart
