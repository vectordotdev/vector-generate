# Vector Generate

Repository for generating files across all of Vector's repos located in the
[`targets` directory](/targets).

## Usage

With Docker:

```bash
docker build --tag vector-generate .
docker run \
  -v `pwd`:/usr/app \
  -u $UID:$GID \
  -it vector-generate
```

Or without Docker:

```bash
./main.rb
```

## What?

This repository contains a single script ([`main.rb`](/main.rb)) that generates
files across various Vector repositories ([`/targets/*`](/targets)) from the
Vector metadata ([`/.meta`](/.meta)).

## Why?

Vector is a large project that covers a lot of surface area. In order to
document and market Vector we need to create a lot of different documents:

1. The [Vector reference docs][vector_reference_docs].
2. The [Vector components page][vector_components].
3. Listing all of the components on the [Vector README][vector_readme].
4. [Deriving Gihub labels and settings][vector_management_locals] from this data.
5. and more...

Instead of manually creating all of these pages, which is error prone, we
generate them. This ensures that these pages are accurate, consistent, and
decoupled from the underlying system, affording us the ability to quickly
iterate and improve them.

### Example 1: The Vector reference docs

For example, the [Vector reference docs][vector_reference] contain over 150
pages that contain detailed configuration information for all of Vector's
components. All of these pages have evolved over time, something that would not
be possible through manual intervention.

### Example 2: Migrating the Vector website

We've migrated the Vector website 3 times to ensure it delivers a good UX.
For Vector, the docs play a critical role in achieving this and we are afforded
this agility through documentation generation. Baking all of this data into
markdown files would make it difficult, if not impossible, to migrate over time.

## How?

1. [`main.rb`](/main.rb) is the main executable.
2. Upon execution it first loads all of the metdata in the [`.meta`](/.meta)
   folder.
   1. You'll notice that the Vector repo is loaded here as a Git submodule.
      We do this to load in Vector's own metadata via the `.meta/vector/meta`
      directory. This allows us to keep the Vector metadata in the main Vector
      repo while still using it here. We like this process because developers
      can still couple metdata changes with their code.
3. Once the metadata is loaded we traverse each of the [`target`](/target)
   subdirectories and look for `.erb` templates and render these templates
   in the context of the loaded metadata. The rendered template is placed in the
   same path as the template without the `.erb` extension.


[vector_components]: https://vector.dev/components/
[vector_management_locals]: https://github.com/timberio/vector-management/blob/master/github/locals_generated.tf.erb
[vector_readme]: https://github.com/timberio/vector/blob/master/README.md
[vector_repo]: https://github.com/timberio/vector
[vector_reference]: https://vector.dev/docs/reference/
[vector_website_repo]: https://github.com/timberio/vector-website