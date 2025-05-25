# TODO

- [ ] Handle container class.
- [ ] "-auto" is currently allowed as len.
- [ ] Check why decoration, shadow, caret, fill, stroke and outline uses hex colors instead of rgb.
- [X] BUG: "columns-12" ignores "2".
    `['0'-'9'] | ('1' ('0' | '1'))` is non greedy.
- [ ] TODO: Do not delay theme eval. Currently eval will delay checking the
  syntax of CSS blocks to allow easy passing of `g` (matched re group). This
  results in potentially "late" schema checks: if the schema is wrong, only
  certain inputs will trigger the checks.
- [ ] Handle !important.
- [ ] Handle custom values.
