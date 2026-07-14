# Technical Notes

## Dependencies

### JsonPath Plus

Polaris uses `jsonpath-plus` to evaluate JSON queries. This provides robust and comprehensive path evaluation for the `query` function.

### Scan Library

The library delegates the parsing of text and expressions to `@dashkite/scan`, which handles string tokenization to accurately extract `${ expression }` structures.

### Joy Library

The `@dashkite/joy` library is heavily utilized to support functional composition, type checking, and polymorphism. The `expand` function itself is defined as a `generic` function from `Joy`, allowing it to cleanly dispatch on the type of the value being expanded (Object, Array, or String).
