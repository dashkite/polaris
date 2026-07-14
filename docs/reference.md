# Reference

## `expand`

$expand(value, context)$

Expands text, objects, or arrays by evaluating expressions wrapped in `${ }` against the provided context.

- `value` (object, array, or string): The value to expand.
- `context` (object): The data object to query against.

Returns the expanded value. 

### Examples

```coffeescript
import { expand } from "@dashkite/polaris"

data = name: "Alice"
result = expand "Hello, ${ name }", data
```

## `scan`

$scan(text)$

Scans text for interpolation tokens, parsing out text blocks and expressions.

- `text` (string): The text to scan.

Returns an array of token objects.

### Examples

```coffeescript
import { scan } from "@dashkite/polaris"

tokens = scan "Hello, ${ name }"
```

## `query`

$query(expression, data)$

Evaluates a JSON path expression against a data object.

- `expression` (string): The JSON path expression to evaluate.
- `data` (object): The data object to query.

Returns the result of the query.

### Examples

```coffeescript
import { query } from "@dashkite/polaris"

data = user: name: "Alice"
result = query "$.user.name", data
```
