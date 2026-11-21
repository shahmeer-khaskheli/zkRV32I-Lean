#!/usr/bin/env python3
"""Expand the theorem-ledger template with maintained source declarations."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
TEMPLATE = ROOT / "scripts" / "generate_proof_ledger.lean"
DECLARATION = re.compile(
    r"^\s*(?:(?:private|protected|unsafe|noncomputable)\s+)*"
    r"(?:theorem|lemma)\s+([^\s({:]+)"
)
NAMESPACE = re.compile(r"^\s*namespace\s+([A-Za-z_][A-Za-z0-9_'.]*)\s*(?:--.*)?$")
END = re.compile(r"^\s*end(?:\s+([A-Za-z_][A-Za-z0-9_'.]*))?\s*(?:--.*)?$")


def source_declarations() -> list[tuple[str, str]]:
    declarations: list[tuple[str, str]] = []
    for path in sorted((ROOT / "formal").rglob("*.lean")):
        relative = path.relative_to(ROOT).as_posix()
        namespaces: list[str] = []
        for line_number, line in enumerate(
            path.read_text(encoding="utf-8").splitlines(), start=1
        ):
            namespace_match = NAMESPACE.match(line)
            if namespace_match:
                declared_namespace = namespace_match.group(1)
                parent = namespaces[-1] if namespaces else ""
                namespaces.append(
                    declared_namespace
                    if "." in declared_namespace
                    or not parent
                    else f"{parent}.{declared_namespace}"
                )
                continue

            end_match = END.match(line)
            if end_match:
                ended_namespace = end_match.group(1)
                if ended_namespace:
                    while namespaces:
                        current = namespaces.pop()
                        if current == ended_namespace or current.endswith(
                            "." + ended_namespace
                        ):
                            break
                elif namespaces:
                    namespaces.pop()
                continue

            declaration_match = DECLARATION.match(line)
            if declaration_match:
                declared_name = declaration_match.group(1).strip("`")
                current_namespace = namespaces[-1] if namespaces else ""
                if declared_name.startswith("_root_."):
                    qualified_name = declared_name.removeprefix("_root_.")
                elif not current_namespace or declared_name.startswith(
                    current_namespace + "."
                ):
                    qualified_name = declared_name
                else:
                    qualified_name = f"{current_namespace}.{declared_name}"
                declarations.append(
                    (qualified_name, f"{relative}:{line_number}")
                )
    return declarations


def main() -> int:
    declarations = source_declarations()
    names = [name for name, _ in declarations]
    duplicates = sorted({name for name in names if names.count(name) > 1})
    if duplicates:
        print(
            "duplicate theorem/lemma names in source scan: "
            + ", ".join(duplicates),
            file=sys.stderr,
        )
        return 1

    template = TEMPLATE.read_text(encoding="utf-8")
    encoded_declarations = "#[\n" + ",\n".join(
        f"  {json.dumps(name + '|' + location)}"
        for name, location in declarations
    ) + "\n]"
    template = template.replace(
        "SOURCE_COUNT_PLACEHOLDER", str(len(declarations))
    ).replace("SOURCE_DECLS_PLACEHOLDER", encoded_declarations)
    if "SOURCE_COUNT_PLACEHOLDER" in template or "SOURCE_DECLS_PLACEHOLDER" in template:
        print("unexpanded source-scan placeholder", file=sys.stderr)
        return 1
    sys.stdout.write(template)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
