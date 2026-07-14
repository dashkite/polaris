# Recipes

## How to expand simple string templates

Developers can use `expand` to interpolate string templates with a context object. This task relies on wrapping the JSON query expression in `${ }`.

```coffeescript
import { expand } from "@dashkite/polaris"

context = 
  user: 
    name: "Alice"

# The expression queries the context object.
greeting = expand "Hello, ${ user.name }", context

console.log greeting # "Hello, Alice"
```

## How to recursively expand objects

Developers can also pass an object to `expand`. The library will traverse the object and expand any string templates found within the object's properties.

```coffeescript
import { expand } from "@dashkite/polaris"

context = 
  host: "api.example.com"
  port: 8080

configTemplate =
  url: "https://${ host }:${ port }/graphql"
  timeout: 5000

# The expand function processes the entire object.
config = expand configTemplate, context

console.log config.url # "https://api.example.com:8080/graphql"
```

## How to recursively expand arrays

Arrays containing string templates are also fully supported by `expand`.

```coffeescript
import { expand } from "@dashkite/polaris"

context = 
  domain: "example.com"

endpoints = [
  "https://api.${ domain }"
  "https://auth.${ domain }"
]

# Each element in the array is expanded.
expandedEndpoints = expand endpoints, context
```

## How to escape interpolation tokens

If a developer needs to include literal `${` characters in the string, they can escape the `$` symbol using a backslash.

```coffeescript
import { expand } from "@dashkite/polaris"

context = 
  amount: 50

# The first dollar sign is escaped.
message = expand "The cost is \\${ amount }", context

console.log message # "The cost is ${ amount }"
```
