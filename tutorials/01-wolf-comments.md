# Wolf's General Comments on Tutorial 1: Your First XID

- I recommend adoption of the terminal input/output style I use in all our other documentation. I arrived at these conventions after a lot of experimentation and have reasons for all of them:
    - No emoji preceding terminal blocks.
    - Triple-backtick code fences for a single input and output pair.
    - No syntax highlighting (no language specifier after opening backticks).
    - Input followed by a blank line, then output.
    - Output lines prefixed with `│ ` to distinguish them from input. Note that this character is not a pipe (`|`), but a box-drawing character (U+2502).
- I have updated the tutorial to follow these conventions.

- The tutorial blurs the distinction between XID and XID Document. I think we should be clear which we are referring to in each context. Since "XID Document" can get unwieldy, I have begun to use the shorthand `XIDDoc` to refer to XID documents, and only use `XID` to refer to the identifier itself.

- The text implies that the nickname added in the first example (`BRadvoc8`) is the name of the XIDDoc itself. However the nickname is associated with the *key* and not the document.

- The examples given for the distinction between known values and strings is confusing: in the example `'nickname'` is a known value. The only string used in the example is `"BRadvoc8"`.

- They should be called "known value" predicates, not just "known predicates", because known values aren't just for predicates; they can be used as values too (as in the case of `'allow': 'All'`).
