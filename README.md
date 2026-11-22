# baldssl-fixtures

Test fixtures for [baldssl](https://github.com/BaDaaS/baldssl): certificates,
keys, and the outputs real OpenSSL binaries print for them. baldssl's tests
compare its output with these byte for byte.

baldssl does not clone this repository. Each release attaches one archive,
`baldssl-fixtures-<tag>.tar.gz`, built from the tagged tree, with its SHA-256
in `baldssl-fixtures-<tag>.tar.gz.sha256`. baldssl pins a tag and the archive's
SHA-256, and `make fixtures` downloads the archive, checks the hash, and
unpacks it into `tests/fixtures`.

## Layout

| Path                 | Contents                                                                                         |
| -------------------- | ------------------------------------------------------------------------------------------------ |
| `cases.txt`          | the `x509` argument sets every certificate is run with                                           |
| `cavp/drbg/`         | NIST CAVP HMAC_DRBG vectors (`HMAC_DRBG.rsp` of each mode of `drbgtestvectors.zip`), unchanged   |
| `certs/`             | the certificates, PEM                                                                            |
| `golden/<p>/`        | OpenSSL's output for each certificate and case, per profile: `v30` (3.0), `v3` (3.5), `v4` (4.1) |
| `golden/<p>/VERSION` | the OpenSSL binary that produced that profile                                                    |
| `keys/`              | key pairs OpenSSL generated, for the curve arithmetic                                            |

Every file is compared byte for byte, so `.gitattributes` turns off line-ending
conversion.

## Where the files come from

- `cavp/drbg/HMAC_DRBG_<mode>.rsp`: the `HMAC_DRBG.rsp` of `drbgvectors_no_reseed.zip`, `drbgvectors_pr_false.zip` and `drbgvectors_pr_true.zip`, inside NIST's [`drbgtestvectors.zip`](https://csrc.nist.gov/projects/cryptographic-algorithm-validation-program/random-number-generators), unchanged.

baldssl's scripts write them, from real OpenSSL binaries, into baldssl's
`tests/fixtures`:

- `scripts/gen-golden.sh --certs <openssl>` writes `certs/` (with
  `scripts/gen-version-certs.py` for the `p256-version-*` certificates), and
  `scripts/gen-golden.sh <openssl-3.0> <openssl-3.5> <openssl-4.1>` writes
  `golden/`;
- `scripts/gen-ec-vectors.sh` writes `keys/keypairs.txt`.

## Releasing a new set

1. In baldssl, regenerate the fixtures into `tests/fixtures`.
2. Copy them here (`rsync -a --delete <baldssl>/tests/fixtures/ ./` keeps this
   README, the `Makefile`, the licence and the workflow, which are not in
   `tests/fixtures`; check `git status` before committing).
3. Commit, then push a tag `vN`. The `release` workflow builds the archive
   (`make archive`) and publishes the release with the archive and its SHA-256.
4. In baldssl, set the new tag and SHA-256 in `tests/fixtures.version`.

`make archive` is deterministic with GNU tar: entries sorted by name, owner and
group 0, modification time 0, and gzip without a name or time stamp. The same
tree gives the same bytes.

## Licence

MIT, as baldssl.
