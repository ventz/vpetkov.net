---
title: "{{ replace .File.ContentBaseName "-" " " | title }}"
# URL slug comes from the filename, not the title -- keeps punctuation
# (periods, colons, question marks) out of the permalink.
slug: "{{ .File.ContentBaseName }}"
date: {{ .Date }}
draft: true
tags: []
description: ""
---

Opening paragraph — this doubles as the card preview and search snippet, so lead
with the answer/outcome.

<!--more-->

## First Section

Body text. Delete this template scaffolding before publishing.
