# Assignment 1: compiling regular expressions

In this assignment, you'll have your first experience with Lua, Terra, and using metaprogramming to compile code, by implementing key parts of a simple compiler for regular expressions. We have provided the key representations, a parser for a simple regular expression syntax, an interpreter, and the skeleton of a compiler, as well as suites of both correctness and performance tests.

You do not need to come up with your own method for matching regular expressions, but you can learn more about the method we use here (translating from regular expressions to _nondeterministic finite automata_ (NFAs)) in  [this nice piece by Russ Cox](https://swtch.com/~rsc/regexp/regexp1.html).

## 0. Install Terra
To start, you need to install [Terra](http://terralang.org). The easiest way, which you almost certainly want to use, is to download the latest precompiled binaries (available for Mac OS, Linux, and Windows) [here](https://github.com/zdevito/terra/releases).

Once you've unpacked a precompiled Terra distribution, you can run terra just by running `/path/to/terra-distribution/bin/terra` (and you can either install those files under `/usr/local/*` or add `/path/to/terra-distribution/bin` to your `$PATH`).

## 1. Lower the Regex AST to the NFA IR

To start off, you should read (or at least skim) the Russ Cox article describing the regex evaluation strategy we'll be using: https://swtch.com/~rsc/regexp/regexp1.html
You don't need to worry about anything after "Caching the NFA to build a DFA".
We don't expect you to compile to DFAs at all.

Part 1 of this assignment is to implement the lowering
step described in the Cox article. We've already supplied you with
[AST](regex.t#L36-L105) and [NFA](regex.t#L107-L185) data structure definitions, so you don't need to decide on how to
represent either of these things.  We also already implemented a [parser](regex.t#L527-L711)
and [NFA simulator](regex.t#L244-L330) for you. Your job is to _lower_ (translate) from a regex AST into an NFA.

Once you implment the NFA lowering
step, you'll be able to test and benchmark your (non-compiled)
version of Regexes.
You can execute any regex in this language using the [_interpreted implementation_](regex.t#L244-L330) included in the starter code. At this point, your implementation should pass all of the correctness and performance tests (by running `terra testregex.t` and `terra perfregex.t`, with `REGEX_COMPILE = false` at the top of each, which is the default configuration of the starter code).

## 2. Complete the NFA compiler
The second part of this assignment is to write the metaprogrammed
parts of the compiler to construct a Terra function that simulates the
NFA. In particular, you will implement the [`step()`](regex.t#L440-L472) function that computes one (non-deterministic) step of the NFA.

You can read the
Cox article to understand the general strategy and the inline comments
in [`regex.t`](regex.t) for details. Note that [the compiler](regex.t#L331-L525) is implemented by defining an `NFA:compile()` method which constructs and returns a Terra function `find(string, strlen, start_idx)` which matches the given string to the regular expression from which the NFA was constructed.

The key in this part here is to use Terra's metaprogramming features to generate code to make the specific state transitions specified in a given NFA. The inline comments provide a lot of details and suggestions on how you should do this. You are responsible for:

1. implementing the body of `genmark` which generates Terra code to mark all the NFA state nodes reachable directly or via epsilon transitions along a given character edge;
2. implementing a generated `step` function, in the style described in the comments. It should encode the transition checks as actual `if` branches for each state and each transition in the NFA.

_Metaprogramming like this—writing code that generates code—can be mind-bending at first. It is extremely powerful, and you will develop an intuition for it by doing the assingments in this class, but don't be surprised if this is confusing at first. A complete solution for this part of the assignment can be done in a few tens of lines of code, but don't be surprised if it takes you quite a bit of thinking and asking questions (both of the staff and your fellow students) to wrap your mind around how._

Once you have written this code, you can test it for both correctness and performance the same way you did in part 1, by changing `REGEX_COMPILE` to `true` at the top of the two test programs.

## 3. Writeup
Finally, we'd like you to write up a little bit about what you did and what you learned. You can submit this writeup as a `writeup.md` in your submission repo.

First, write a short paragraph for each of part 1 and part 2, describing how you implemented each part.

Second, reflect briefly on what you found difficult, or alternatively, something you found interesting or surprising. (If your experience was great, you can say that too!)

## _n. Extra Credit_
If you have gotten this far and are excited to explore more, there are [a few extra credit ideas](regex.t#L12-L32) in the comments at the top of `regex.t`. _These are highly optional, but can be fun and let you go a bit deeper into your first compiler!_ If you pursue any of these, please also describe what you did or found briefly in your writeup.

Additionally, you can write some reflection on possible extensions or different design choices in the implementation:

What if instead of having `mark` be generated as a function, it was just a quoted piece of code that got spliced in everywhere it's used?

Notice that character classes (e.g., `.`, `%w`, `[a-zA-Z]`, etc.) get unrolled during parsing into conjunctions of many atomic terms. How might that affect performance?