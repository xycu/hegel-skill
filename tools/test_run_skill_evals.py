"""Assertion-logic checks for run_skill_evals (no Ollama needed).

Run: python tools/test_run_skill_evals.py
"""
from run_skill_evals import check_case, has_slop_footer

# --- slop footer detection ---
assert has_slop_footer("text\n\n---\nslop: 3/10 (1 revision)")
assert has_slop_footer("SLOP: 1/10")  # case-insensitive
assert not has_slop_footer("no footer here")
assert not has_slop_footer("slop: tonight")  # marker but no N/10

# --- must_include_any ---
assert check_case({"must_include_any": ["Spirit", "Hegel"], "require_slop_footer": False},
                  "the march of Spirit") == []
assert check_case({"must_include_any": ["Spirit"], "require_slop_footer": False},
                  "nothing here")  # fails

# --- must_include_all ---
assert check_case({"must_include_all": ["a", "b"], "require_slop_footer": False}, "a and b") == []
assert check_case({"must_include_all": ["a", "b"], "require_slop_footer": False}, "only a")  # fails

# --- must_not_include ---
assert check_case({"must_not_include": ["forbidden"], "require_slop_footer": False}, "clean") == []
assert check_case({"must_not_include": ["forbidden"], "require_slop_footer": False}, "FORBIDDEN word")  # fails, case-insensitive

# --- slop footer required by default ---
assert check_case({}, "no footer")  # default require_slop_footer=True -> fails
assert check_case({}, "answer\n---\nslop: 2/10 (0 revisions)") == []

print("test_run_skill_evals: OK")
