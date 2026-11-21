#!/usr/bin/env python3
import copy
import json
import pathlib
import shlex
import struct
import subprocess
import sys
import tempfile


ROOT = pathlib.Path(__file__).resolve().parent.parent
CHECKER = ROOT / "scripts" / "verify_transcript.lean"
ENTRY = 0x1000
PROGRAM_HEADER_OFFSET = 52
PROGRAM_HEADER_SIZE = 32
PROGRAM_HEADER_COUNT = 2
DATA_HEADER_OFFSET = PROGRAM_HEADER_OFFSET + PROGRAM_HEADER_SIZE
SEGMENT_OFFSET = PROGRAM_HEADER_OFFSET + PROGRAM_HEADER_SIZE * PROGRAM_HEADER_COUNT
DATA_ADDRESS = 0x2000
PROGRAM_WORDS = (0x00700093, 0x00100073)  # addi x1, x0, 7; ebreak


def valid_elf(entry=ENTRY, words=PROGRAM_WORDS):
    code_size = 4 * len(words)
    data_offset = SEGMENT_OFFSET + code_size
    data = bytearray(data_offset + 4)
    data[:7] = bytes((0x7F, ord("E"), ord("L"), ord("F"), 1, 1, 1))
    struct.pack_into(
        "<HHIIIIIHHHHHH",
        data,
        16,
        2,  # ET_EXEC
        243,  # EM_RISCV
        1,
        entry,
        PROGRAM_HEADER_OFFSET,
        0,
        0,
        52,
        32,
        PROGRAM_HEADER_COUNT,
        0,
        0,
        0,
    )
    struct.pack_into(
        "<IIIIIIII",
        data,
        PROGRAM_HEADER_OFFSET,
        1,  # PT_LOAD
        SEGMENT_OFFSET,
        ENTRY,
        ENTRY,
        code_size,
        code_size,
        5,  # PF_R | PF_X
        4,
    )
    struct.pack_into(
        "<IIIIIIII",
        data,
        DATA_HEADER_OFFSET,
        1,  # PT_LOAD
        data_offset,
        DATA_ADDRESS,
        DATA_ADDRESS,
        4,
        8,  # Four bytes of BSS
        6,  # PF_R | PF_W
        4,
    )
    for index, word in enumerate(words):
        struct.pack_into("<I", data, SEGMENT_OFFSET + index * 4, word)
    data[data_offset : data_offset + 4] = bytes((0xAA, 0xBB, 0xCC, 0xDD))
    return data


def run(command, *, expect_success, label):
    result = subprocess.run(
        command, cwd=ROOT, capture_output=True, text=True, check=False
    )
    succeeded = result.returncode == 0
    if succeeded != expect_success:
        raise AssertionError(
            f"{label}: expected {'acceptance' if expect_success else 'rejection'}\n"
            f"command: {shlex.join(command)}\n"
            f"stdout:\n{result.stdout}\nstderr:\n{result.stderr}"
        )
    return result


