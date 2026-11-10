#!/usr/bin/env python3
"""Strip Helm bookkeeping labels from `helm template` output.

Run over each generated manifest after regenerating it.

Operates line-wise rather than round-tripping YAML: istiod's sidecar-injector
config embeds Go templates that reference `app.kubernetes.io/name` as a value
lookup on the injected workload, and those must survive byte-identical. A line
whose key is followed by `{{` is such a lookup, not object metadata.
"""
import re
import sys

KEYS = (
    "helm.sh/chart",
    "app.kubernetes.io/managed-by",
    "app.kubernetes.io/instance",
    "app.kubernetes.io/part-of",
    "app.kubernetes.io/version",
    "app.kubernetes.io/name",
)

PAT = re.compile(r"^\s*(" + "|".join(re.escape(k) for k in KEYS) + r"):\s")


def strip(path):
    kept, removed = [], 0
    with open(path) as fh:
        for line in fh:
            if PAT.match(line) and "{{" not in line:
                removed += 1
                continue
            kept.append(line)
    with open(path, "w") as fh:
        fh.writelines(kept)
    return removed


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("usage: strip-helm-labels.py <manifest.yaml>...")
    for path in sys.argv[1:]:
        print(f"stripped {strip(path)} label lines from {path}")
