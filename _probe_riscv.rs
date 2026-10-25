#![no_std]
#![no_main]
#![forbid(unsafe_code)]

use core::panic::PanicInfo;

#[export_name = "_start"]
pub extern "C" fn start() -> ! { loop {} }

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! { loop {} }