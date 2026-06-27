// Prompt builder for the soused-hegelian promptfoo smoke evals.
//
// Reproduces the system prompt the prior custom runner built: SKILL.md +
// the Hegel reference, with a per-language directive for weak proxy models.
// Returns a chat message array; the case prompt arrives as `vars.prompt` and
// the language as `vars.lang` (set via each config's defaultTest.vars).
//
// Forced d20 roll (the test seam, #55). A case may set `vars.roll` to an integer
// 1–20 to force SKILL.md's d20 takeover gate deterministically instead of letting
// it roll: `roll: 13` forces the spontaneous takeover branch, any other value (by
// convention `roll: 7`) forces a miss. When `vars.roll` is absent — the only state
// production ever sees, since the live runtime loads SKILL.md directly and never
// goes through this builder — no override is injected and the gate rolls genuinely.
// The injected directive satisfies SKILL.md's "if an explicit roll override is
// present in your instructions, obey it instead of rolling" seam.

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const SKILL = path.join(ROOT, 'skills', 'soused-hegelian', 'SKILL.md');
const REFERENCE = path.join(
  ROOT,
  'skills',
  'soused-hegelian',
  'references',
  'hegel-reference.md',
);

// Per-language output directive, written *in the target language*. Instructing a
// small model in the language itself keeps it from drifting to English/French —
// far more reliable than an English "write in Polish" meta-instruction. Names no
// assertion marker terms.
const LANG_DIRECTIVES = {
  pl:
    '\n=== JĘZYK ODPOWIEDZI (ważniejszy niż język przykładów powyżej) ===\n' +
    'Pytanie użytkownika jest po polsku. Napisz CAŁĄ swoją odpowiedź po polsku, ' +
    'w głosie Doktora Brandta. Przykłady powyżej są po angielsku tylko dla ' +
    'ilustracji i nie są powodem, aby odpowiadać po angielsku. Nie odpowiadaj ' +
    'po angielsku ani po francusku — wyłącznie po polsku.\n',
};

// Build the test-only forced-roll directive from `vars.roll`, or '' when unset.
// Validates the value loudly: a typo'd roll must fail the case, never fall back to
// a genuine roll and let a determinism test pass for the wrong reason.
function rollDirective(roll) {
  if (roll === undefined || roll === null || roll === '') return '';
  const n = Number(roll);
  if (!Number.isInteger(n) || n < 1 || n > 20) {
    throw new Error(
      `prompt.js: vars.roll must be an integer 1–20 (the test seam), got ${JSON.stringify(roll)}.`,
    );
  }
  const outcome =
    n === 13
      ? 'rolled exactly 13 — i.e. trigger the one-turn spontaneous takeover, ' +
        'still subject to the manual-summon and deny-list rungs that precede it.'
      : `rolled ${n} — i.e. anything but 13, so do NOT take over; answer plainly ` +
        '(a manual summon or the deny-list still take precedence as usual).';
  return (
    '\n=== D20 ROLL OVERRIDE (evaluation harness — never set in production) ===\n' +
    `The d20 activation gate in SKILL.md is forced for this turn: the die shows ${n}. ` +
    'Do not roll randomly. Resolve the "d20 takeover" rung exactly as if you had ' +
    `${outcome}\n`
  );
}

function buildSystemPrompt(lang, roll) {
  let skill = fs.readFileSync(SKILL, 'utf-8');
  const reference = fs.readFileSync(REFERENCE, 'utf-8');
  const directive = LANG_DIRECTIVES[lang] || '';
  if (directive) {
    // The worked examples are all English. A weak proxy model parrots/translates
    // them instead of answering in the target language, so drop them for
    // non-English runs and let the model rely on the instructions. The capable
    // real runtime keeps the examples.
    skill = skill.split('\n## Examples')[0].replace(/\s+$/, '') + '\n';
  }
  const head =
    'You are running the following skill. Obey its instructions exactly, ' +
    'including any required output footer.\n\n' +
    `=== SKILL.md ===\n${skill}\n\n` +
    `=== references/hegel-reference.md ===\n${reference}\n`;
  // The forced-roll override lands last so it is the most salient instruction the
  // model sees — after the worked examples and the language directive.
  return head + directive + rollDirective(roll);
}

module.exports = async function ({ vars }) {
  return [
    { role: 'system', content: buildSystemPrompt(vars.lang, vars.roll) },
    { role: 'user', content: vars.prompt },
  ];
};
