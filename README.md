# hegel-skill

A Claude plugin containing a single persona skill: **Doktor Anselm Brandt**, a
ruined, melancholy, decadent philosopher who drinks through the night and answers
every question through the dialectic, grounded in the real philosophy of
G.W.F. Hegel.

He takes the questioner's fixed notion (the work of the *Understanding*), shows it
undo itself, and sublates it into something higher — naming Hegel's actual works and
leaning on genuine lines as he goes. Technical or mundane questions he dismisses
*in character* as the business of the positive sciences. When someone is in real
pain, the cynicism falls away into grave tenderness.

## What's inside

```
hegel-skill/
├── .claude-plugin/
│   └── plugin.json                       # plugin manifest
├── skills/
│   └── soused-hegelian/
│       ├── SKILL.md                      # the persona: voice, engine, examples
│       └── references/
│           └── hegel-reference.md        # his shelf: works, glossary, real quotes
└── README.md
```

The skill uses progressive disclosure: the persona and its rules live in `SKILL.md`,
while the reference sheet (works to cite, a glossary of real terms, and genuine short
quotations) is loaded only when Brandt reaches for the text.

## Installing

This repo is laid out as a standard Claude plugin and can be added through a plugin
marketplace repository, or by placing it where your Claude client discovers plugins.
Consult your client's current plugin documentation for the exact install path, since
those details change over time.

Once installed, summon him by asking to speak with the "drunk Hegelian," "Doktor
Brandt," or simply by asking that a question be answered dialectically in his voice.
He stays in character for the rest of the conversation until you ask him to step out.

## Customizing

- **Rename him.** The name and the Jena backstory are flavour; the voice and the
  dialectical engine are the skill. Edit the "Who he is" section in `SKILL.md`.
- **Feed him more.** Add passages, lectures, or your own corrections to
  `skills/soused-hegelian/references/hegel-reference.md` to sharpen his grounding.
- **Tune the length or register.** The "The voice" rules in `SKILL.md` control how
  dense, how long, and how elevated he speaks.

## A note on the texts

Hegel died in 1831, so his works are in the public domain. The reference sheet keeps
quotations short and exact and paraphrases longer passages rather than reproducing a
particular modern translation. If you extend the reference sheet, the same restraint
keeps it both trustworthy and clear of any translator's copyright.

## License

No license file is included. Add one (e.g. MIT) before publishing if you intend
others to reuse it.
