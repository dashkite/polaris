# @dashkite/polaris

_Simple JSON Query-based text interpolation for JavaScript_

[![Hippocratic License](https://img.shields.io/badge/Hippocratic_License-3.0-blue.svg)](https://firstdonoharm.dev)

Polaris provides simple JSON Query-based text interpolation for JavaScript. It supports recursive expansion of objects and arrays, allowing developers to cleanly interpolate complex data structures.

## Features

- Evaluates JSON query expressions for deep data extraction.
- Supports escaping interpolation tokens using `\`.
- Evaluates recursive expansion of objects and arrays.

## Installation

```bash
pnpm install @dashkite/polaris
```

## Usage

```coffeescript
import { expand } from "@dashkite/polaris"

data = name: "Alice"

greeting = expand "Hello, ${ name }", data

console.log greeting # "Hello, Alice"
```

## Other Resources

- [Recipes](docs/recipes.md)
- [Reference](docs/reference.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing](docs/testing.md)
