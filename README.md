# Vector Generate

Repository for generating files across all of Vector's repos.

## What it does

The main [`vector` repo][vector_repo] contains a [`.meta` folder][vector_meta]
that contains structured metadata for the Vector project in the form of TOML
files, such as Vector's components and all of the available configuration
options. This metadata is parsed and used to generate files across many
different Vector repos, primarily the
[`vector-website` repo][vector_website_repo].


[vector_meta]: https://github.com/timberio/vector/tree/master/.meta
[vector_repo]: https://github.com/timberio/vector
[vector_website_repo]: https://github.com/timberio/vector-website