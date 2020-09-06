# Vector Generate

A library used for generating `.erb` templates across various Vector
repositories using [Vector's `.meta` data][vector_metadata].

## Why?

[Vector's `.meta` directory][vector_metadata] contains structured data about
Vector itself. This data is used to generate documentation, configuration
examples, and other content. Coupling this metadata with Vector allows
contributors to couple metadata changes with their code. This means contributors
can maintain documentation, and other documents, without having to worry about
styling or presentation of this data.

## How?

This library is intended to be used like a Ruby gem. The
[`vector-website`][vector_website_repo] repo demonstrates how this is done:

1. Define a [`Gemfile`][vector_website_gemfile] that includes this library.
2. Define a [Ruby file][vector_website_generate] (usually called `generate.rb`)
   that uses this library accordingly.
3. Ensure this file is executable so it can be called directly.
4. Notice that this Ruby file loads the Vector metadata. How it accesses the
   data is up to you. A common practice is to load the
   [`vector` repo][vector_repo] as a submodule, so that this script can access
   the contained `.meta` directory.

## Future Intent

The Ruby gem approach allows each repository to optionally use this library as
needed. It is intended that we'll phase this library out as each repository
works with Vector's metadata directly, ultimately removing the need for this
library entirely.

## History

Finally, it's worth noting some history on this system. What you see here is
not the result of some carefully crafted master plan. This system evolved over
time as a means to an end. It initially started as a simple script to help with
documentation since Vector was using Gitbook at the time. It then evolved into
something larger as Vector's documentation system evolved. We've taken care to
organize the code and keep it clean, but there is certainly room for
improvement.

[vector_metdata]: https://github.com/timberio/vector/tree/master/.meta
[vector_repo]: https://github.com/timberio/vector
[vector_website_gemfile]: https://github.com/timberio/vector-website/blob/master/scripts/Gemfile
[vector_website_generate]: https://github.com/timberio/vector-website/blob/master/scripts/generate.rb
[vector_website_repo]: https://github.com/timberio/vector-website