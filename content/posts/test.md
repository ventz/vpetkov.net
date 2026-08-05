+++
title = 'Test'
date = 2024-01-19T12:43:01-05:00
draft = true
+++

Here is some example code:

```python
while True:
    q=input("> ")
    #print(">"+q+'\n')
    r = index.query_with_sources(q)
    print(r['answer'] + '\n' + "Source: "+r['sources'])
    print('')

```
<!--more-->
