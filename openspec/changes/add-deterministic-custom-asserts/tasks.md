## 1. Custom-assert plumbing

- [ ] 1.1 Add a `javascript`/`python` assert that parses the `slop: N/10` footer into a numeric metric.
- [ ] 1.2 Add a deterministic structural assert for the dialectical move (negation/sublation present, scaffolding absent) where expressible without a judge.

## 2. Wire + verify

- [ ] 2.1 Reference the custom asserts from the EN/PL configs (or defaultTest) without disturbing existing keyword asserts.
- [ ] 2.2 `./run-tests.sh` green locally; `openspec validate add-deterministic-custom-asserts --strict` clean.
