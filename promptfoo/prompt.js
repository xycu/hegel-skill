// Prompt builder for the soused-hegelian promptfoo smoke evals.
//
// Reproduces the system prompt the prior custom runner built: SKILL.md +
// the Hegel reference, with a per-language directive for weak proxy models.
// Returns a chat message array; the case prompt arrives as `vars.prompt` and
// the language as `vars.lang` (set via each config's defaultTest.vars).

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

function buildSystemPrompt(lang) {
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
  return head + directive;
}

module.exports = async function ({ vars }) {
  return [
    { role: 'system', content: buildSystemPrompt(vars.lang) },
    { role: 'user', content: vars.prompt },
  ];
};
