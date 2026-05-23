# Tira Insights — Design Theme

A warm editorial palette built for analytical storytelling. Born from the AOV Deep Dive newsletter; lifted out so you can use it anywhere.

> The aesthetic: a 1990s consulting white paper, redrawn for screen. Cream paper, charcoal ink, Georgia headlines, gold accents. Calm, considered, data-confident.

---

## What's in here

| File | What it is |
|---|---|
| `theme.css` | The complete drop-in stylesheet — palette, type, components |
| `style-guide.html` | A visual reference rendering every component |
| `starter.html` | A blank document seeded with the theme — use this as a base |
| `README.md` | This file |

---

## Quick start

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Your Document</title>
  <link rel="stylesheet" href="theme.css" />
</head>
<body>
  <h1 class="t-hero">Your <em>headline</em> here.</h1>
  <p class="t-lede">An italic serif lede sets the tone.</p>
  <p class="t-body">Body copy in Inter sans. <b>Bold for emphasis.</b></p>
</body>
</html>
```

`theme.css` imports Inter from Google Fonts. Georgia is system-installed. No build step required.

---

## The palette

The theme is built on **three semantic accent colours**. Use them consistently:

| Token | Hex | Meaning |
|---|---|---|
| `--gold` | `#A87C30` | Positive signal · "build this" · highlight |
| `--sage` | `#4F7259` | Healthy state · growth · sweet-spot |
| `--blush` | `#8A4F48` | Risk · leak · "stop this" |

The neutrals carry the page:

| Token | Hex | Use |
|---|---|---|
| `--paper`   | `#F6F2E9` | Primary background |
| `--paper-2` | `#EFE9DA` | Chart frames, secondary bands |
| `--paper-3` | `#E7E0CC` | Default bars, ghost numbers |
| `--ink`     | `#1A1A1A` | Body text, primary headings |
| `--ink-soft`| `#2A2A2A` | Paragraph text |
| `--muted`   | `#5A5A5A` | Decks, captions |
| `--subtle`  | `#8C8C8C` | Metadata, footers |

---

## Typography

- **Headings** — Georgia, weight 700, tight letter-spacing. Italics carry the accent colour.
- **Lede + deck** — Georgia italic, in `--muted`. Sets the introspective tone.
- **Body** — Inter 400, generous line-height. `<b>` returns to ink-black for emphasis.
- **Eyebrows + labels** — Inter 600/700, uppercase, tracked at 0.22–0.32em.

```html
<h1 class="t-hero">Big <em>question.</em></h1>
<p class="t-lede">Italic introduction in muted serif.</p>
<p class="t-body t-dropcap">Drop-cap paragraph for opening sections...</p>
```

---

## Components

The theme ships with these reusable patterns:

- `.t-eyebrow` — pre-headline label with a gold rule
- `.t-strip` — horizontal stat row with rule dividers
- `.t-keystat` — single big-number stat block
- `.t-pullquote` — bordered italic callout (gold / sage / blush)
- `.t-chart` — chart frame with title, subtitle, and footnote
- `.t-card` / `.t-card-ink` — light or dark card with semantic accent
- `.t-closing` — full-width dark closing band with radial gold wash
- `.t-masthead` — top-of-document brand rule
- `.t-section-num` — large ghost numeral for chapter heads

See `style-guide.html` for every variant.

---

## Inline SVG charts

`theme.css` styles inline SVG charts via these classes — drop them on the right elements:

```css
.axis-line     /* Inner axis stroke */
.grid-line     /* Subtle background gridlines */
.axis-text     /* Tick labels */
.axis-text-bold/* Emphasised category labels */
.value-text    /* Bar value labels */
.bar-default   /* Neutral bar fill */
.bar-gold      /* Highlighted bar */
.bar-blush     /* Risk-flagged bar */
.bar-sage      /* Positive-flagged bar */
```

---

## Print

The theme is print-friendly out of the box:

- All `background-color` rules use `-webkit-print-color-adjust: exact`
- `--paper` is enforced on `html` and `body` when printing
- Set your own `@page` size in the consuming document for paged layouts

---

## Conventions

- Use **italics in the accent colour** to mark emphasis — never bold for tone.
- Use **gold for things you want more of**, **blush for things you want less of**, **sage for healthy/protected territory**.
- Keep eyebrows short, tracked, and pre-headline — they act as section badges, not titles.
- Drop-caps go in opening paragraphs of major sections only.
- Pull quotes belong in two places: after an opening claim, or before a turn.

---

*Theme extracted from Tira Insights · Vol. II · The Premium Question · May 2026.*
