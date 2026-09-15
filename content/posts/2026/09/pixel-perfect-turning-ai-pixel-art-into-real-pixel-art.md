---
title: "Pixel-Perfect: Turning AI Pixel Art Into Real Pixel Art"
# URL slug comes from the filename, not the title -- keeps punctuation
# (periods, colons, question marks) out of the permalink.
slug: "pixel-perfect-turning-ai-pixel-art-into-real-pixel-art"
date: 2026-09-15T06:15:00-04:00
draft: false
tags:
  - pixel-art
  - ai
  - python
  - image-processing
  - open-source
cover:
  image: "https://raw.githubusercontent.com/ventz/pixel-perfect/main/docs/images/before-after-banner.png"
  alt: "AI pixel art before and after restoration: blurry and uneven on the left, crisp true pixels on the right"
description: "AI image models produce art that only looks like pixel art - drifting grids, blurry edges, and tens of thousands of colors. Pixel-Perfect recovers the real grid and rebuilds a true pixel-perfect image, with no model, no GPU, and no network."
---

Ask any image model for "pixel art" and you get something that looks right from across the room and falls apart the moment you try to use it. Zoom in and the "pixels" are different sizes, the edges are blurry, and a sprite that should have 16 colors has 40,000. So I built a tool that recovers the real image hiding underneath: [https://github.com/ventz/pixel-perfect](https://github.com/ventz/pixel-perfect)

<!--more-->

## Before and after

{{< figure src="https://raw.githubusercontent.com/ventz/pixel-perfect/main/docs/images/before-after.png" alt="Left: an AI-generated pixel art character with blurry edges, uneven cells, and tens of thousands of colors. Right: the same character restored to a true low-resolution pixel grid with a small palette and hard edges." link="https://raw.githubusercontent.com/ventz/pixel-perfect/main/docs/images/before-after.png" target="_blank" rel="noopener noreferrer" caption="Left: straight out of an image model. Right: restored. Click to enlarge." >}}

The left side is what the model actually gave me: a 1254x1254 image with 42,646 unique colors. The right side is what it was *trying* to draw: a tiny native sprite where every logical pixel is one solid color on a uniform grid, upscaled with nearest-neighbor so you can see it.

## Why AI pixel art is not pixel art

Real pixel art has a simple contract: every pixel is deliberate. Diffusion models do not work in pixels at all - they work in a compressed latent space and paint the result back out at high resolution. That breaks the contract in three ways:

- **The grid drifts.** The implied upscale factor is not constant, so one "pixel" is 17px wide and the one next to it is 15px, and the whole grid slowly slides off the integer lattice.
- **Edges are anti-aliased.** The decoder smooths every hard edge, which is exactly the thing pixel art exists to avoid.
- **Colors explode.** Instead of a deliberate palette you get hundreds or thousands of near-duplicates, plus JPEG noise on top.

You cannot fix that by just resizing down. If you guess the grid size wrong by even one cell, the error accumulates across the image and you get doubled lines and smeared features. Drop it into a game engine, a sprite editor, or a palette-swap shader and all three defects become very visible very quickly.

## How it works

Pixel-Perfect is deterministic image processing - no model, no GPU, no network calls. The pipeline:

1. **Find the grid period.** Edge energy is projected onto each axis and autocorrelated, which reveals how often the "pixels" repeat even when the cells vary in size.
2. **Fit a drifting grid.** Instead of forcing a uniform lattice, a dynamic-programming fit places each gridline individually while constraining how much neighboring cells can differ in width. That is what lets it follow a 17px cell followed by a 15px one.
3. **Score candidates by reconstruction.** Several nearby grid sizes are tried, and each is scored by how well it *explains* the source as damaged pixel art: collapse each cell to one color, rebuild the image, and measure the difference - only on the center of each cell, so blurry edges do not vote. The best explanation wins, and the per-cell error doubles as a confidence heatmap.
4. **Collapse and quantize.** Each cell takes the median color of its interior in OKLab (a perceptual color space), and the result is reduced to a small palette - either an automatic count or a named palette like PICO-8, Sweetie-16, or Endesga-32.

The output is the true native image (here 62x64) plus an optional nearest-neighbor preview at whatever scale you want.

## Using it

Setup is a clone and `uv sync`:

```bash
git clone https://github.com/ventz/pixel-perfect
cd pixel-perfect
uv sync
```

From the command line:

```bash
uv run pixelperfect restore sprite.png clean.png --palette 16 --upscale 8
```

Or start the web app with `uv run app.py` and open `http://127.0.0.1:8000`. It shows the detected grid over the source, lets you override the grid size or palette for the hard cases, and has a small built-in pixel editor (pencil, fill, eyedropper, undo) for the handful of cells no algorithm will ever get right. Every stage is also an API endpoint, and the core is a plain Python library if you want to script batches.

## Where it struggles

It is honest about uncertainty rather than pretending. Very sparse sprites with huge flat backgrounds give the scorer less to work with, very small cells (around 5px) can land one off, and art that was never on a grid to begin with has no grid to recover. In those cases the confidence score drops, and the manual grid override plus the editor are there for exactly that.

The better fix, where you control generation, is to avoid the damage in the first place - the repo has a write-up on that too: [Fixing pixel art at generation time](https://github.com/ventz/pixel-perfect/blob/main/docs/explanation/generation.md).

The code is MIT licensed: [https://github.com/ventz/pixel-perfect](https://github.com/ventz/pixel-perfect)