def main():
    if len(sys.argv) != 3:
        raise SystemExit(
            "usage: check_transcript_adversarial.py <host-runner> <lake-command>"
        )

    runner = str(pathlib.Path(sys.argv[1]).resolve())
    lake_command = shlex.split(sys.argv[2])
    if not lake_command:
        raise SystemExit("Lake command must not be empty")

    with tempfile.TemporaryDirectory(prefix="zkrv32i-transcript-") as directory:
        temp = pathlib.Path(directory)
        elf = valid_elf()
        elf_path = temp / "valid.elf"
        transcript_path = temp / "valid.json"
        elf_path.write_bytes(elf)

        run(
            [
                runner,
                "--emit-transcript",
                str(elf_path),
                str(transcript_path),
                "8",
            ],
            expect_success=True,
            label="Rust transcript emission",
        )
        original = json.loads(transcript_path.read_text(encoding="utf-8"))
        memory = bytes.fromhex(original["initial_state"]["memory_hex"])
        data_memory_offset = DATA_ADDRESS - original["initial_state"]["memory_base"]
        if memory[data_memory_offset : data_memory_offset + 8] != bytes(
            (0xAA, 0xBB, 0xCC, 0xDD, 0, 0, 0, 0)
        ):
            raise AssertionError("runner did not load data segment and zero-fill its BSS")
        cases = [
            {
                "name": "valid transcript",
                "elf_path": str(elf_path),
                "transcript_path": str(transcript_path),
                "expect_accept": True,
            }
        ]

        fuel_elf = valid_elf(words=(0x00700093, 0x00800113, 0x00100073))
        fuel_elf_path = temp / "fuel-limit.elf"
        fuel_transcript_path = temp / "fuel-limit.json"
        fuel_elf_path.write_bytes(fuel_elf)
        run(
            [
                runner,
                "--emit-transcript",
                str(fuel_elf_path),
                str(fuel_transcript_path),
                "1",
            ],
            expect_success=True,
            label="Rust fuel-limit transcript emission",
        )
        fuel_transcript = json.loads(
            fuel_transcript_path.read_text(encoding="utf-8")
        )
        if fuel_transcript["stop"] != {
            "kind": "fuel_limit",
            "steps": 1,
            "limit": 1,
        }:
            raise AssertionError("runner did not report the exhausted fuel limit")
        cases.append(
            {
                "name": "valid fuel-limit transcript",
                "elf_path": str(fuel_elf_path),
                "transcript_path": str(fuel_transcript_path),
                "expect_accept": True,
            }
        )
        wrong_limit_transcript = copy.deepcopy(fuel_transcript)
        wrong_limit_transcript["stop"]["limit"] = 2
        wrong_limit_path = temp / "fuel-limit-mismatch.json"
        wrong_limit_path.write_text(
            json.dumps(wrong_limit_transcript), encoding="utf-8"
        )
        cases.append(
            {
                "name": "Lean checker: fuel limit mismatch",
                "elf_path": str(fuel_elf_path),
                "transcript_path": str(wrong_limit_path),
                "expect_accept": False,
            }
        )
        missing_limit_transcript = copy.deepcopy(fuel_transcript)
        del missing_limit_transcript["stop"]["limit"]
        missing_limit_path = temp / "fuel-limit-missing.json"
        missing_limit_path.write_text(
            json.dumps(missing_limit_transcript), encoding="utf-8"
        )
        cases.append(
            {
                "name": "Lean checker: missing fuel limit",
                "elf_path": str(fuel_elf_path),
                "transcript_path": str(missing_limit_path),
                "expect_accept": False,
            }
        )

        fault_fixtures = [
            ("fetch", valid_elf(words=(0x0001006F,)), 2),
            ("decode", valid_elf(words=(0xFFFFFFFF,)), 1),
            ("step", valid_elf(words=(0xFFC02083,)), 1),
        ]
        fault_transcripts = {}
        for stage, fault_elf, fuel in fault_fixtures:
            fault_elf_path = temp / f"{stage}-fault.elf"
            fault_transcript_path = temp / f"{stage}-fault.json"
            fault_elf_path.write_bytes(fault_elf)
            run(
                [
                    runner,
                    "--emit-transcript",
                    str(fault_elf_path),
                    str(fault_transcript_path),
                    str(fuel),
                ],
                expect_success=True,
                label=f"Rust {stage}-fault transcript emission",
            )
            fault_transcript = json.loads(
                fault_transcript_path.read_text(encoding="utf-8")
            )
            if fault_transcript["stop"].get("stage") != stage:
                raise AssertionError(
                    f"runner did not report the expected {stage} fault"
                )
            fault_transcripts[stage] = (fault_elf_path, fault_transcript)
            cases.append(
                {
                    "name": f"valid {stage}-fault transcript",
                    "elf_path": str(fault_elf_path),
                    "transcript_path": str(fault_transcript_path),
                    "expect_accept": True,
                }
            )

        fault_mutations = [
            (
                "fetch-fault error mismatch",
                "fetch",
                lambda stop: stop.__setitem__("error", "illegal_instruction"),
            ),
            (
                "decode-fault word mismatch",
                "decode",
                lambda stop: stop.__setitem__("word", stop["word"] ^ 1),
            ),
            (
                "step-fault decoded operand mismatch",
                "step",
                lambda stop: stop["decoded"]["operands"].__setitem__(
                    2, stop["decoded"]["operands"][2] + 1
                ),
            ),
        ]
        for index, (label, stage, mutate) in enumerate(fault_mutations):
            fault_elf_path, fault_transcript = fault_transcripts[stage]
            mutated = copy.deepcopy(fault_transcript)
            mutate(mutated["stop"])
            mutated_path = temp / f"mutated-fault-{index}.json"
            mutated_path.write_text(json.dumps(mutated), encoding="utf-8")
            cases.append(
                {
                    "name": f"Lean checker: {label}",
                    "elf_path": str(fault_elf_path),
                    "transcript_path": str(mutated_path),
                    "expect_accept": False,
                }
            )

        offset_entry_elf = valid_elf(ENTRY + 4)
        offset_entry_elf_path = temp / "entry-offset.elf"
        offset_entry_transcript_path = temp / "entry-offset.json"
        offset_entry_elf_path.write_bytes(offset_entry_elf)
        run(
            [
                runner,
                "--emit-transcript",
                str(offset_entry_elf_path),
                str(offset_entry_transcript_path),
                "8",
            ],
            expect_success=True,
            label="Rust transcript emission with entry inside executable segment",
        )
        cases.append(
            {
                "name": "entry inside executable segment",
                "elf_path": str(offset_entry_elf_path),
                "transcript_path": str(offset_entry_transcript_path),
                "expect_accept": True,
            }
        )

        elf_mutations = [
            ("bad ELF magic", lambda data: data.__setitem__(0, 0)),
            ("wrong machine", lambda data: struct.pack_into("<H", data, 18, 3)),
            (
                "non-PT_LOAD segment",
                lambda data: struct.pack_into(
                    "<I", data, PROGRAM_HEADER_OFFSET, 2
                ),
            ),
            (
                "non-executable segment",
                lambda data: struct.pack_into(
                    "<I", data, PROGRAM_HEADER_OFFSET + 24, 4
                ),
            ),
            ("misaligned entry", lambda data: struct.pack_into("<I", data, 24, ENTRY + 1)),
            (
                "entry outside executable segment",
                lambda data: struct.pack_into("<I", data, 24, ENTRY + 8),
            ),
            (
                "segment file range out of bounds",
                lambda data: struct.pack_into(
                    "<I", data, PROGRAM_HEADER_OFFSET + 4, len(data) + 1
                ),
            ),
            (
                "overlapping load segments",
                lambda data: struct.pack_into(
                    "<I", data, DATA_HEADER_OFFSET + 8, ENTRY + 4
                ),
            ),
            (
                "load segment outside bounded memory window",
                lambda data: struct.pack_into(
                    "<I", data, DATA_HEADER_OFFSET + 8, ENTRY + (1 << 16)
                ),
            ),
        ]

        for index, (label, mutate) in enumerate(elf_mutations):
            mutated_elf = bytearray(elf)
            mutate(mutated_elf)
            mutated_elf_path = temp / f"mutated-{index}.elf"
            mutated_transcript_path = temp / f"mutated-{index}.json"
            mutated_elf_path.write_bytes(mutated_elf)

            run(
                [
                    runner,
                    "--emit-transcript",
                    str(mutated_elf_path),
                    str(temp / f"mutated-{index}-runner.json"),
                    "8",
                ],
                expect_success=False,
                label=f"Rust runner: {label}",
            )

            transcript = copy.deepcopy(original)
            transcript["elf_bytes"] = mutated_elf.hex()
            mutated_transcript_path.write_text(
                json.dumps(transcript), encoding="utf-8"
            )
            cases.append(
                {
                    "name": f"Lean checker: {label}",
                    "elf_path": str(mutated_elf_path),
                    "transcript_path": str(mutated_transcript_path),
                    "expect_accept": False,
                }
            )

        transcript_mutations = [
            (
                "step PC",
                lambda value: value["steps"][0].__setitem__(
                    "pc", value["steps"][0]["pc"] + 4
                ),
            ),
            (
                "instruction word",
                lambda value: value["steps"][0].__setitem__(
                    "word", value["steps"][0]["word"] ^ 1
                ),
            ),
            (
                "decoded operand",
                lambda value: value["steps"][0]["decoded"]["operands"].__setitem__(
                    2, value["steps"][0]["decoded"]["operands"][2] + 1
                ),
            ),
            (
                "state snapshot",
                lambda value: value["steps"][0]["state"]["registers"].__setitem__(
                    1, value["steps"][0]["state"]["registers"][1] ^ 1
                ),
            ),
            (
                "stop reason",
                lambda value: value.__setitem__(
                    "stop",
                    {
                        "kind": "fuel_limit",
                        "steps": len(value["steps"]),
                        "limit": len(value["steps"]),
                    },
                ),
            ),
        ]

        for index, (label, mutate) in enumerate(transcript_mutations):
            transcript = copy.deepcopy(original)
            mutate(transcript)
            mutated_transcript_path = temp / f"mutated-transcript-{index}.json"
            mutated_transcript_path.write_text(
                json.dumps(transcript), encoding="utf-8"
            )
            cases.append(
                {
                    "name": f"Lean checker: mutated {label}",
                    "elf_path": str(elf_path),
                    "transcript_path": str(mutated_transcript_path),
                    "expect_accept": False,
                }
            )

        manifest_path = temp / "batch.json"
        manifest_path.write_text(json.dumps({"cases": cases}), encoding="utf-8")
        run(
            lake_command
            + ["env", "lean", "--run", str(CHECKER), "batch", str(manifest_path)],
            expect_success=True,
            label="Lean transcript mutation batch",
        )

    print(
        f"transcript adversarial checks passed: {len(elf_mutations)} ELF mutations, "
        f"{len(transcript_mutations) + len(fault_mutations)} transcript mutations, "
        f"{len(fault_fixtures)} valid fault stops"
    )


if __name__ == "__main__":
    main()
