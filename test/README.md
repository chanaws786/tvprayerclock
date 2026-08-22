# Unit Tests

This directory contains unit tests for the MCWAS TV Prayer Clock application.

## Running Tests

### Time Calculation Tests

To run the time calculation unit tests:

1. Open Processing IDE
2. File → Open → Select `test/TimeCalculationTest.pde`
3. Click the Run button (▶) or press Ctrl+R (Cmd+R on Mac)
4. View the console output for test results

## Test Coverage

### TimeCalculationTest.pde

Tests the following functions:
- `padTime()` - Time value padding with leading zeros
- `salahTimeInMinutes()` - Conversion of time strings to minutes since midnight
- `isRamadanMonth()` - Ramadan month detection
- `isRamadanGreyScreenTime()` - Ramadan grey screen time window logic

## Adding New Tests

To add new tests:

1. Create a new test function following the naming convention `test<FunctionName>()`
2. Use the assertion helpers:
   - `assertEquals(expected, actual, message)` for objects
   - `assertEquals(expected, actual, message)` for integers
   - `assertEquals(expected, actual, message)` for booleans
3. Call your test function in `runTests()`
4. Run the test sketch to verify

## Test Results

Tests will output:
- ✓ PASS for successful tests
- ✗ FAIL for failed tests with expected vs actual values
- Summary showing total passed/failed tests

## Continuous Integration

These tests can be integrated into CI/CD pipelines by:
1. Running Processing in headless mode
2. Capturing console output
3. Checking exit codes based on test results