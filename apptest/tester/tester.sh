#!/bin/bash

set -xeo pipefail
shopt -s nullglob

for test in /tests/common/*; do
	testrunner -logtostderr "--test_spec=${test}"
done
