-- Post tags: one source of truth, rendered once.
--
-- A post declares its topics in frontmatter with `tags:` — "negative binomial",
-- "bootstrap", "biased sampling". Quarto renders `categories` into the DOM as
-- chips and drops `tags` entirely: it is metadata for search and listings, not
-- something the default template prints. Verified on 1.9.38: there is no
-- keywords meta tag and no tag markup in the output.
--
-- So the tags are emitted here as one hidden div of plain spans, and
-- theme/post-meta.html moves them into the post's metadata rule beside the
-- engine and frozen chips. Authoring them once in frontmatter is the whole
-- point: a hand-written second copy in the body is the thing that would drift.
--
-- If this filter does not run, nothing is stated wrongly — the page simply has
-- no tag chips, the same silent fallback the category accents and the engine
-- chip use. That matters more than it sounds: a wrong tag is a claim about what
-- a post is about, and this site's whole pitch is that claims are checked.

local function escape(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

function Pandoc(doc)
  local tags = doc.meta.tags
  if not tags then return nil end

  local spans = {}
  for _, tag in ipairs(tags) do
    local text = pandoc.utils.stringify(tag)
    if text ~= "" then
      table.insert(spans, '<span class="post-tag">' .. escape(text) .. "</span>")
    end
  end

  if #spans == 0 then return nil end

  doc.blocks:insert(1, pandoc.RawBlock(
    "html",
    '<div class="post-tags" hidden>' .. table.concat(spans) .. "</div>"
  ))

  return doc
end
