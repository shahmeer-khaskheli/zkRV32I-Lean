# Binary Trace Scope

## Checked trace chain

The transcript checker verifies:

1. ELF bytes and parsed load plan;
2. the initial machine memory and registers;
3. every row PC;
4. every raw instruction word;
5. every decoded operand record;
6. `Machine.step`;
7. every output snapshot;
8. halt, fuel-limit, or fault stop evidence.

## Limits

The checked chain is bounded and model-specific. It does not prove a general
RV32I execution, compiled machine code, external ELF loader, hardware
processor, or cryptographic proof system.
