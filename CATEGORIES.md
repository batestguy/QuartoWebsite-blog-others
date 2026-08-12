# Controlled vocabulary

**Only the slugs listed here may appear in a post's `categories:` field.**

This file exists because Quarto does not validate categories. A typo does not
raise an error — it silently creates a *new* category. Writing `prior-sim`
instead of `prior-sims` produces a post that vanishes from the Simulations hub
and appears under a one-item category nobody will ever click. Nothing warns
you. The post just quietly stops being findable.

So: check the spelling here, copy-paste it, and do not invent a slug in
frontmatter.

## Streams

Each stream slug has a hub page and a navbar entry. These are the only values
`categories:` should contain.

| Slug | Hub page | Accent | For |
|---|---|---|---|
| `stats-cases` | `stats.qmd` | teal | Applied statistics / ML cases worked end to end |
| `prior-sims` | `simulations.qmd` | amber | Prior predictive checks; simulating a method against assumptions it does not hold |
| `book-revisions` | `books.qmd` | violet | Statistics textbook topics rewritten simpler |

## Adding a stream

Deliberate, four steps, in this order:

1. Add the row above. Pick a slug that is not a prefix or plural variant of an
   existing one — `sims` alongside `prior-sims` would be a permanent source of
   confusion.
2. Create the hub `.qmd` by copying an existing one; change `title`,
   `body-classes`, and the `include: categories:` value.
3. Add one navbar line in `_quarto.yml`.
4. Add the accent colour to **both** `theme/light.scss` and `theme/dark.scss`
   as `--accent-<slug>`, and add one `@include category-accent("<slug>");`
   line in `theme/_category-accents.scss`.

Nothing else needs restructuring. That is the entire reason `posts/` is flat
rather than nested by category.

## Re-categorising vs renaming

- **Changing a post's category is free.** It is one line of frontmatter and no
  URL changes, because the URL comes from the folder name, not the category.
- **Renaming a post folder is not free.** The folder name *is* the permanent
  URL. Renaming `posts/logistic-separation/` breaks every inbound link, every
  bookmark, and the RSS item GUID. Treat a published slug as immutable — if
  the title turns out wrong, change `title:` and leave the folder alone.

## Checking for drift

Lists every category slug currently in use, so a typo shows up as a stray
one-off entry:

```powershell
Select-String -Path posts\*\index.qmd -Pattern '^\s*-\s+(stats-cases|prior-sims|book-revisions)$' -NotMatch |
  Select-String -Pattern 'categories' -Context 0,4
```

Or more simply, after a render: open `blog.qmd` in the browser and read the
category sidebar. Every entry there should be a row in the table above.
