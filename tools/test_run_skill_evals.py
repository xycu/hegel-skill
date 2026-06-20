"""Assertion-logic checks for run_skill_evals (no Ollama needed).

Run: python tools/test_run_skill_evals.py
"""
from run_skill_evals import check_case, has_slop_footer

# --- slop footer detection ---
assert has_slop_footer("text\n\n---\nslop: 3/10 (1 revision)")
assert has_slop_footer("SLOP: 1/10")  # case-insensitive
assert not has_slop_footer("no footer here")
assert not has_slop_footer("slop: tonight")  # marker but no N/10


def fails(case, output):
    return check_case(case, output)[0]


def advisories(case, output):
    return check_case(case, output)[1]


# --- must_include_any (hard) ---
assert fails({"must_include_any": ["Spirit", "Hegel"]}, "the march of Spirit") == []
assert fails({"must_include_any": ["Spirit"]}, "nothing here")  # fails

# --- must_include_all (hard) ---
assert fails({"must_include_all": ["a", "b"]}, "a and b") == []
assert fails({"must_include_all": ["a", "b"]}, "only a")  # fails

# --- must_not_include (hard, case-insensitive) ---
assert fails({"must_not_include": ["forbidden"]}, "clean") == []
assert fails({"must_not_include": ["forbidden"]}, "FORBIDDEN word")  # fails

# --- empty output is a hard failure ---
assert any("empty" in f for f in fails({}, "   "))

# --- slop footer is advisory, never a failure ---
assert fails({}, "answer with no footer") == []                       # no footer -> still passes
assert any("slop footer" in a for a in advisories({}, "no footer"))   # but is reported
assert advisories({}, "answer\n---\nslop: 2/10 (0 revisions)") == []  # footer present -> silent

print("test_run_skill_evals: OK")
