#![no_std]
#![no_main]
#![forbid(unsafe_code)]

use core::panic::PanicInfo;

#[inline(never)]
pub extern "C" fn firmware_start() -> ! {
    loop {
        core::hint::spin_loop();
    }
}

#[used]
static KEEP_CORE_DECODER: fn(u32) -> Result<zkrv32i::Instruction, zkrv32i::DecodeError> =
    zkrv32i::decode;

#[panic_handler]
fn panic(_info: &PanicInfo<'_>) -> ! {
    loop {
        core::hint::spin_loop();
    }
}
