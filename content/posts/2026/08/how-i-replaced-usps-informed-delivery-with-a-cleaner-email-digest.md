---
title: "How I Replaced USPS Informed Delivery With a Cleaner Email Digest"
# URL slug comes from the filename, not the title -- keeps punctuation
# (periods, colons, question marks) out of the permalink.
slug: "how-i-replaced-usps-informed-delivery-with-a-cleaner-email-digest"
date: 2026-08-09T20:06:44-04:00
draft: false
tags:
  - usps
  - automation
  - aws
  - lambda
  - ses
  - email
  - ai
  - python
cover:
  image: "https://raw.githubusercontent.com/ventz/usps-informed-delivery-no-ads/main/screenshots/2026-08-06-clean.png"
  alt: "The rebuilt USPS digest: packages first with status and tracking, then the one real mail scan, with no advertising"
description: "Half of my Informed Delivery digest is advertising shown instead of my actual mail, because USPS lets mailers replace the scan of your envelope with a marketing image. So I built a small pipeline that strips the ads and re-sends a clean, self-contained email."
---

When USPS Informed Delivery was announced, I was genuinely excited. Scans of your mail, in your inbox, before it arrives - that felt like a real step toward modernization. Then USPS did what USPS does, and butchered the execution. Today the digest contains more ads and "look over here" banners than the two things I actually care about: am I getting mail and packages, and when. So I built something that fixes it: [https://github.com/ventz/usps-informed-delivery-no-ads](https://github.com/ventz/usps-informed-delivery-no-ads)

<!--more-->

**Updated 8/16/2026: how to actually stop the mail.** This tool makes the digest readable, but it does not stop the junk arriving. I went looking for what actually works and found most of the published advice is stale or wrong - the FTC's own page still quotes DMAchoice at $6 when it is $8, five widely cited opt-out URLs are dead outright, and the data-removal services that dominate those search results make no postal-mail claim on their own pricing pages. So I wrote it down properly: [How to stop physical junk mail](https://github.com/ventz/usps-informed-delivery-no-ads/blob/main/docs/stopping-junk-mail.md) - a printable checklist, every URL verified. Almost all of it is a one-time afternoon. The two things no guide mentions: the opt-outs expire, and moving silently voids them.

## The problem is not clutter - it is replacement

This is the part that took me a while to notice, and it is worse than it sounds.

USPS runs a program called interactive campaigns. A mailer can supply a "Representative Image", which in USPS's own words is "used in lieu of a flat-size image or in place of a grayscale letter-size image". In place of. Their marketing creative does not appear *next to* the scan of your envelope, it appears *instead of* it. And a campaign always ships an ad with it, because the clickable "Ride-along Image" is not optional: "The Ride-along Image is always required."

The part I got wrong when I first looked into this, and worth correcting: USPS does not *sell* that slot. Per their [own campaign FAQ](https://www.usps.com/business/pdf/informed-delivery-faqs.pdf), a campaign "is provided at no additional cost to mailers", though they "reserve the right to monetize new aspects of Informed Delivery in the future". So the one genuinely modern product they shipped degrades your view of your own mail, and they are not even charging for it yet.

I measured it across 19 real digests from a one month stretch:

| | |
|---|---|
| Mailpieces announced | 34 |
| Real envelope scans provided | **17** (50%) |
| Advertiser image files | **36** |
| Days with mail but zero scans | 4 |

Half. Half of my mail was hidden behind an ad in the email whose entire purpose is to show me my mail. On one day, both announced mailpieces ran campaigns, so the "Daily Digest" contained exactly none of my mail. On another, an advertiser's banner was 35,593 bytes - physically larger than the 31,980 byte scan it displaced.

It was one of those small things that goes from mild nagging to genuinely frustrating. I have opened a few feedback tickets over the last year about how confusing these emails are. Nothing changed. So the time came to do something about it.

## Before and after

Here is a real digest. Three mailpieces announced, one actual scan, five advertiser images. USPS needs two full screens to tell me that:

{{< figure-row >}}
{{< figure src="https://raw.githubusercontent.com/ventz/usps-informed-delivery-no-ads/main/screenshots/2026-08-06-usps-1.png" alt="USPS Informed Delivery digest, first screen: a greeting, a mailpiece counter, and an advertiser image where a mail scan should be" link="https://raw.githubusercontent.com/ventz/usps-informed-delivery-no-ads/main/screenshots/2026-08-06-usps-1.png" target="_blank" rel="noopener noreferrer" caption="Screen 1 of 2" >}}
{{< figure src="https://raw.githubusercontent.com/ventz/usps-informed-delivery-no-ads/main/screenshots/2026-08-06-usps-2.png" alt="USPS Informed Delivery digest, second screen: another advertiser image, empty package sections, and a referral banner" link="https://raw.githubusercontent.com/ventz/usps-informed-delivery-no-ads/main/screenshots/2026-08-06-usps-2.png" target="_blank" rel="noopener noreferrer" caption="Screen 2 of 2" >}}
{{< /figure-row >}}

Two full screens, and exactly one real mailpiece scan in all of it. Click either to enlarge.

### The same day, rebuilt

Everything above, minus the advertising, is this:

{{< figure src="https://raw.githubusercontent.com/ventz/usps-informed-delivery-no-ads/main/screenshots/2026-08-06-clean.png" alt="The rebuilt digest: packages first with status and tracking, then the one real mail scan labeled FINANCIAL, then a note naming the advertisers that replaced the other two mailpieces" width="340" link="https://raw.githubusercontent.com/ventz/usps-informed-delivery-no-ads/main/screenshots/2026-08-06-clean.png" target="_blank" rel="noopener noreferrer" caption="One screen. Click to enlarge." >}}

Packages first, with status and tracking. Then mail, labeled by type, flagged when something actually needs attention. And critically, an honest line at the bottom: "USPS did not provide a scan for 2 mailpieces. Replaced by advertising from: USPS HR, save-select homes." Silently dropping the ads would make an ad-only day render as a blank page that looks like a bug. Naming what was taken makes the loss visible.

## How it works

The whole thing is about a thousand lines of Python. Forward a digest to an address handled by SES, which drops the raw message in S3, which triggers a Lambda that parses the MIME, rebuilds the email, and sends it back to me. Roughly 15 seconds end to end. There is a diagram of the flow here: [https://github.com/ventz/usps-informed-delivery-no-ads#architecture](https://github.com/ventz/usps-informed-delivery-no-ads#architecture)

Two decisions did most of the work:

**Ad-stripping is a filename deny-list, not an AI judgment call.** The attachments split cleanly: advertiser creative is always named `mailer-*.jpg` or `content-*.jpg`, real scans are not. That is a two line filter, and it cannot hallucinate.

**Ask the model only what the email does not already state.** My first version asked a vision model to read the sender off each scanned envelope. It was unstable - the same envelope returned the bank's name on one run and the bare PO Box from the return address on the next. Then I noticed USPS renders each scan directly beneath a `FROM:` heading, which means the sender is already stated in the markup, positionally. Parsing it is deterministic and free. The model now only does what genuinely is not in the email: reading a sender off an envelope when USPS supplies no label at all.

That second lesson generalizes well beyond this project, and it is the one I keep re-learning: every field I asked a model for that was already knowable from the source turned out flaky. Every field I derived from the source turned out stable.

So the AI footprint here is deliberately small: one OpenAI vision call per envelope scan that survives the ad filter, asked only for what the email genuinely does not state - what kind of mail the piece is, and who in the household it is addressed to. Ads are dropped before that call, so advertiser creative never gets uploaded, and leaving the API key unset simply drops the type labels rather than breaking the digest. The full breakdown of what it is and is not asked for, including the privacy trade-off, is here: [https://github.com/ventz/usps-informed-delivery-no-ads#what-openai-is-used-for](https://github.com/ventz/usps-informed-delivery-no-ads#what-openai-is-used-for)

The whole thing took a few hours with Claude Code, most of it spent on the corpus analysis rather than the code. It has been running unattended since, and every digest has come back clean.

## The part nobody at USPS wants to talk about

There is an excellent piece on [USPS financial viability](https://www.kcra.com/article/usps-financial-viability-congress-action/73249258) that puts this in context, and it is worth reading in full.

Two things stand out. First, physical mail is a thing of the past and is dying, faster lately: the agency "is now delivering approximately the same amount of annual mail as it did in the early 1980s." Nobody needs, or wants, six day a week delivery of that. Second, the days are numbered. By deferring payments to worker retirement funds it bought back some time, and Postmaster General David Steiner estimated to Congress that the service now has until somewhere between 2031 and 2035 before it runs out of cash. Look at the chart titled "USPS revenue outpaced by expenses each year since 2006" and it is hard to conclude anything other than that the math stopped working around 2009.

Given that data, the response has been to sell more ad space in the one genuinely useful modern product they shipped.

As a ps, for those who did not know: the agency is a protected monopoly that has largely covered its own costs by selling stamps, and the sale of stamps is no longer enough to make up the difference even with price increases. If this were any other business, it would have shut down a long time ago.

Until someone at USPS decides the digest should show you your mail, there is this: [https://github.com/ventz/usps-informed-delivery-no-ads#quick-setup](https://github.com/ventz/usps-informed-delivery-no-ads#quick-setup)
