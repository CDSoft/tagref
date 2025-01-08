# Tagref

First of all, this software is a reimplementation of
[tagref](https://github.com/stepchowfun/tagref). The primary goal was to test
[LuaX](https://github.com/CDSoft/luax) and
[argparse](https://github.com/CDSoft/luax/blob/master/doc/argparse.md). If you
need a faster implementation I strongly recommend to use the original
[tagref](https://github.com/stepchowfun/tagref).

Tagref helps you maintain cross-references in your code. You can use it to help
keep things in sync, document assumptions, manage invariants, etc. The original
implementation of [tagref](https://github.com/stepchowfun/tagref) is used at
Airbnb for their front-end monorepo. You should use it too!

Tagref works with any programming language, and it respects your `.gitignore`
file (`git` must be installed). It's recommended to set up Tagref as an
automated continuous integration (CI) check. The original [Tagref
implementation](https://github.com/stepchowfun/tagref) is *blazing fast* (as
they say) and almost certainly won't be the bottleneck in your CI.

## What is it?

When writing code, it's common to refer to other parts of the codebase in
comments. The traditional way to do that is to provide a file path and a line
number. For example:

```python
# Keep this in sync with controllers/profile.py:304.
```

Unfortunately, as we all know, this is brittle:

1. As the code evolves, the line numbers may shift.
2. The file might be renamed or deleted.

One strategy is to reference a specific commit. At least then you know the
reader will be able to find the line that you're referencing:

```python
# Keep this in sync with controllers/profile.py@55217c6:304.
```

But that approach isn't ideal, since the current version of the code may have
diverged from the referenced commit in non-trivial ways.

*Tagref* solves this problem in a better way. It allows you to annotate your
code with *tags* (in comments), which can be referenced from other parts of the
codebase. For example, you might have a tag like this:

```python
# [tag:cities_nonempty] This function always returns a non-empty list.
def get_cities():
  return ['San Francisco', 'Tokyo']
```

Elsewhere, suppose you're writing some code which depends on that
postcondition. You can make that clear by referencing the tag:

```python
cities = get_cities()

first_city = cities[0] # This is safe due to [ref:cities_nonempty].
```

Tagref ensures such references remain valid. If someone tries to delete or
rename the tag, Tagref will complain. More precisely, it checks the following:

1. References actually point to tags. A tag cannot be deleted or renamed
   without updating the references that point to it.
2. Tags are unique. There is never any ambiguity about which tag is being
   referenced.

Note that, in the example above, Tagref won't ensure that the `get_cities`
function actually returns a non-empty list. It isn't magic! It only checks the
two conditions above.

## Usage

The easiest way to use Tagref is to run the `tagref` command with no arguments.
It will recursively scan the working directory and check the two conditions
described above. Here are the supported command-line options:

```
Usage: tagref [-p path] [-r ref-prefix] [-t tag-prefix] [-h]
       [<command>] ...

Tagref helps you maintain cross-references in your code.

Options:
   -p path               Adds the path of a directory to scan (default: .)
   -r ref-prefix         Sets the prefix used for locating references (default: ref)
   -t tag-prefix         Sets the prefix used for locating tags (default: tag)
   -h, --help            Show this help message and exit.

Commands:
   check                 Checks all the tags and references (default)
   list-refs             Lists all the references
   list-tags             Lists all the tags
   list-unused           Lists the unreferenced tags
```

## Installation instructions

You can download and compile Tagref with these commands:

```sh
git clone https://github.com/CDSoft/tagref
make -C tagref install
```

This will install `tagref` to `~/.local/bin`.

## Acknowledgements

The idea for Tagref was inspired by [the GHC notes
convention](https://ghc.haskell.org/trac/ghc/wiki/Commentary/CodingStyle#Commentsinthesourcecode).
[This article](http://www.aosabook.org/en/ghc.html) has more insights into how
the GHC developers manage their codebase.
