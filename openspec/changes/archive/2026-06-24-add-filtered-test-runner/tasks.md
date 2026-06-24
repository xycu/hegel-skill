# Tasks: Filter the local test runner to a single behaviour

- [x] Parse a `-k <pattern>` / `--filter <pattern>` flag (and `-h`/`--help`) in `run-tests.sh` without breaking the existing positional model argument or `MODEL=` env override

- [x] Thread the filter into both eval stages as promptfoo `--filter-pattern <pattern>`; with no filter, the command is unchanged

- [x] Update the usage header in `run-tests.sh` to document `-k`/`--filter` with an example

- [x] `openspec validate add-filtered-test-runner --strict` clean

- [x] Verify locally: `./run-tests.sh -k persona-persistence` runs only the EN+PL persona-persistence cases (other behaviours skipped), and a no-arg run still covers everything; an EN-only pattern leaves the PL stage green at zero cases
