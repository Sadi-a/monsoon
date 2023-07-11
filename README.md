# Monsoon

Monsoon is a baremetal-focused fork of [Typhoon][typhoon].

Its aim is to implement several features unavailable in [Typhoon][typhoon] such 
as supporting several CPU architectures, as in x86_64 and aarch64, or supporting
ephemeral nodes.

[Typhoon]: https://typhoon.psdn.io/

## Test suite

Monsoon implements a test suite available on the 'test-suite' branch. It runs
terraform apply and validates that Monsoon finishes its installation and
deployment as it should.
Using the test suite on any branch or fork, the source in `monsoon.tf` can be
set to
```git::https://github.com/<user>/<fork-name>//flatcar-linux/kubernetes?ref=<branch-name>```

