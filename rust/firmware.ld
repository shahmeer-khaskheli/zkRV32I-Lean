OUTPUT_ARCH(riscv)
ENTRY(_start)

SECTIONS
{
    . = 0x80000000;
    .text : ALIGN(4) {
        _start = .;
        KEEP(*(.text._ZN8firmware14firmware_start*))
        *(.text .text.*)
    }
    .rodata : ALIGN(4) {
        *(.rodata .rodata.*)
    }
    .data : ALIGN(4) {
        *(.data .data.*)
    }
    .bss : ALIGN(4) {
        *(.bss .bss.*)
        *(COMMON)
    }
    /DISCARD/ : {
        *(.eh_frame .eh_frame.*)
    }
}
