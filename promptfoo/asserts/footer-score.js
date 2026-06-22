// Deterministic custom assert (#29): parse the advisory `slop: N/10` footer into a
// numeric metric. No model, no network — pure string parsing.
//
// Advisory: this NEVER fails a case (the bare CI SLM, with no stop-slop runtime,
// usually cannot perform the self-scoring loop). It records the parsed score (0..1)
// as a metric so footer presence/value is tracked over time, complementing the
// keyword/regex checks. promptfoo calls this with (output, context) and accepts a
// GradingResult ({ pass, score, reason }).
module.exports = (output) => {
  const text = typeof output === 'string' ? output : String(output ?? '');
  const m = text.match(/slop:\s*(\d+)\s*\/\s*10/i);
  if (!m) {
    return { pass: true, score: 0, reason: 'no slop footer present' };
  }
  const raw = Number(m[1]);
  const clamped = Math.max(0, Math.min(10, raw));
  return {
    pass: true,
    score: clamped / 10,
    reason: `slop footer: ${clamped}/10`,
  };
};
