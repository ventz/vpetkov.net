---
title: "Flying a Goose With OpenAI's Decisions API"
# URL slug comes from the filename, not the title -- keeps punctuation
# (periods, colons, question marks) out of the permalink.
slug: "flying-a-goose-with-openais-decisions-api"
date: 2026-10-11T16:15:00-04:00
draft: false
tags:
  - ai
  - openai
  - python
  - games
  - open-source
cover:
  image: "https://raw.githubusercontent.com/ventz/honk-game-openai-decision-api/main/docs/images/banner.jpg"
  alt: "Two frames from Honk in endless mode: the goose flying between wavy rows of pipes at a score of 18, and the final score of 23"
description: "OpenAI's Decisions API is built for classification, not reflexes. I wired it into Honk, a Flappy Bird-style game inside Reddit, to see if a hosted model could fly a goose through pipes in real time. It finishes the test level 20 out of 20 times and has passed 23 pipes in endless mode."
---

OpenAI's new Decisions API is built for classification: routing tickets, flagging content, scoring things. It returns a typed answer (a probability, a choice, a score) instead of text, and it is pitched as about 10x faster than the Responses API. So I gave it the most unfair test I could think of: flying a goose through pipes in [Honk](https://www.reddit.com/r/honk/), a Flappy Bird-style game that runs inside Reddit. It finishes the test level **20 out of 20** times at about 110-150ms per decision, and in endless mode it has flown through **23 pipes** on camera: [https://github.com/ventz/honk-game-openai-decision-api](https://github.com/ventz/honk-game-openai-decision-api)

<!--more-->

## The run

{{< figure src="https://raw.githubusercontent.com/ventz/honk-game-openai-decision-api/main/docs/images/flying.jpg" alt="The goose flying through endless mode at pipe 21. The banner across the top reads: OpenAI Decisions (gpt-6-luna) flying, game state, FLAP p=0.97, 201ms, taps 58." link="https://x.com/ventzpetkov/status/2109380287415345487" target="_blank" rel="noopener noreferrer" caption="Pipe 21 of 23, at 2x speed. The banner shows each decision live: here the model says FLAP with p=0.97, 201ms after it was asked. Click to watch the video on X." >}}

A reflex game is a brutal test for a hosted model. The goose falls on every frame, a gap is only a few goose-heights tall, and an answer that arrives 300ms late is already wrong. It works, but only after three discoveries.

## Ask a fact, not an action

The model is asked one question per decision, and the wording turned out to be the whole program. Worded as an action plus a rule ("flap if the goose will be below the middle; do not flap if above"), the answers came back *inverted*: p=0.99 to flap when the goose was 40 pixels *above* the middle.

Asked as a plain fact instead ("Will the goose be below the middle of the gap?"), given one sentence like "The goose will be 40 pixels below the middle of the gap," it answered p=1.00 or p=0.00 and was right every time. The code taps when the probability is at least 0.5. The model judges the fact; the action stays in code.

Raw screen coordinates and velocities did not work either. Plain words did.

## Predict the future

A decision takes about 110-150ms, or 7-9 frames at 60fps, and the goose keeps falling the whole time. Asking about where the goose *is* gets you an answer about the past.

So the bot runs the game's own physics forward and asks about where the goose *will be* when a tap sent now actually lands. I measured the physics from the live game rather than assuming textbook gravity:

```
each frame:  y += scale*v;   v = min(10, 0.98*(v + 0.4))     (a flap sets v = -6.3)
```

That predicted a 23-frame fall to within 0.1px. The textbook `y + v*t + 1/2*g*t^2` it replaced was 59px short, which is most of a gap.

## Never wait on one slow answer

Latency is not constant. Most answers come back in 110-150ms, but some take 300ms or more, and a cold HTTPS connection took about 750ms on the first call - long enough to crash. So the bot never waits on any single request:

- A new question goes out every 25ms, with up to 8 in flight at once. Only the newest answer acts.
- Answers older than one already acted on are thrown away.
- Answers based on a frame read within 60ms of a tap are thrown away too, because the tap had not registered yet. Acting on those caused double flaps straight into the top pipe.
- Anything slower than 250ms is dropped and stops counting toward the in-flight limit, so a burst of slow responses can't stall new questions. That one fix took it from 12/13 to 20/20.

## Getting inside the game

Honk is a Devvit app: a web app Reddit hosts in an iframe. The bot attaches to a separate Chrome window over the DevTools protocol and finds that iframe. Inside, the game turned out to be a PixiJS canvas that exposes its whole state on `window.gameInstance`: the goose's hitbox, velocity and death flag, plus every obstacle, the gravity, the scroll speed and the finish line. Reading all of that takes about 4ms, against 40-80ms for a screenshot.

I tried screenshots too. At 360px the model could not judge fine vertical alignment, answered "above" on every frame, and never flapped once: 0/10.

## Results

| Setup | Result |
|---|---|
| Game state + factual question + tap settle + stall handling | **20/20** on the test level, 110ms median |
| Same, without stall handling | 12/13 |
| Same, without the tap settle | 7/10 |
| Earlier wordings (raw numbers, action rules) | 0/7 |
| Screenshots + factual above/below choice | 0/10 |
| Endless mode, 10 runs on camera | 10, 4, 8, 4, **23**, 2, 2, 14, 4, 2 |

Endless mode is the real test, and it is still in progress. The gaps are tighter, the speed ramps up, and later pipes come in wavy rows and move. Scores swing widely with the API's latency, which changes hour to hour. The full write-up, including what didn't work, is in [docs/findings.md](https://github.com/ventz/honk-game-openai-decision-api/blob/main/docs/findings.md).

## Fair play

This is an experiment in model latency and reliability, not a way to farm a leaderboard. The bot plays with your logged-in Reddit account, so please don't use it to compete with human players.

The code is MIT licensed: [https://github.com/ventz/honk-game-openai-decision-api](https://github.com/ventz/honk-game-openai-decision-api)
