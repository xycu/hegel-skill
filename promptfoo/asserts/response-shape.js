// Deterministic custom assert (#29): a structural check on the response shape, with
// no model judgment and no keyword matching (so it can't flake at high temperature).
//
// Brandt's answers are substantive prose, not a one-liner or a refusal. This asserts
// the output is a non-trivial multi-sentence response and records its shape (sentence
// and character counts) as a metric. Thresholds are deliberately loose — this guards
// against empty / truncated / one-word degenerate outputs, not literary quality
// (that is llm-rubric's job, #31).
module.exports = (output) => {
  const text = (typeof output === 'string' ? output : String(output ?? '')).trim();
  const chars = text.length;
  // Count sentence-ish terminators; em-dashes and ellipses are common in the voice.
  const sentences = (text.match(/[.!?…]+(\s|$)/g) || []).length;
  const ok = chars >= 200 && sentences >= 2;
  return {
    pass: ok,
    score: ok ? 1 : 0,
    reason: `response shape: ${chars} chars, ${sentences} sentences`,
  };
};
