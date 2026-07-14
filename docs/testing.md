# Testing

## How is Polaris tested?

Polaris utilizes the `@dashkite/amen` testing framework alongside `@dashkite/assert` for robust and readable tests. The tests evaluate the correctness of the API.

The testing approach relies on a set of predefined scenarios consisting of an input and an expected output. The tests iterate over these scenarios and verify that expanding the input against a standard data context matches the expected output. Additional tests evaluate edge cases such as `undefined` handling and provide basic performance benchmarks.

## Running Tests

To invoke the test suite, developers can run the following command using `genie`:

```bash
npx genie test
```
