---
title: "The Internet Changed. So Did This Blog."
slug: "the-internet-changed-so-did-this-blog"
date: 2026-08-06T17:50:12-04:00
draft: false
tags:
  - meta
  - hugo
  - blogging
  - website
  - ai
description: "After years of maintaining a complex WordPress stack, Linux servers, a Datacenter Colo, and other infrastructure, I decided it was time to simplify—not just my website, but also what I write about."
---

After years of maintaining a complex WordPress-based blog, Linux servers, and a Datacenter Colo, I decided it was time to simplify. This new site is built with Hugo and focuses on one thing: making it easy to write and share ideas instead of spending my limited free time maintaining infrastructure. At the same time, I think we're at another inflection point on the internet—one where AI is changing not only *how* we build software, but also what kinds of technical content are worth publishing.

<!--more-->

## Why Start Over?

Over the years, life simply got busier.

Between work, family, and everything else that comes with life, the amount of uninterrupted time I have to spend on personal projects is much smaller than it used to be. When I *do* have a few free hours, I'd much rather spend them building something interesting than maintaining the platform I'm writing on.

My previous setup wasn't particularly fragile—in fact, almost everything was automated—but it had grown into a surprisingly large stack. Just to publish a simple post, I was effectively maintaining:

- Ubuntu
- Apache
- PHP
- MySQL
- WordPress
- Themes
- Plugins
- Backups
- Security updates and monitoring
- IAM, authentication, SSO, and 2FA
- Deployment and automation scripts

That's a lot of infrastructure for what is, at its core, a collection of Markdown articles.

Eventually I realized I was spending more time maintaining the blog than writing for it. That wasn't the trade-off I wanted anymore.

## Rediscovering Simplicity

Over the last five to six years, I've grown to appreciate the elegance of static websites.

Write in Markdown. Commit to Git. Deploy automatically.

That's really all I wanted.

That, and I still wanted complete control over how the site was built, deployed, and hosted. Hugo gives me that flexibility without adding complexity.

Modern static site generators offer incredible performance, security, scalability, and deployment flexibility—all with virtually no operational overhead. There's something satisfying about eliminating entire classes of problems simply by removing the technologies that create them. And perhaps most importantly, they eliminate an entire class of security concerns that come with running a dynamic web application.

In reality, I wasn't looking for a full-featured publishing platform anymore. I just wanted a place to quickly share interesting projects, technical deep dives, automation ideas, and the occasional how-to—a step above a collection of GitHub Gists.

## Why Hugo?

When it came time to rebuild, I evaluated just about every major static site generator I could find, including Hugo, Jekyll, Gatsby, Eleventy, Hexo, Docusaurus, and MkDocs.

Each has its strengths, but Hugo checked all the boxes for me:

- Extremely fast builds
- Simple Markdown-based workflow
- Flexible templating
- Minimal dependencies
- Easy deployment to virtually any hosting provider

I'll save the details for another post, but Hugo felt like the right balance between power and simplicity.

## The Internet Changed (Again)

Years ago, if you wanted to figure out how to do something obscure, you were often on your own.

Maybe you wanted to compile a custom Android kernel, integrate a Perl script with Amazon SES, or get Widevine DRM working on a Raspberry Pi. Those projects often took an entire weekend of research, experimentation, trial and error, and digging through forum posts before you finally had something that worked.

Those were exactly the kinds of things I enjoyed writing about.

Today, that world looks very different.

Modern LLMs from OpenAI, Anthropic, and Google can often produce a working solution after just a few prompts. They aren't perfect, but they're remarkably good at answering the kinds of "How do I...?" questions that used to drive people to technical blogs, along with implementing technical solutions.

That's a good thing.

It also means the internet has changed—yet again.

A number of years ago, my college friend Mike Burns wrote an excellent post titled *"[The Internet Is Gone](https://mike-burns.com/gone.html)"*, reflecting on how the web had evolved from the one we grew up with. Reading it today, I think we're in the middle of another major shift.

Search engines are no longer the primary destination for technical knowledge. Neither are blogs. Increasingly, people ask an AI assistant first and only reach for search engines when they need more context or verification.

That fundamentally changes the value of publishing another "How to install X on Ubuntu" tutorial.

## So What *Is* Worth Writing?

Personally, I think straightforward technical tutorials have become a commodity.

That doesn't mean blogging is dead—it just means the interesting parts have shifted.

LLMs are excellent at synthesizing information that's already out there. They're much less effective at generating genuinely new experience.

If nobody has ever tried an approach before, measured the results, compared architectures, or documented the trade-offs, there isn't much for an AI to synthesize.

Someone still has to do the work.

The exciting part is that AI also helps us do that work faster. It accelerates research, helps validate ideas, writes code, reviews designs, and removes much of the repetitive effort involved in building something new. But it's still up to us to ask the right questions, run the experiments, evaluate the results, and share what we learn.

What still excites me are things that AI can't easily fully synthesize (yet):

- Experiments
- Proofs of concept
- Lessons learned
- Architectural trade-offs
- Unexpected failures
- Surprising discoveries
- Connecting ideas across different technologies
- The bigger picture

In other words, the kinds of things you only get by actually building something.

Those are the stories I want to tell.

## Looking Ahead

For the last five to six years, I've been working almost exclusively with Generative AI.

During that time I've built, evaluated, or advised on hundreds of projects, prototypes, and proof-of-concepts spanning a wide range of industries and use cases.

Some succeeded.

Some failed spectacularly.

Almost all of them taught me something.

I'm hoping this blog becomes a place where I can share some of those lessons—not just prompts or snippets of code, but the design decisions, trade-offs, failures, surprises, and patterns that only become obvious after you've built enough of these systems.

I'll still write about cloud infrastructure, automation, programming, open source, homelabs, and whatever technical rabbit hole I happen to be exploring.

The difference is that I probably won't spend three pages explaining how to configure a particular tool or reproduce every command I typed along the way. AI is remarkably good at filling in those details.

Instead, I'd rather focus on *why* I chose a particular approach, what worked, what didn't, the trade-offs I discovered, and the lessons I learned while building it.

Those are the parts that I still find interesting—and, hopefully, useful to others.

## What Happened to the Old Blog?

I've archived my old site, but you can still browse all of the posts under the [Old WordPress Blog](/tags/old-wordpress-blog/) tag, including the last article published on March 30, 2020.

There's still plenty of content there that's worth preserving, and it's also a fun snapshot of the technologies and approaches I was using over the years. Think of it as a small piece of personal—and internet—history.

## One Final Irony

Generative AI may have made many traditional technical blog posts less valuable, but it also makes writing *better* blog posts dramatically easier.

This article, for example, started as a handful of scattered notes and half-finished thoughts. AI helped organize them into something coherent while leaving the opinions, experiences, and perspective entirely my own.

I think that's a pretty good use of the technology.

---

Welcome to the new site. It's cleaner, simpler, faster, and, most importantly, lets me spend less time maintaining infrastructure and more time experimenting, learning, and sharing what I discover along the way.
