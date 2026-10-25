// Lean compiler output
// Module: ZkRV32I.Binary
// Imports: Init ZkRV32I.Trace
#include <lean/lean.h>
#if defined(__clang__)
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wunused-label"
#elif defined(__GNUC__) && !defined(__CLANG__)
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wunused-label"
#pragma GCC diagnostic ignored "-Wunused-but-set-variable"
#endif
#ifdef __cplusplus
extern "C" {
#endif
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_loadELF32Segments(lean_object*, lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__13;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__29;
uint8_t l_ZkRV32I_Memory_validRange(lean_object*, lean_object*, lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__17;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__30;
lean_object* lean_uint32_to_nat(uint32_t);
lean_object* l_ZkRV32I_decode(uint32_t);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__5;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__27;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__18;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_parseELF32Header(lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__9;
LEAN_EXPORT uint8_t l_ZkRV32I_Binary_instDecidableEqELF32Header(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_ELF32ProgramHeader_isLoadableExecutable___boxed(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_loadSegment___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__9;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__21;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__15;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_decodeBitVec32(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_binaryStep(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_readU32LE___boxed(lean_object*, lean_object*);
static lean_object* l_ZkRV32I_Binary_readELF32ProgramHeaders___closed__2;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_fetch32___boxed(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__14;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_readU32LE(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_decEqELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_825____boxed(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__8;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__11;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__12;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_fetchDecode(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_readU16LE(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_loadSegment___lambda__1(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__1;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_instDecidableEqELF32Header___boxed(lean_object*, lean_object*);
static lean_object* l_ZkRV32I_Binary_parseELF32Header___closed__2;
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__Except_toBool_match__1_splitter___rarg(lean_object*, lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__25;
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_decEqELF32Header____x40_ZkRV32I_Binary___hyg_242____boxed(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__17;
LEAN_EXPORT uint8_t l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__28;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_instReprELF32Header;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__10;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__2;
LEAN_EXPORT uint8_t l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_decEqELF32Header____x40_ZkRV32I_Binary___hyg_242_(lean_object*, lean_object*);
static lean_object* l_ZkRV32I_Binary_parseELF32Header___closed__5;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__19;
lean_object* lean_nat_to_int(lean_object*);
uint32_t lean_uint32_of_nat(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_loadSegment___lambda__1___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__7;
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____boxed(lean_object*, lean_object*);
lean_object* l_BitVec_ofNat(lean_object*, lean_object*);
static lean_object* l_ZkRV32I_Binary_parseELF32Header___closed__3;
lean_object* lean_array_to_list(lean_object*);
static lean_object* l_ZkRV32I_Binary_readELF32ProgramHeaders___closed__1;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__7;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_readELF32ProgramHeaders(lean_object*, lean_object*, lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__15;
lean_object* lean_nat_land(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__24;
uint16_t lean_uint16_of_nat(lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__16;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__1;
static lean_object* l_ZkRV32I_Binary_parseELF32Header___closed__1;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_parseELF32(lean_object*);
lean_object* l_Array_append___rarg(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__4;
static lean_object* l_ZkRV32I_Binary_parseELF32Header___closed__4;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_decodeBitVec32___boxed(lean_object*);
static lean_object* l_ZkRV32I_Binary_instReprELF32ProgramHeader___closed__1;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__5;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__3;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_loadSegment(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_fetchDecode___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_parseELF32Header___boxed(lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__3;
lean_object* lean_array_fget(lean_object*, lean_object*);
LEAN_EXPORT uint8_t l_ZkRV32I_Binary_ELF32ProgramHeader_isLoadableExecutable(lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__19;
lean_object* lean_string_length(lean_object*);
LEAN_EXPORT uint8_t l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_decEqELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_825_(lean_object*, lean_object*);
uint8_t lean_nat_dec_eq(lean_object*, lean_object*);
uint8_t lean_nat_dec_lt(lean_object*, lean_object*);
lean_object* lean_nat_mod(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__2;
uint8_t lean_uint32_dec_eq(uint32_t, uint32_t);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_readELF32ProgramHeaders___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__23;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__16;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__11;
lean_object* lean_uint16_to_nat(uint16_t);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__10;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_instDecidableEqELF32ProgramHeader___boxed(lean_object*, lean_object*);
lean_object* lean_nat_sub(lean_object*, lean_object*);
lean_object* lean_nat_mul(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__8;
LEAN_EXPORT lean_object* l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1___boxed(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__13;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_readU16LE___boxed(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__6;
lean_object* lean_array_mk(lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__12;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_parseELF32ProgramHeader___boxed(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__22;
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275_(lean_object*, lean_object*);
lean_object* lean_uint8_to_nat(uint8_t);
LEAN_EXPORT uint8_t l_ZkRV32I_Binary_segmentFits(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_instReprELF32ProgramHeader;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__26;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__18;
lean_object* l_ZkRV32I_step(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_parseELF32ProgramHeader(lean_object*, lean_object*);
lean_object* lean_array_get_size(lean_object*);
static lean_object* l_ZkRV32I_Binary_instReprELF32Header___closed__1;
uint8_t lean_nat_dec_le(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__6;
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__20;
lean_object* lean_nat_add(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__14;
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_ELF32Image_loadMemory(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_segmentFits___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_fetch32(lean_object*, lean_object*);
uint8_t lean_uint8_dec_eq(uint8_t, uint8_t);
lean_object* l___private_Init_Data_Repr_0__Nat_reprFast(lean_object*);
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____boxed(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__20;
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__Except_toBool_match__1_splitter(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t l_ZkRV32I_Binary_instDecidableEqELF32ProgramHeader(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__4;
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627_(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_readU32LE(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; uint8_t x_4; 
x_3 = lean_array_get_size(x_1);
x_4 = lean_nat_dec_lt(x_2, x_3);
if (x_4 == 0)
{
lean_object* x_5; 
lean_dec(x_3);
x_5 = lean_box(0);
return x_5;
}
else
{
lean_object* x_6; uint8_t x_7; lean_object* x_8; lean_object* x_9; uint8_t x_10; 
x_6 = lean_array_fget(x_1, x_2);
x_7 = lean_unbox(x_6);
lean_dec(x_6);
x_8 = lean_unsigned_to_nat(1u);
x_9 = lean_nat_add(x_2, x_8);
x_10 = lean_nat_dec_lt(x_9, x_3);
if (x_10 == 0)
{
lean_object* x_11; 
lean_dec(x_9);
lean_dec(x_3);
x_11 = lean_box(0);
return x_11;
}
else
{
lean_object* x_12; uint8_t x_13; lean_object* x_14; lean_object* x_15; uint8_t x_16; 
x_12 = lean_array_fget(x_1, x_9);
lean_dec(x_9);
x_13 = lean_unbox(x_12);
lean_dec(x_12);
x_14 = lean_unsigned_to_nat(2u);
x_15 = lean_nat_add(x_2, x_14);
x_16 = lean_nat_dec_lt(x_15, x_3);
if (x_16 == 0)
{
lean_object* x_17; 
lean_dec(x_15);
lean_dec(x_3);
x_17 = lean_box(0);
return x_17;
}
else
{
lean_object* x_18; uint8_t x_19; lean_object* x_20; lean_object* x_21; uint8_t x_22; 
x_18 = lean_array_fget(x_1, x_15);
lean_dec(x_15);
x_19 = lean_unbox(x_18);
lean_dec(x_18);
x_20 = lean_unsigned_to_nat(3u);
x_21 = lean_nat_add(x_2, x_20);
x_22 = lean_nat_dec_lt(x_21, x_3);
lean_dec(x_3);
if (x_22 == 0)
{
lean_object* x_23; 
lean_dec(x_21);
x_23 = lean_box(0);
return x_23;
}
else
{
lean_object* x_24; uint8_t x_25; lean_object* x_26; lean_object* x_27; lean_object* x_28; lean_object* x_29; lean_object* x_30; lean_object* x_31; lean_object* x_32; lean_object* x_33; lean_object* x_34; lean_object* x_35; lean_object* x_36; lean_object* x_37; lean_object* x_38; uint32_t x_39; lean_object* x_40; lean_object* x_41; 
x_24 = lean_array_fget(x_1, x_21);
lean_dec(x_21);
x_25 = lean_unbox(x_24);
lean_dec(x_24);
x_26 = lean_uint8_to_nat(x_7);
x_27 = lean_uint8_to_nat(x_13);
x_28 = lean_unsigned_to_nat(256u);
x_29 = lean_nat_mul(x_27, x_28);
lean_dec(x_27);
x_30 = lean_nat_add(x_26, x_29);
lean_dec(x_29);
lean_dec(x_26);
x_31 = lean_uint8_to_nat(x_19);
x_32 = lean_unsigned_to_nat(65536u);
x_33 = lean_nat_mul(x_31, x_32);
lean_dec(x_31);
x_34 = lean_nat_add(x_30, x_33);
lean_dec(x_33);
lean_dec(x_30);
x_35 = lean_uint8_to_nat(x_25);
x_36 = lean_unsigned_to_nat(16777216u);
x_37 = lean_nat_mul(x_35, x_36);
lean_dec(x_35);
x_38 = lean_nat_add(x_34, x_37);
lean_dec(x_37);
lean_dec(x_34);
x_39 = lean_uint32_of_nat(x_38);
lean_dec(x_38);
x_40 = lean_box_uint32(x_39);
x_41 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_41, 0, x_40);
return x_41;
}
}
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_readU32LE___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = l_ZkRV32I_Binary_readU32LE(x_1, x_2);
lean_dec(x_2);
lean_dec(x_1);
return x_3;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_readU16LE(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; uint8_t x_4; 
x_3 = lean_array_get_size(x_1);
x_4 = lean_nat_dec_lt(x_2, x_3);
if (x_4 == 0)
{
lean_object* x_5; 
lean_dec(x_3);
x_5 = lean_box(0);
return x_5;
}
else
{
lean_object* x_6; uint8_t x_7; lean_object* x_8; lean_object* x_9; uint8_t x_10; 
x_6 = lean_array_fget(x_1, x_2);
x_7 = lean_unbox(x_6);
lean_dec(x_6);
x_8 = lean_unsigned_to_nat(1u);
x_9 = lean_nat_add(x_2, x_8);
x_10 = lean_nat_dec_lt(x_9, x_3);
lean_dec(x_3);
if (x_10 == 0)
{
lean_object* x_11; 
lean_dec(x_9);
x_11 = lean_box(0);
return x_11;
}
else
{
lean_object* x_12; uint8_t x_13; lean_object* x_14; lean_object* x_15; lean_object* x_16; lean_object* x_17; lean_object* x_18; uint16_t x_19; lean_object* x_20; lean_object* x_21; 
x_12 = lean_array_fget(x_1, x_9);
lean_dec(x_9);
x_13 = lean_unbox(x_12);
lean_dec(x_12);
x_14 = lean_uint8_to_nat(x_7);
x_15 = lean_uint8_to_nat(x_13);
x_16 = lean_unsigned_to_nat(256u);
x_17 = lean_nat_mul(x_15, x_16);
lean_dec(x_15);
x_18 = lean_nat_add(x_14, x_17);
lean_dec(x_17);
lean_dec(x_14);
x_19 = lean_uint16_of_nat(x_18);
lean_dec(x_18);
x_20 = lean_box(x_19);
x_21 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_21, 0, x_20);
return x_21;
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_readU16LE___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = l_ZkRV32I_Binary_readU16LE(x_1, x_2);
lean_dec(x_2);
lean_dec(x_1);
return x_3;
}
}
LEAN_EXPORT uint8_t l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_decEqELF32Header____x40_ZkRV32I_Binary___hyg_242_(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; uint32_t x_4; lean_object* x_5; lean_object* x_6; lean_object* x_7; lean_object* x_8; lean_object* x_9; uint32_t x_10; lean_object* x_11; lean_object* x_12; lean_object* x_13; lean_object* x_14; uint8_t x_15; 
x_3 = lean_ctor_get(x_1, 0);
x_4 = lean_ctor_get_uint32(x_1, sizeof(void*)*5);
x_5 = lean_ctor_get(x_1, 1);
x_6 = lean_ctor_get(x_1, 2);
x_7 = lean_ctor_get(x_1, 3);
x_8 = lean_ctor_get(x_1, 4);
x_9 = lean_ctor_get(x_2, 0);
x_10 = lean_ctor_get_uint32(x_2, sizeof(void*)*5);
x_11 = lean_ctor_get(x_2, 1);
x_12 = lean_ctor_get(x_2, 2);
x_13 = lean_ctor_get(x_2, 3);
x_14 = lean_ctor_get(x_2, 4);
x_15 = lean_nat_dec_eq(x_3, x_9);
if (x_15 == 0)
{
uint8_t x_16; 
x_16 = 0;
return x_16;
}
else
{
uint8_t x_17; 
x_17 = lean_uint32_dec_eq(x_4, x_10);
if (x_17 == 0)
{
uint8_t x_18; 
x_18 = 0;
return x_18;
}
else
{
uint8_t x_19; 
x_19 = lean_nat_dec_eq(x_5, x_11);
if (x_19 == 0)
{
uint8_t x_20; 
x_20 = 0;
return x_20;
}
else
{
uint8_t x_21; 
x_21 = lean_nat_dec_eq(x_6, x_12);
if (x_21 == 0)
{
uint8_t x_22; 
x_22 = 0;
return x_22;
}
else
{
uint8_t x_23; 
x_23 = lean_nat_dec_eq(x_7, x_13);
if (x_23 == 0)
{
uint8_t x_24; 
x_24 = 0;
return x_24;
}
else
{
uint8_t x_25; 
x_25 = lean_nat_dec_eq(x_8, x_14);
return x_25;
}
}
}
}
}
}
}
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_decEqELF32Header____x40_ZkRV32I_Binary___hyg_242____boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint8_t x_3; lean_object* x_4; 
x_3 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_decEqELF32Header____x40_ZkRV32I_Binary___hyg_242_(x_1, x_2);
lean_dec(x_2);
lean_dec(x_1);
x_4 = lean_box(x_3);
return x_4;
}
}
LEAN_EXPORT uint8_t l_ZkRV32I_Binary_instDecidableEqELF32Header(lean_object* x_1, lean_object* x_2) {
_start:
{
uint8_t x_3; 
x_3 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_decEqELF32Header____x40_ZkRV32I_Binary___hyg_242_(x_1, x_2);
return x_3;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_instDecidableEqELF32Header___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint8_t x_3; lean_object* x_4; 
x_3 = l_ZkRV32I_Binary_instDecidableEqELF32Header(x_1, x_2);
lean_dec(x_2);
lean_dec(x_1);
x_4 = lean_box(x_3);
return x_4;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__1() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("objectType", 10, 10);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__2() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__1;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__3() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = lean_box(0);
x_2 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__2;
x_3 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_3, 0, x_1);
lean_ctor_set(x_3, 1, x_2);
return x_3;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__4() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked(" := ", 4, 4);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__5() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__4;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__6() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__3;
x_2 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__5;
x_3 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_3, 0, x_1);
lean_ctor_set(x_3, 1, x_2);
return x_3;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__7() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_unsigned_to_nat(14u);
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__8() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked(",", 1, 1);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__9() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__8;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__10() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("entry", 5, 5);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__11() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__10;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__12() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_unsigned_to_nat(9u);
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__13() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("version", 7, 7);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__14() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__13;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__15() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_unsigned_to_nat(11u);
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__16() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("programHeaderOffset", 19, 19);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__17() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__16;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__18() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_unsigned_to_nat(23u);
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__19() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("programHeaderEntrySize", 22, 22);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__20() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__19;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__21() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_unsigned_to_nat(26u);
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__22() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("programHeaderCount", 18, 18);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__23() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__22;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__24() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_unsigned_to_nat(22u);
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__25() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("{ ", 2, 2);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__26() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__25;
x_2 = lean_string_length(x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__27() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__26;
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__28() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__25;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__29() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked(" }", 2, 2);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__30() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__29;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627_(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; lean_object* x_6; lean_object* x_7; uint8_t x_8; lean_object* x_9; lean_object* x_10; lean_object* x_11; lean_object* x_12; lean_object* x_13; lean_object* x_14; lean_object* x_15; lean_object* x_16; lean_object* x_17; lean_object* x_18; lean_object* x_19; uint32_t x_20; lean_object* x_21; lean_object* x_22; lean_object* x_23; lean_object* x_24; lean_object* x_25; lean_object* x_26; lean_object* x_27; lean_object* x_28; lean_object* x_29; lean_object* x_30; lean_object* x_31; lean_object* x_32; lean_object* x_33; lean_object* x_34; lean_object* x_35; lean_object* x_36; lean_object* x_37; lean_object* x_38; lean_object* x_39; lean_object* x_40; lean_object* x_41; lean_object* x_42; lean_object* x_43; lean_object* x_44; lean_object* x_45; lean_object* x_46; lean_object* x_47; lean_object* x_48; lean_object* x_49; lean_object* x_50; lean_object* x_51; lean_object* x_52; lean_object* x_53; lean_object* x_54; lean_object* x_55; lean_object* x_56; lean_object* x_57; lean_object* x_58; lean_object* x_59; lean_object* x_60; lean_object* x_61; lean_object* x_62; lean_object* x_63; lean_object* x_64; lean_object* x_65; lean_object* x_66; lean_object* x_67; lean_object* x_68; lean_object* x_69; lean_object* x_70; lean_object* x_71; lean_object* x_72; lean_object* x_73; lean_object* x_74; lean_object* x_75; lean_object* x_76; lean_object* x_77; lean_object* x_78; lean_object* x_79; lean_object* x_80; lean_object* x_81; lean_object* x_82; 
x_3 = lean_ctor_get(x_1, 0);
lean_inc(x_3);
x_4 = l___private_Init_Data_Repr_0__Nat_reprFast(x_3);
x_5 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_5, 0, x_4);
x_6 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__7;
x_7 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_7, 0, x_6);
lean_ctor_set(x_7, 1, x_5);
x_8 = 0;
x_9 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_9, 0, x_7);
lean_ctor_set_uint8(x_9, sizeof(void*)*1, x_8);
x_10 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__6;
x_11 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_11, 0, x_10);
lean_ctor_set(x_11, 1, x_9);
x_12 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__9;
x_13 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_13, 0, x_11);
lean_ctor_set(x_13, 1, x_12);
x_14 = lean_box(1);
x_15 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_15, 0, x_13);
lean_ctor_set(x_15, 1, x_14);
x_16 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__11;
x_17 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_17, 0, x_15);
lean_ctor_set(x_17, 1, x_16);
x_18 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__5;
x_19 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_19, 0, x_17);
lean_ctor_set(x_19, 1, x_18);
x_20 = lean_ctor_get_uint32(x_1, sizeof(void*)*5);
x_21 = lean_uint32_to_nat(x_20);
x_22 = l___private_Init_Data_Repr_0__Nat_reprFast(x_21);
x_23 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_23, 0, x_22);
x_24 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__12;
x_25 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_25, 0, x_24);
lean_ctor_set(x_25, 1, x_23);
x_26 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_26, 0, x_25);
lean_ctor_set_uint8(x_26, sizeof(void*)*1, x_8);
x_27 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_27, 0, x_19);
lean_ctor_set(x_27, 1, x_26);
x_28 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_28, 0, x_27);
lean_ctor_set(x_28, 1, x_12);
x_29 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_29, 0, x_28);
lean_ctor_set(x_29, 1, x_14);
x_30 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__14;
x_31 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_31, 0, x_29);
lean_ctor_set(x_31, 1, x_30);
x_32 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_32, 0, x_31);
lean_ctor_set(x_32, 1, x_18);
x_33 = lean_ctor_get(x_1, 1);
lean_inc(x_33);
x_34 = l___private_Init_Data_Repr_0__Nat_reprFast(x_33);
x_35 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_35, 0, x_34);
x_36 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__15;
x_37 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_37, 0, x_36);
lean_ctor_set(x_37, 1, x_35);
x_38 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_38, 0, x_37);
lean_ctor_set_uint8(x_38, sizeof(void*)*1, x_8);
x_39 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_39, 0, x_32);
lean_ctor_set(x_39, 1, x_38);
x_40 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_40, 0, x_39);
lean_ctor_set(x_40, 1, x_12);
x_41 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_41, 0, x_40);
lean_ctor_set(x_41, 1, x_14);
x_42 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__17;
x_43 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_43, 0, x_41);
lean_ctor_set(x_43, 1, x_42);
x_44 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_44, 0, x_43);
lean_ctor_set(x_44, 1, x_18);
x_45 = lean_ctor_get(x_1, 2);
lean_inc(x_45);
x_46 = l___private_Init_Data_Repr_0__Nat_reprFast(x_45);
x_47 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_47, 0, x_46);
x_48 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__18;
x_49 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_49, 0, x_48);
lean_ctor_set(x_49, 1, x_47);
x_50 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_50, 0, x_49);
lean_ctor_set_uint8(x_50, sizeof(void*)*1, x_8);
x_51 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_51, 0, x_44);
lean_ctor_set(x_51, 1, x_50);
x_52 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_52, 0, x_51);
lean_ctor_set(x_52, 1, x_12);
x_53 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_53, 0, x_52);
lean_ctor_set(x_53, 1, x_14);
x_54 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__20;
x_55 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_55, 0, x_53);
lean_ctor_set(x_55, 1, x_54);
x_56 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_56, 0, x_55);
lean_ctor_set(x_56, 1, x_18);
x_57 = lean_ctor_get(x_1, 3);
lean_inc(x_57);
x_58 = l___private_Init_Data_Repr_0__Nat_reprFast(x_57);
x_59 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_59, 0, x_58);
x_60 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__21;
x_61 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_61, 0, x_60);
lean_ctor_set(x_61, 1, x_59);
x_62 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_62, 0, x_61);
lean_ctor_set_uint8(x_62, sizeof(void*)*1, x_8);
x_63 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_63, 0, x_56);
lean_ctor_set(x_63, 1, x_62);
x_64 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_64, 0, x_63);
lean_ctor_set(x_64, 1, x_12);
x_65 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_65, 0, x_64);
lean_ctor_set(x_65, 1, x_14);
x_66 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__23;
x_67 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_67, 0, x_65);
lean_ctor_set(x_67, 1, x_66);
x_68 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_68, 0, x_67);
lean_ctor_set(x_68, 1, x_18);
x_69 = lean_ctor_get(x_1, 4);
lean_inc(x_69);
lean_dec(x_1);
x_70 = l___private_Init_Data_Repr_0__Nat_reprFast(x_69);
x_71 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_71, 0, x_70);
x_72 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__24;
x_73 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_73, 0, x_72);
lean_ctor_set(x_73, 1, x_71);
x_74 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_74, 0, x_73);
lean_ctor_set_uint8(x_74, sizeof(void*)*1, x_8);
x_75 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_75, 0, x_68);
lean_ctor_set(x_75, 1, x_74);
x_76 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__28;
x_77 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_77, 0, x_76);
lean_ctor_set(x_77, 1, x_75);
x_78 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__30;
x_79 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_79, 0, x_77);
lean_ctor_set(x_79, 1, x_78);
x_80 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__27;
x_81 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_81, 0, x_80);
lean_ctor_set(x_81, 1, x_79);
x_82 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_82, 0, x_81);
lean_ctor_set_uint8(x_82, sizeof(void*)*1, x_8);
return x_82;
}
}
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627_(x_1, x_2);
lean_dec(x_2);
return x_3;
}
}
static lean_object* _init_l_ZkRV32I_Binary_instReprELF32Header___closed__1() {
_start:
{
lean_object* x_1; 
x_1 = lean_alloc_closure((void*)(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____boxed), 2, 0);
return x_1;
}
}
static lean_object* _init_l_ZkRV32I_Binary_instReprELF32Header() {
_start:
{
lean_object* x_1; 
x_1 = l_ZkRV32I_Binary_instReprELF32Header___closed__1;
return x_1;
}
}
LEAN_EXPORT uint8_t l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_decEqELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_825_(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; lean_object* x_6; lean_object* x_7; lean_object* x_8; lean_object* x_9; lean_object* x_10; lean_object* x_11; lean_object* x_12; lean_object* x_13; lean_object* x_14; lean_object* x_15; lean_object* x_16; uint8_t x_17; 
x_3 = lean_ctor_get(x_1, 0);
x_4 = lean_ctor_get(x_1, 1);
x_5 = lean_ctor_get(x_1, 2);
x_6 = lean_ctor_get(x_1, 3);
x_7 = lean_ctor_get(x_1, 4);
x_8 = lean_ctor_get(x_1, 5);
x_9 = lean_ctor_get(x_1, 6);
x_10 = lean_ctor_get(x_2, 0);
x_11 = lean_ctor_get(x_2, 1);
x_12 = lean_ctor_get(x_2, 2);
x_13 = lean_ctor_get(x_2, 3);
x_14 = lean_ctor_get(x_2, 4);
x_15 = lean_ctor_get(x_2, 5);
x_16 = lean_ctor_get(x_2, 6);
x_17 = lean_nat_dec_eq(x_3, x_10);
if (x_17 == 0)
{
uint8_t x_18; 
x_18 = 0;
return x_18;
}
else
{
uint8_t x_19; 
x_19 = lean_nat_dec_eq(x_4, x_11);
if (x_19 == 0)
{
uint8_t x_20; 
x_20 = 0;
return x_20;
}
else
{
uint8_t x_21; 
x_21 = lean_nat_dec_eq(x_5, x_12);
if (x_21 == 0)
{
uint8_t x_22; 
x_22 = 0;
return x_22;
}
else
{
uint8_t x_23; 
x_23 = lean_nat_dec_eq(x_6, x_13);
if (x_23 == 0)
{
uint8_t x_24; 
x_24 = 0;
return x_24;
}
else
{
uint8_t x_25; 
x_25 = lean_nat_dec_eq(x_7, x_14);
if (x_25 == 0)
{
uint8_t x_26; 
x_26 = 0;
return x_26;
}
else
{
uint8_t x_27; 
x_27 = lean_nat_dec_eq(x_8, x_15);
if (x_27 == 0)
{
uint8_t x_28; 
x_28 = 0;
return x_28;
}
else
{
uint8_t x_29; 
x_29 = lean_nat_dec_eq(x_9, x_16);
return x_29;
}
}
}
}
}
}
}
}
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_decEqELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_825____boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint8_t x_3; lean_object* x_4; 
x_3 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_decEqELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_825_(x_1, x_2);
lean_dec(x_2);
lean_dec(x_1);
x_4 = lean_box(x_3);
return x_4;
}
}
LEAN_EXPORT uint8_t l_ZkRV32I_Binary_instDecidableEqELF32ProgramHeader(lean_object* x_1, lean_object* x_2) {
_start:
{
uint8_t x_3; 
x_3 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_decEqELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_825_(x_1, x_2);
return x_3;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_instDecidableEqELF32ProgramHeader___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint8_t x_3; lean_object* x_4; 
x_3 = l_ZkRV32I_Binary_instDecidableEqELF32ProgramHeader(x_1, x_2);
lean_dec(x_2);
lean_dec(x_1);
x_4 = lean_box(x_3);
return x_4;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__1() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("segmentType", 11, 11);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__2() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__1;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__3() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = lean_box(0);
x_2 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__2;
x_3 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_3, 0, x_1);
lean_ctor_set(x_3, 1, x_2);
return x_3;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__4() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__3;
x_2 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__5;
x_3 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_3, 0, x_1);
lean_ctor_set(x_3, 1, x_2);
return x_3;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__5() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_unsigned_to_nat(15u);
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__6() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("fileOffset", 10, 10);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__7() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__6;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__8() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("virtualAddress", 14, 14);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__9() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__8;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__10() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_unsigned_to_nat(18u);
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__11() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("fileSize", 8, 8);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__12() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__11;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__13() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_unsigned_to_nat(12u);
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__14() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("memorySize", 10, 10);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__15() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__14;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__16() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("flags", 5, 5);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__17() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__16;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__18() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("alignment", 9, 9);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__19() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__18;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__20() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_unsigned_to_nat(13u);
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275_(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; lean_object* x_6; lean_object* x_7; uint8_t x_8; lean_object* x_9; lean_object* x_10; lean_object* x_11; lean_object* x_12; lean_object* x_13; lean_object* x_14; lean_object* x_15; lean_object* x_16; lean_object* x_17; lean_object* x_18; lean_object* x_19; lean_object* x_20; lean_object* x_21; lean_object* x_22; lean_object* x_23; lean_object* x_24; lean_object* x_25; lean_object* x_26; lean_object* x_27; lean_object* x_28; lean_object* x_29; lean_object* x_30; lean_object* x_31; lean_object* x_32; lean_object* x_33; lean_object* x_34; lean_object* x_35; lean_object* x_36; lean_object* x_37; lean_object* x_38; lean_object* x_39; lean_object* x_40; lean_object* x_41; lean_object* x_42; lean_object* x_43; lean_object* x_44; lean_object* x_45; lean_object* x_46; lean_object* x_47; lean_object* x_48; lean_object* x_49; lean_object* x_50; lean_object* x_51; lean_object* x_52; lean_object* x_53; lean_object* x_54; lean_object* x_55; lean_object* x_56; lean_object* x_57; lean_object* x_58; lean_object* x_59; lean_object* x_60; lean_object* x_61; lean_object* x_62; lean_object* x_63; lean_object* x_64; lean_object* x_65; lean_object* x_66; lean_object* x_67; lean_object* x_68; lean_object* x_69; lean_object* x_70; lean_object* x_71; lean_object* x_72; lean_object* x_73; lean_object* x_74; lean_object* x_75; lean_object* x_76; lean_object* x_77; lean_object* x_78; lean_object* x_79; lean_object* x_80; lean_object* x_81; lean_object* x_82; lean_object* x_83; lean_object* x_84; lean_object* x_85; lean_object* x_86; lean_object* x_87; lean_object* x_88; lean_object* x_89; lean_object* x_90; lean_object* x_91; lean_object* x_92; 
x_3 = lean_ctor_get(x_1, 0);
lean_inc(x_3);
x_4 = l___private_Init_Data_Repr_0__Nat_reprFast(x_3);
x_5 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_5, 0, x_4);
x_6 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__5;
x_7 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_7, 0, x_6);
lean_ctor_set(x_7, 1, x_5);
x_8 = 0;
x_9 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_9, 0, x_7);
lean_ctor_set_uint8(x_9, sizeof(void*)*1, x_8);
x_10 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__4;
x_11 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_11, 0, x_10);
lean_ctor_set(x_11, 1, x_9);
x_12 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__9;
x_13 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_13, 0, x_11);
lean_ctor_set(x_13, 1, x_12);
x_14 = lean_box(1);
x_15 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_15, 0, x_13);
lean_ctor_set(x_15, 1, x_14);
x_16 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__7;
x_17 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_17, 0, x_15);
lean_ctor_set(x_17, 1, x_16);
x_18 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__5;
x_19 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_19, 0, x_17);
lean_ctor_set(x_19, 1, x_18);
x_20 = lean_ctor_get(x_1, 1);
lean_inc(x_20);
x_21 = l___private_Init_Data_Repr_0__Nat_reprFast(x_20);
x_22 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_22, 0, x_21);
x_23 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__7;
x_24 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_24, 0, x_23);
lean_ctor_set(x_24, 1, x_22);
x_25 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_25, 0, x_24);
lean_ctor_set_uint8(x_25, sizeof(void*)*1, x_8);
x_26 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_26, 0, x_19);
lean_ctor_set(x_26, 1, x_25);
x_27 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_27, 0, x_26);
lean_ctor_set(x_27, 1, x_12);
x_28 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_28, 0, x_27);
lean_ctor_set(x_28, 1, x_14);
x_29 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__9;
x_30 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_30, 0, x_28);
lean_ctor_set(x_30, 1, x_29);
x_31 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_31, 0, x_30);
lean_ctor_set(x_31, 1, x_18);
x_32 = lean_ctor_get(x_1, 2);
lean_inc(x_32);
x_33 = l___private_Init_Data_Repr_0__Nat_reprFast(x_32);
x_34 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_34, 0, x_33);
x_35 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__10;
x_36 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_36, 0, x_35);
lean_ctor_set(x_36, 1, x_34);
x_37 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_37, 0, x_36);
lean_ctor_set_uint8(x_37, sizeof(void*)*1, x_8);
x_38 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_38, 0, x_31);
lean_ctor_set(x_38, 1, x_37);
x_39 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_39, 0, x_38);
lean_ctor_set(x_39, 1, x_12);
x_40 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_40, 0, x_39);
lean_ctor_set(x_40, 1, x_14);
x_41 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__12;
x_42 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_42, 0, x_40);
lean_ctor_set(x_42, 1, x_41);
x_43 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_43, 0, x_42);
lean_ctor_set(x_43, 1, x_18);
x_44 = lean_ctor_get(x_1, 3);
lean_inc(x_44);
x_45 = l___private_Init_Data_Repr_0__Nat_reprFast(x_44);
x_46 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_46, 0, x_45);
x_47 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__13;
x_48 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_48, 0, x_47);
lean_ctor_set(x_48, 1, x_46);
x_49 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_49, 0, x_48);
lean_ctor_set_uint8(x_49, sizeof(void*)*1, x_8);
x_50 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_50, 0, x_43);
lean_ctor_set(x_50, 1, x_49);
x_51 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_51, 0, x_50);
lean_ctor_set(x_51, 1, x_12);
x_52 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_52, 0, x_51);
lean_ctor_set(x_52, 1, x_14);
x_53 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__15;
x_54 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_54, 0, x_52);
lean_ctor_set(x_54, 1, x_53);
x_55 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_55, 0, x_54);
lean_ctor_set(x_55, 1, x_18);
x_56 = lean_ctor_get(x_1, 4);
lean_inc(x_56);
x_57 = l___private_Init_Data_Repr_0__Nat_reprFast(x_56);
x_58 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_58, 0, x_57);
x_59 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_59, 0, x_23);
lean_ctor_set(x_59, 1, x_58);
x_60 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_60, 0, x_59);
lean_ctor_set_uint8(x_60, sizeof(void*)*1, x_8);
x_61 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_61, 0, x_55);
lean_ctor_set(x_61, 1, x_60);
x_62 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_62, 0, x_61);
lean_ctor_set(x_62, 1, x_12);
x_63 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_63, 0, x_62);
lean_ctor_set(x_63, 1, x_14);
x_64 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__17;
x_65 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_65, 0, x_63);
lean_ctor_set(x_65, 1, x_64);
x_66 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_66, 0, x_65);
lean_ctor_set(x_66, 1, x_18);
x_67 = lean_ctor_get(x_1, 5);
lean_inc(x_67);
x_68 = l___private_Init_Data_Repr_0__Nat_reprFast(x_67);
x_69 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_69, 0, x_68);
x_70 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__12;
x_71 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_71, 0, x_70);
lean_ctor_set(x_71, 1, x_69);
x_72 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_72, 0, x_71);
lean_ctor_set_uint8(x_72, sizeof(void*)*1, x_8);
x_73 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_73, 0, x_66);
lean_ctor_set(x_73, 1, x_72);
x_74 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_74, 0, x_73);
lean_ctor_set(x_74, 1, x_12);
x_75 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_75, 0, x_74);
lean_ctor_set(x_75, 1, x_14);
x_76 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__19;
x_77 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_77, 0, x_75);
lean_ctor_set(x_77, 1, x_76);
x_78 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_78, 0, x_77);
lean_ctor_set(x_78, 1, x_18);
x_79 = lean_ctor_get(x_1, 6);
lean_inc(x_79);
lean_dec(x_1);
x_80 = l___private_Init_Data_Repr_0__Nat_reprFast(x_79);
x_81 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_81, 0, x_80);
x_82 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__20;
x_83 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_83, 0, x_82);
lean_ctor_set(x_83, 1, x_81);
x_84 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_84, 0, x_83);
lean_ctor_set_uint8(x_84, sizeof(void*)*1, x_8);
x_85 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_85, 0, x_78);
lean_ctor_set(x_85, 1, x_84);
x_86 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__28;
x_87 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_87, 0, x_86);
lean_ctor_set(x_87, 1, x_85);
x_88 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__30;
x_89 = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(x_89, 0, x_87);
lean_ctor_set(x_89, 1, x_88);
x_90 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__27;
x_91 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_91, 0, x_90);
lean_ctor_set(x_91, 1, x_89);
x_92 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_92, 0, x_91);
lean_ctor_set_uint8(x_92, sizeof(void*)*1, x_8);
return x_92;
}
}
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275_(x_1, x_2);
lean_dec(x_2);
return x_3;
}
}
static lean_object* _init_l_ZkRV32I_Binary_instReprELF32ProgramHeader___closed__1() {
_start:
{
lean_object* x_1; 
x_1 = lean_alloc_closure((void*)(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____boxed), 2, 0);
return x_1;
}
}
static lean_object* _init_l_ZkRV32I_Binary_instReprELF32ProgramHeader() {
_start:
{
lean_object* x_1; 
x_1 = l_ZkRV32I_Binary_instReprELF32ProgramHeader___closed__1;
return x_1;
}
}
LEAN_EXPORT uint8_t l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(lean_object* x_1, lean_object* x_2) {
_start:
{
if (lean_obj_tag(x_1) == 0)
{
if (lean_obj_tag(x_2) == 0)
{
uint8_t x_3; 
x_3 = 1;
return x_3;
}
else
{
uint8_t x_4; 
lean_dec(x_2);
x_4 = 0;
return x_4;
}
}
else
{
if (lean_obj_tag(x_2) == 0)
{
uint8_t x_5; 
lean_dec(x_1);
x_5 = 0;
return x_5;
}
else
{
lean_object* x_6; lean_object* x_7; uint8_t x_8; uint8_t x_9; uint8_t x_10; 
x_6 = lean_ctor_get(x_1, 0);
lean_inc(x_6);
lean_dec(x_1);
x_7 = lean_ctor_get(x_2, 0);
lean_inc(x_7);
lean_dec(x_2);
x_8 = lean_unbox(x_6);
lean_dec(x_6);
x_9 = lean_unbox(x_7);
lean_dec(x_7);
x_10 = lean_uint8_dec_eq(x_8, x_9);
return x_10;
}
}
}
}
static lean_object* _init_l_ZkRV32I_Binary_parseELF32Header___closed__1() {
_start:
{
uint8_t x_1; lean_object* x_2; lean_object* x_3; 
x_1 = 1;
x_2 = lean_box(x_1);
x_3 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_3, 0, x_2);
return x_3;
}
}
static lean_object* _init_l_ZkRV32I_Binary_parseELF32Header___closed__2() {
_start:
{
uint8_t x_1; lean_object* x_2; lean_object* x_3; 
x_1 = 70;
x_2 = lean_box(x_1);
x_3 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_3, 0, x_2);
return x_3;
}
}
static lean_object* _init_l_ZkRV32I_Binary_parseELF32Header___closed__3() {
_start:
{
uint8_t x_1; lean_object* x_2; lean_object* x_3; 
x_1 = 76;
x_2 = lean_box(x_1);
x_3 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_3, 0, x_2);
return x_3;
}
}
static lean_object* _init_l_ZkRV32I_Binary_parseELF32Header___closed__4() {
_start:
{
uint8_t x_1; lean_object* x_2; lean_object* x_3; 
x_1 = 69;
x_2 = lean_box(x_1);
x_3 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_3, 0, x_2);
return x_3;
}
}
static lean_object* _init_l_ZkRV32I_Binary_parseELF32Header___closed__5() {
_start:
{
uint8_t x_1; lean_object* x_2; lean_object* x_3; 
x_1 = 127;
x_2 = lean_box(x_1);
x_3 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_3, 0, x_2);
return x_3;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_parseELF32Header(lean_object* x_1) {
_start:
{
lean_object* x_2; lean_object* x_3; lean_object* x_86; lean_object* x_103; lean_object* x_120; lean_object* x_137; lean_object* x_154; lean_object* x_171; lean_object* x_188; uint8_t x_189; 
x_2 = lean_array_get_size(x_1);
x_188 = lean_unsigned_to_nat(52u);
x_189 = lean_nat_dec_le(x_188, x_2);
if (x_189 == 0)
{
lean_object* x_190; 
lean_dec(x_2);
x_190 = lean_box(0);
return x_190;
}
else
{
lean_object* x_191; uint8_t x_192; 
x_191 = lean_unsigned_to_nat(0u);
x_192 = lean_nat_dec_lt(x_191, x_2);
if (x_192 == 0)
{
lean_object* x_193; lean_object* x_194; uint8_t x_195; 
x_193 = lean_box(0);
x_194 = l_ZkRV32I_Binary_parseELF32Header___closed__5;
x_195 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_193, x_194);
if (x_195 == 0)
{
lean_object* x_196; 
lean_dec(x_2);
x_196 = lean_box(0);
return x_196;
}
else
{
lean_object* x_197; 
x_197 = lean_box(0);
x_171 = x_197;
goto block_187;
}
}
else
{
lean_object* x_198; uint8_t x_199; lean_object* x_200; lean_object* x_201; lean_object* x_202; uint8_t x_203; 
x_198 = lean_array_fget(x_1, x_191);
x_199 = lean_unbox(x_198);
lean_dec(x_198);
x_200 = lean_box(x_199);
x_201 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_201, 0, x_200);
x_202 = l_ZkRV32I_Binary_parseELF32Header___closed__5;
x_203 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_201, x_202);
if (x_203 == 0)
{
lean_object* x_204; 
lean_dec(x_2);
x_204 = lean_box(0);
return x_204;
}
else
{
lean_object* x_205; 
x_205 = lean_box(0);
x_171 = x_205;
goto block_187;
}
}
}
block_85:
{
lean_object* x_4; lean_object* x_5; 
lean_dec(x_3);
x_4 = lean_unsigned_to_nat(16u);
x_5 = l_ZkRV32I_Binary_readU16LE(x_1, x_4);
if (lean_obj_tag(x_5) == 0)
{
lean_object* x_6; 
lean_dec(x_2);
x_6 = lean_box(0);
return x_6;
}
else
{
lean_object* x_7; lean_object* x_8; lean_object* x_9; 
x_7 = lean_ctor_get(x_5, 0);
lean_inc(x_7);
lean_dec(x_5);
x_8 = lean_unsigned_to_nat(18u);
x_9 = l_ZkRV32I_Binary_readU16LE(x_1, x_8);
if (lean_obj_tag(x_9) == 0)
{
lean_object* x_10; 
lean_dec(x_7);
lean_dec(x_2);
x_10 = lean_box(0);
return x_10;
}
else
{
lean_object* x_11; lean_object* x_12; lean_object* x_13; 
x_11 = lean_ctor_get(x_9, 0);
lean_inc(x_11);
lean_dec(x_9);
x_12 = lean_unsigned_to_nat(20u);
x_13 = l_ZkRV32I_Binary_readU32LE(x_1, x_12);
if (lean_obj_tag(x_13) == 0)
{
lean_object* x_14; 
lean_dec(x_11);
lean_dec(x_7);
lean_dec(x_2);
x_14 = lean_box(0);
return x_14;
}
else
{
lean_object* x_15; lean_object* x_16; lean_object* x_17; 
x_15 = lean_ctor_get(x_13, 0);
lean_inc(x_15);
lean_dec(x_13);
x_16 = lean_unsigned_to_nat(24u);
x_17 = l_ZkRV32I_Binary_readU32LE(x_1, x_16);
if (lean_obj_tag(x_17) == 0)
{
lean_object* x_18; 
lean_dec(x_15);
lean_dec(x_11);
lean_dec(x_7);
lean_dec(x_2);
x_18 = lean_box(0);
return x_18;
}
else
{
lean_object* x_19; lean_object* x_20; lean_object* x_21; 
x_19 = lean_ctor_get(x_17, 0);
lean_inc(x_19);
lean_dec(x_17);
x_20 = lean_unsigned_to_nat(28u);
x_21 = l_ZkRV32I_Binary_readU32LE(x_1, x_20);
if (lean_obj_tag(x_21) == 0)
{
lean_object* x_22; 
lean_dec(x_19);
lean_dec(x_15);
lean_dec(x_11);
lean_dec(x_7);
lean_dec(x_2);
x_22 = lean_box(0);
return x_22;
}
else
{
lean_object* x_23; lean_object* x_24; lean_object* x_25; 
x_23 = lean_ctor_get(x_21, 0);
lean_inc(x_23);
lean_dec(x_21);
x_24 = lean_unsigned_to_nat(40u);
x_25 = l_ZkRV32I_Binary_readU16LE(x_1, x_24);
if (lean_obj_tag(x_25) == 0)
{
lean_object* x_26; 
lean_dec(x_23);
lean_dec(x_19);
lean_dec(x_15);
lean_dec(x_11);
lean_dec(x_7);
lean_dec(x_2);
x_26 = lean_box(0);
return x_26;
}
else
{
lean_object* x_27; lean_object* x_28; lean_object* x_29; 
x_27 = lean_ctor_get(x_25, 0);
lean_inc(x_27);
lean_dec(x_25);
x_28 = lean_unsigned_to_nat(42u);
x_29 = l_ZkRV32I_Binary_readU16LE(x_1, x_28);
if (lean_obj_tag(x_29) == 0)
{
lean_object* x_30; 
lean_dec(x_27);
lean_dec(x_23);
lean_dec(x_19);
lean_dec(x_15);
lean_dec(x_11);
lean_dec(x_7);
lean_dec(x_2);
x_30 = lean_box(0);
return x_30;
}
else
{
lean_object* x_31; lean_object* x_32; lean_object* x_33; 
x_31 = lean_ctor_get(x_29, 0);
lean_inc(x_31);
lean_dec(x_29);
x_32 = lean_unsigned_to_nat(44u);
x_33 = l_ZkRV32I_Binary_readU16LE(x_1, x_32);
if (lean_obj_tag(x_33) == 0)
{
lean_object* x_34; 
lean_dec(x_31);
lean_dec(x_27);
lean_dec(x_23);
lean_dec(x_19);
lean_dec(x_15);
lean_dec(x_11);
lean_dec(x_7);
lean_dec(x_2);
x_34 = lean_box(0);
return x_34;
}
else
{
lean_object* x_35; lean_object* x_36; uint16_t x_37; lean_object* x_38; lean_object* x_39; lean_object* x_56; uint8_t x_57; 
x_35 = lean_ctor_get(x_33, 0);
lean_inc(x_35);
if (lean_is_exclusive(x_33)) {
 lean_ctor_release(x_33, 0);
 x_36 = x_33;
} else {
 lean_dec_ref(x_33);
 x_36 = lean_box(0);
}
x_37 = lean_unbox(x_7);
lean_dec(x_7);
x_38 = lean_uint16_to_nat(x_37);
x_56 = lean_unsigned_to_nat(2u);
x_57 = lean_nat_dec_eq(x_38, x_56);
if (x_57 == 0)
{
lean_object* x_58; 
lean_dec(x_38);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_31);
lean_dec(x_27);
lean_dec(x_23);
lean_dec(x_19);
lean_dec(x_15);
lean_dec(x_11);
lean_dec(x_2);
x_58 = lean_box(0);
return x_58;
}
else
{
uint16_t x_59; lean_object* x_60; lean_object* x_61; uint8_t x_62; 
x_59 = lean_unbox(x_11);
lean_dec(x_11);
x_60 = lean_uint16_to_nat(x_59);
x_61 = lean_unsigned_to_nat(243u);
x_62 = lean_nat_dec_eq(x_60, x_61);
lean_dec(x_60);
if (x_62 == 0)
{
lean_object* x_63; 
lean_dec(x_38);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_31);
lean_dec(x_27);
lean_dec(x_23);
lean_dec(x_19);
lean_dec(x_15);
lean_dec(x_2);
x_63 = lean_box(0);
return x_63;
}
else
{
uint32_t x_64; lean_object* x_65; lean_object* x_66; uint8_t x_67; 
x_64 = lean_unbox_uint32(x_15);
x_65 = lean_uint32_to_nat(x_64);
x_66 = lean_unsigned_to_nat(1u);
x_67 = lean_nat_dec_eq(x_65, x_66);
lean_dec(x_65);
if (x_67 == 0)
{
lean_object* x_68; 
lean_dec(x_38);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_31);
lean_dec(x_27);
lean_dec(x_23);
lean_dec(x_19);
lean_dec(x_15);
lean_dec(x_2);
x_68 = lean_box(0);
return x_68;
}
else
{
uint16_t x_69; lean_object* x_70; lean_object* x_71; uint8_t x_72; 
x_69 = lean_unbox(x_27);
lean_dec(x_27);
x_70 = lean_uint16_to_nat(x_69);
x_71 = lean_unsigned_to_nat(52u);
x_72 = lean_nat_dec_eq(x_70, x_71);
lean_dec(x_70);
if (x_72 == 0)
{
lean_object* x_73; 
lean_dec(x_38);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_31);
lean_dec(x_23);
lean_dec(x_19);
lean_dec(x_15);
lean_dec(x_2);
x_73 = lean_box(0);
return x_73;
}
else
{
uint16_t x_74; lean_object* x_75; lean_object* x_76; uint8_t x_77; 
x_74 = lean_unbox(x_35);
x_75 = lean_uint16_to_nat(x_74);
x_76 = lean_unsigned_to_nat(0u);
x_77 = lean_nat_dec_eq(x_75, x_76);
lean_dec(x_75);
if (x_77 == 0)
{
uint16_t x_78; lean_object* x_79; lean_object* x_80; uint8_t x_81; 
x_78 = lean_unbox(x_31);
x_79 = lean_uint16_to_nat(x_78);
x_80 = lean_unsigned_to_nat(32u);
x_81 = lean_nat_dec_le(x_80, x_79);
lean_dec(x_79);
if (x_81 == 0)
{
lean_object* x_82; 
lean_dec(x_38);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_31);
lean_dec(x_23);
lean_dec(x_19);
lean_dec(x_15);
lean_dec(x_2);
x_82 = lean_box(0);
return x_82;
}
else
{
lean_object* x_83; 
x_83 = lean_box(0);
x_39 = x_83;
goto block_55;
}
}
else
{
lean_object* x_84; 
x_84 = lean_box(0);
x_39 = x_84;
goto block_55;
}
}
}
}
}
block_55:
{
uint32_t x_40; lean_object* x_41; uint16_t x_42; lean_object* x_43; uint16_t x_44; lean_object* x_45; lean_object* x_46; lean_object* x_47; uint8_t x_48; 
lean_dec(x_39);
x_40 = lean_unbox_uint32(x_23);
lean_dec(x_23);
x_41 = lean_uint32_to_nat(x_40);
x_42 = lean_unbox(x_31);
lean_dec(x_31);
x_43 = lean_uint16_to_nat(x_42);
x_44 = lean_unbox(x_35);
lean_dec(x_35);
x_45 = lean_uint16_to_nat(x_44);
x_46 = lean_nat_mul(x_43, x_45);
x_47 = lean_nat_add(x_41, x_46);
lean_dec(x_46);
x_48 = lean_nat_dec_le(x_47, x_2);
lean_dec(x_2);
lean_dec(x_47);
if (x_48 == 0)
{
lean_object* x_49; 
lean_dec(x_45);
lean_dec(x_43);
lean_dec(x_41);
lean_dec(x_38);
lean_dec(x_36);
lean_dec(x_19);
lean_dec(x_15);
x_49 = lean_box(0);
return x_49;
}
else
{
uint32_t x_50; lean_object* x_51; lean_object* x_52; uint32_t x_53; lean_object* x_54; 
x_50 = lean_unbox_uint32(x_15);
lean_dec(x_15);
x_51 = lean_uint32_to_nat(x_50);
x_52 = lean_alloc_ctor(0, 5, 4);
lean_ctor_set(x_52, 0, x_38);
lean_ctor_set(x_52, 1, x_51);
lean_ctor_set(x_52, 2, x_41);
lean_ctor_set(x_52, 3, x_43);
lean_ctor_set(x_52, 4, x_45);
x_53 = lean_unbox_uint32(x_19);
lean_dec(x_19);
lean_ctor_set_uint32(x_52, sizeof(void*)*5, x_53);
if (lean_is_scalar(x_36)) {
 x_54 = lean_alloc_ctor(1, 1, 0);
} else {
 x_54 = x_36;
}
lean_ctor_set(x_54, 0, x_52);
return x_54;
}
}
}
}
}
}
}
}
}
}
}
block_102:
{
lean_object* x_87; uint8_t x_88; 
lean_dec(x_86);
x_87 = lean_unsigned_to_nat(6u);
x_88 = lean_nat_dec_lt(x_87, x_2);
if (x_88 == 0)
{
lean_object* x_89; lean_object* x_90; uint8_t x_91; 
x_89 = lean_box(0);
x_90 = l_ZkRV32I_Binary_parseELF32Header___closed__1;
x_91 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_89, x_90);
if (x_91 == 0)
{
lean_object* x_92; 
lean_dec(x_2);
x_92 = lean_box(0);
return x_92;
}
else
{
lean_object* x_93; 
x_93 = lean_box(0);
x_3 = x_93;
goto block_85;
}
}
else
{
lean_object* x_94; uint8_t x_95; lean_object* x_96; lean_object* x_97; lean_object* x_98; uint8_t x_99; 
x_94 = lean_array_fget(x_1, x_87);
x_95 = lean_unbox(x_94);
lean_dec(x_94);
x_96 = lean_box(x_95);
x_97 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_97, 0, x_96);
x_98 = l_ZkRV32I_Binary_parseELF32Header___closed__1;
x_99 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_97, x_98);
if (x_99 == 0)
{
lean_object* x_100; 
lean_dec(x_2);
x_100 = lean_box(0);
return x_100;
}
else
{
lean_object* x_101; 
x_101 = lean_box(0);
x_3 = x_101;
goto block_85;
}
}
}
block_119:
{
lean_object* x_104; uint8_t x_105; 
lean_dec(x_103);
x_104 = lean_unsigned_to_nat(5u);
x_105 = lean_nat_dec_lt(x_104, x_2);
if (x_105 == 0)
{
lean_object* x_106; lean_object* x_107; uint8_t x_108; 
x_106 = lean_box(0);
x_107 = l_ZkRV32I_Binary_parseELF32Header___closed__1;
x_108 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_106, x_107);
if (x_108 == 0)
{
lean_object* x_109; 
lean_dec(x_2);
x_109 = lean_box(0);
return x_109;
}
else
{
lean_object* x_110; 
x_110 = lean_box(0);
x_86 = x_110;
goto block_102;
}
}
else
{
lean_object* x_111; uint8_t x_112; lean_object* x_113; lean_object* x_114; lean_object* x_115; uint8_t x_116; 
x_111 = lean_array_fget(x_1, x_104);
x_112 = lean_unbox(x_111);
lean_dec(x_111);
x_113 = lean_box(x_112);
x_114 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_114, 0, x_113);
x_115 = l_ZkRV32I_Binary_parseELF32Header___closed__1;
x_116 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_114, x_115);
if (x_116 == 0)
{
lean_object* x_117; 
lean_dec(x_2);
x_117 = lean_box(0);
return x_117;
}
else
{
lean_object* x_118; 
x_118 = lean_box(0);
x_86 = x_118;
goto block_102;
}
}
}
block_136:
{
lean_object* x_121; uint8_t x_122; 
lean_dec(x_120);
x_121 = lean_unsigned_to_nat(4u);
x_122 = lean_nat_dec_lt(x_121, x_2);
if (x_122 == 0)
{
lean_object* x_123; lean_object* x_124; uint8_t x_125; 
x_123 = lean_box(0);
x_124 = l_ZkRV32I_Binary_parseELF32Header___closed__1;
x_125 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_123, x_124);
if (x_125 == 0)
{
lean_object* x_126; 
lean_dec(x_2);
x_126 = lean_box(0);
return x_126;
}
else
{
lean_object* x_127; 
x_127 = lean_box(0);
x_103 = x_127;
goto block_119;
}
}
else
{
lean_object* x_128; uint8_t x_129; lean_object* x_130; lean_object* x_131; lean_object* x_132; uint8_t x_133; 
x_128 = lean_array_fget(x_1, x_121);
x_129 = lean_unbox(x_128);
lean_dec(x_128);
x_130 = lean_box(x_129);
x_131 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_131, 0, x_130);
x_132 = l_ZkRV32I_Binary_parseELF32Header___closed__1;
x_133 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_131, x_132);
if (x_133 == 0)
{
lean_object* x_134; 
lean_dec(x_2);
x_134 = lean_box(0);
return x_134;
}
else
{
lean_object* x_135; 
x_135 = lean_box(0);
x_103 = x_135;
goto block_119;
}
}
}
block_153:
{
lean_object* x_138; uint8_t x_139; 
lean_dec(x_137);
x_138 = lean_unsigned_to_nat(3u);
x_139 = lean_nat_dec_lt(x_138, x_2);
if (x_139 == 0)
{
lean_object* x_140; lean_object* x_141; uint8_t x_142; 
x_140 = lean_box(0);
x_141 = l_ZkRV32I_Binary_parseELF32Header___closed__2;
x_142 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_140, x_141);
if (x_142 == 0)
{
lean_object* x_143; 
lean_dec(x_2);
x_143 = lean_box(0);
return x_143;
}
else
{
lean_object* x_144; 
x_144 = lean_box(0);
x_120 = x_144;
goto block_136;
}
}
else
{
lean_object* x_145; uint8_t x_146; lean_object* x_147; lean_object* x_148; lean_object* x_149; uint8_t x_150; 
x_145 = lean_array_fget(x_1, x_138);
x_146 = lean_unbox(x_145);
lean_dec(x_145);
x_147 = lean_box(x_146);
x_148 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_148, 0, x_147);
x_149 = l_ZkRV32I_Binary_parseELF32Header___closed__2;
x_150 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_148, x_149);
if (x_150 == 0)
{
lean_object* x_151; 
lean_dec(x_2);
x_151 = lean_box(0);
return x_151;
}
else
{
lean_object* x_152; 
x_152 = lean_box(0);
x_120 = x_152;
goto block_136;
}
}
}
block_170:
{
lean_object* x_155; uint8_t x_156; 
lean_dec(x_154);
x_155 = lean_unsigned_to_nat(2u);
x_156 = lean_nat_dec_lt(x_155, x_2);
if (x_156 == 0)
{
lean_object* x_157; lean_object* x_158; uint8_t x_159; 
x_157 = lean_box(0);
x_158 = l_ZkRV32I_Binary_parseELF32Header___closed__3;
x_159 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_157, x_158);
if (x_159 == 0)
{
lean_object* x_160; 
lean_dec(x_2);
x_160 = lean_box(0);
return x_160;
}
else
{
lean_object* x_161; 
x_161 = lean_box(0);
x_137 = x_161;
goto block_153;
}
}
else
{
lean_object* x_162; uint8_t x_163; lean_object* x_164; lean_object* x_165; lean_object* x_166; uint8_t x_167; 
x_162 = lean_array_fget(x_1, x_155);
x_163 = lean_unbox(x_162);
lean_dec(x_162);
x_164 = lean_box(x_163);
x_165 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_165, 0, x_164);
x_166 = l_ZkRV32I_Binary_parseELF32Header___closed__3;
x_167 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_165, x_166);
if (x_167 == 0)
{
lean_object* x_168; 
lean_dec(x_2);
x_168 = lean_box(0);
return x_168;
}
else
{
lean_object* x_169; 
x_169 = lean_box(0);
x_137 = x_169;
goto block_153;
}
}
}
block_187:
{
lean_object* x_172; uint8_t x_173; 
lean_dec(x_171);
x_172 = lean_unsigned_to_nat(1u);
x_173 = lean_nat_dec_lt(x_172, x_2);
if (x_173 == 0)
{
lean_object* x_174; lean_object* x_175; uint8_t x_176; 
x_174 = lean_box(0);
x_175 = l_ZkRV32I_Binary_parseELF32Header___closed__4;
x_176 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_174, x_175);
if (x_176 == 0)
{
lean_object* x_177; 
lean_dec(x_2);
x_177 = lean_box(0);
return x_177;
}
else
{
lean_object* x_178; 
x_178 = lean_box(0);
x_154 = x_178;
goto block_170;
}
}
else
{
lean_object* x_179; uint8_t x_180; lean_object* x_181; lean_object* x_182; lean_object* x_183; uint8_t x_184; 
x_179 = lean_array_fget(x_1, x_172);
x_180 = lean_unbox(x_179);
lean_dec(x_179);
x_181 = lean_box(x_180);
x_182 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_182, 0, x_181);
x_183 = l_ZkRV32I_Binary_parseELF32Header___closed__4;
x_184 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_182, x_183);
if (x_184 == 0)
{
lean_object* x_185; 
lean_dec(x_2);
x_185 = lean_box(0);
return x_185;
}
else
{
lean_object* x_186; 
x_186 = lean_box(0);
x_154 = x_186;
goto block_170;
}
}
}
}
}
LEAN_EXPORT lean_object* l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint8_t x_3; lean_object* x_4; 
x_3 = l___private_Init_Data_Option_Basic_0__Option_beqOption____x40_Init_Data_Option_Basic___hyg_159____at_ZkRV32I_Binary_parseELF32Header___spec__1(x_1, x_2);
x_4 = lean_box(x_3);
return x_4;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_parseELF32Header___boxed(lean_object* x_1) {
_start:
{
lean_object* x_2; 
x_2 = l_ZkRV32I_Binary_parseELF32Header(x_1);
lean_dec(x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_parseELF32ProgramHeader(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; uint8_t x_6; 
x_3 = lean_unsigned_to_nat(32u);
x_4 = lean_nat_add(x_2, x_3);
x_5 = lean_array_get_size(x_1);
x_6 = lean_nat_dec_le(x_4, x_5);
lean_dec(x_4);
if (x_6 == 0)
{
lean_object* x_7; 
lean_dec(x_5);
x_7 = lean_box(0);
return x_7;
}
else
{
lean_object* x_8; 
x_8 = l_ZkRV32I_Binary_readU32LE(x_1, x_2);
if (lean_obj_tag(x_8) == 0)
{
lean_object* x_9; 
lean_dec(x_5);
x_9 = lean_box(0);
return x_9;
}
else
{
lean_object* x_10; lean_object* x_11; lean_object* x_12; lean_object* x_13; 
x_10 = lean_ctor_get(x_8, 0);
lean_inc(x_10);
lean_dec(x_8);
x_11 = lean_unsigned_to_nat(4u);
x_12 = lean_nat_add(x_2, x_11);
x_13 = l_ZkRV32I_Binary_readU32LE(x_1, x_12);
lean_dec(x_12);
if (lean_obj_tag(x_13) == 0)
{
lean_object* x_14; 
lean_dec(x_10);
lean_dec(x_5);
x_14 = lean_box(0);
return x_14;
}
else
{
lean_object* x_15; lean_object* x_16; lean_object* x_17; lean_object* x_18; 
x_15 = lean_ctor_get(x_13, 0);
lean_inc(x_15);
lean_dec(x_13);
x_16 = lean_unsigned_to_nat(8u);
x_17 = lean_nat_add(x_2, x_16);
x_18 = l_ZkRV32I_Binary_readU32LE(x_1, x_17);
lean_dec(x_17);
if (lean_obj_tag(x_18) == 0)
{
lean_object* x_19; 
lean_dec(x_15);
lean_dec(x_10);
lean_dec(x_5);
x_19 = lean_box(0);
return x_19;
}
else
{
lean_object* x_20; lean_object* x_21; lean_object* x_22; lean_object* x_23; 
x_20 = lean_ctor_get(x_18, 0);
lean_inc(x_20);
lean_dec(x_18);
x_21 = lean_unsigned_to_nat(16u);
x_22 = lean_nat_add(x_2, x_21);
x_23 = l_ZkRV32I_Binary_readU32LE(x_1, x_22);
lean_dec(x_22);
if (lean_obj_tag(x_23) == 0)
{
lean_object* x_24; 
lean_dec(x_20);
lean_dec(x_15);
lean_dec(x_10);
lean_dec(x_5);
x_24 = lean_box(0);
return x_24;
}
else
{
lean_object* x_25; lean_object* x_26; lean_object* x_27; lean_object* x_28; 
x_25 = lean_ctor_get(x_23, 0);
lean_inc(x_25);
lean_dec(x_23);
x_26 = lean_unsigned_to_nat(20u);
x_27 = lean_nat_add(x_2, x_26);
x_28 = l_ZkRV32I_Binary_readU32LE(x_1, x_27);
lean_dec(x_27);
if (lean_obj_tag(x_28) == 0)
{
lean_object* x_29; 
lean_dec(x_25);
lean_dec(x_20);
lean_dec(x_15);
lean_dec(x_10);
lean_dec(x_5);
x_29 = lean_box(0);
return x_29;
}
else
{
lean_object* x_30; lean_object* x_31; lean_object* x_32; lean_object* x_33; 
x_30 = lean_ctor_get(x_28, 0);
lean_inc(x_30);
lean_dec(x_28);
x_31 = lean_unsigned_to_nat(24u);
x_32 = lean_nat_add(x_2, x_31);
x_33 = l_ZkRV32I_Binary_readU32LE(x_1, x_32);
lean_dec(x_32);
if (lean_obj_tag(x_33) == 0)
{
lean_object* x_34; 
lean_dec(x_30);
lean_dec(x_25);
lean_dec(x_20);
lean_dec(x_15);
lean_dec(x_10);
lean_dec(x_5);
x_34 = lean_box(0);
return x_34;
}
else
{
lean_object* x_35; lean_object* x_36; lean_object* x_37; lean_object* x_38; 
x_35 = lean_ctor_get(x_33, 0);
lean_inc(x_35);
lean_dec(x_33);
x_36 = lean_unsigned_to_nat(28u);
x_37 = lean_nat_add(x_2, x_36);
x_38 = l_ZkRV32I_Binary_readU32LE(x_1, x_37);
lean_dec(x_37);
if (lean_obj_tag(x_38) == 0)
{
lean_object* x_39; 
lean_dec(x_35);
lean_dec(x_30);
lean_dec(x_25);
lean_dec(x_20);
lean_dec(x_15);
lean_dec(x_10);
lean_dec(x_5);
x_39 = lean_box(0);
return x_39;
}
else
{
uint8_t x_40; 
x_40 = !lean_is_exclusive(x_38);
if (x_40 == 0)
{
lean_object* x_41; uint32_t x_42; lean_object* x_43; uint32_t x_44; lean_object* x_45; lean_object* x_46; uint8_t x_47; 
x_41 = lean_ctor_get(x_38, 0);
x_42 = lean_unbox_uint32(x_15);
lean_dec(x_15);
x_43 = lean_uint32_to_nat(x_42);
x_44 = lean_unbox_uint32(x_25);
lean_dec(x_25);
x_45 = lean_uint32_to_nat(x_44);
x_46 = lean_nat_add(x_43, x_45);
x_47 = lean_nat_dec_le(x_46, x_5);
lean_dec(x_5);
lean_dec(x_46);
if (x_47 == 0)
{
lean_object* x_48; 
lean_dec(x_45);
lean_dec(x_43);
lean_free_object(x_38);
lean_dec(x_41);
lean_dec(x_35);
lean_dec(x_30);
lean_dec(x_20);
lean_dec(x_10);
x_48 = lean_box(0);
return x_48;
}
else
{
uint32_t x_49; lean_object* x_50; uint8_t x_51; 
x_49 = lean_unbox_uint32(x_30);
lean_dec(x_30);
x_50 = lean_uint32_to_nat(x_49);
x_51 = lean_nat_dec_le(x_45, x_50);
if (x_51 == 0)
{
lean_object* x_52; 
lean_dec(x_50);
lean_dec(x_45);
lean_dec(x_43);
lean_free_object(x_38);
lean_dec(x_41);
lean_dec(x_35);
lean_dec(x_20);
lean_dec(x_10);
x_52 = lean_box(0);
return x_52;
}
else
{
uint32_t x_53; lean_object* x_54; uint32_t x_55; lean_object* x_56; uint32_t x_57; lean_object* x_58; uint32_t x_59; lean_object* x_60; lean_object* x_61; 
x_53 = lean_unbox_uint32(x_10);
lean_dec(x_10);
x_54 = lean_uint32_to_nat(x_53);
x_55 = lean_unbox_uint32(x_20);
lean_dec(x_20);
x_56 = lean_uint32_to_nat(x_55);
x_57 = lean_unbox_uint32(x_35);
lean_dec(x_35);
x_58 = lean_uint32_to_nat(x_57);
x_59 = lean_unbox_uint32(x_41);
lean_dec(x_41);
x_60 = lean_uint32_to_nat(x_59);
x_61 = lean_alloc_ctor(0, 7, 0);
lean_ctor_set(x_61, 0, x_54);
lean_ctor_set(x_61, 1, x_43);
lean_ctor_set(x_61, 2, x_56);
lean_ctor_set(x_61, 3, x_45);
lean_ctor_set(x_61, 4, x_50);
lean_ctor_set(x_61, 5, x_58);
lean_ctor_set(x_61, 6, x_60);
lean_ctor_set(x_38, 0, x_61);
return x_38;
}
}
}
else
{
lean_object* x_62; uint32_t x_63; lean_object* x_64; uint32_t x_65; lean_object* x_66; lean_object* x_67; uint8_t x_68; 
x_62 = lean_ctor_get(x_38, 0);
lean_inc(x_62);
lean_dec(x_38);
x_63 = lean_unbox_uint32(x_15);
lean_dec(x_15);
x_64 = lean_uint32_to_nat(x_63);
x_65 = lean_unbox_uint32(x_25);
lean_dec(x_25);
x_66 = lean_uint32_to_nat(x_65);
x_67 = lean_nat_add(x_64, x_66);
x_68 = lean_nat_dec_le(x_67, x_5);
lean_dec(x_5);
lean_dec(x_67);
if (x_68 == 0)
{
lean_object* x_69; 
lean_dec(x_66);
lean_dec(x_64);
lean_dec(x_62);
lean_dec(x_35);
lean_dec(x_30);
lean_dec(x_20);
lean_dec(x_10);
x_69 = lean_box(0);
return x_69;
}
else
{
uint32_t x_70; lean_object* x_71; uint8_t x_72; 
x_70 = lean_unbox_uint32(x_30);
lean_dec(x_30);
x_71 = lean_uint32_to_nat(x_70);
x_72 = lean_nat_dec_le(x_66, x_71);
if (x_72 == 0)
{
lean_object* x_73; 
lean_dec(x_71);
lean_dec(x_66);
lean_dec(x_64);
lean_dec(x_62);
lean_dec(x_35);
lean_dec(x_20);
lean_dec(x_10);
x_73 = lean_box(0);
return x_73;
}
else
{
uint32_t x_74; lean_object* x_75; uint32_t x_76; lean_object* x_77; uint32_t x_78; lean_object* x_79; uint32_t x_80; lean_object* x_81; lean_object* x_82; lean_object* x_83; 
x_74 = lean_unbox_uint32(x_10);
lean_dec(x_10);
x_75 = lean_uint32_to_nat(x_74);
x_76 = lean_unbox_uint32(x_20);
lean_dec(x_20);
x_77 = lean_uint32_to_nat(x_76);
x_78 = lean_unbox_uint32(x_35);
lean_dec(x_35);
x_79 = lean_uint32_to_nat(x_78);
x_80 = lean_unbox_uint32(x_62);
lean_dec(x_62);
x_81 = lean_uint32_to_nat(x_80);
x_82 = lean_alloc_ctor(0, 7, 0);
lean_ctor_set(x_82, 0, x_75);
lean_ctor_set(x_82, 1, x_64);
lean_ctor_set(x_82, 2, x_77);
lean_ctor_set(x_82, 3, x_66);
lean_ctor_set(x_82, 4, x_71);
lean_ctor_set(x_82, 5, x_79);
lean_ctor_set(x_82, 6, x_81);
x_83 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_83, 0, x_82);
return x_83;
}
}
}
}
}
}
}
}
}
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_parseELF32ProgramHeader___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = l_ZkRV32I_Binary_parseELF32ProgramHeader(x_1, x_2);
lean_dec(x_2);
lean_dec(x_1);
return x_3;
}
}
static lean_object* _init_l_ZkRV32I_Binary_readELF32ProgramHeaders___closed__1() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_box(0);
x_2 = lean_array_mk(x_1);
return x_2;
}
}
static lean_object* _init_l_ZkRV32I_Binary_readELF32ProgramHeaders___closed__2() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l_ZkRV32I_Binary_readELF32ProgramHeaders___closed__1;
x_2 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_readELF32ProgramHeaders(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4) {
_start:
{
lean_object* x_5; uint8_t x_6; 
x_5 = lean_unsigned_to_nat(0u);
x_6 = lean_nat_dec_eq(x_4, x_5);
if (x_6 == 0)
{
lean_object* x_7; lean_object* x_8; lean_object* x_9; 
x_7 = lean_unsigned_to_nat(1u);
x_8 = lean_nat_sub(x_4, x_7);
x_9 = l_ZkRV32I_Binary_parseELF32ProgramHeader(x_1, x_2);
if (lean_obj_tag(x_9) == 0)
{
lean_object* x_10; 
lean_dec(x_8);
x_10 = lean_box(0);
return x_10;
}
else
{
lean_object* x_11; lean_object* x_12; lean_object* x_13; 
x_11 = lean_ctor_get(x_9, 0);
lean_inc(x_11);
lean_dec(x_9);
x_12 = lean_nat_add(x_2, x_3);
x_13 = l_ZkRV32I_Binary_readELF32ProgramHeaders(x_1, x_12, x_3, x_8);
lean_dec(x_8);
lean_dec(x_12);
if (lean_obj_tag(x_13) == 0)
{
lean_object* x_14; 
lean_dec(x_11);
x_14 = lean_box(0);
return x_14;
}
else
{
uint8_t x_15; 
x_15 = !lean_is_exclusive(x_13);
if (x_15 == 0)
{
lean_object* x_16; lean_object* x_17; lean_object* x_18; lean_object* x_19; lean_object* x_20; 
x_16 = lean_ctor_get(x_13, 0);
x_17 = lean_box(0);
x_18 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_18, 0, x_11);
lean_ctor_set(x_18, 1, x_17);
x_19 = lean_array_mk(x_18);
x_20 = l_Array_append___rarg(x_19, x_16);
lean_dec(x_16);
lean_ctor_set(x_13, 0, x_20);
return x_13;
}
else
{
lean_object* x_21; lean_object* x_22; lean_object* x_23; lean_object* x_24; lean_object* x_25; lean_object* x_26; 
x_21 = lean_ctor_get(x_13, 0);
lean_inc(x_21);
lean_dec(x_13);
x_22 = lean_box(0);
x_23 = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(x_23, 0, x_11);
lean_ctor_set(x_23, 1, x_22);
x_24 = lean_array_mk(x_23);
x_25 = l_Array_append___rarg(x_24, x_21);
lean_dec(x_21);
x_26 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_26, 0, x_25);
return x_26;
}
}
}
}
else
{
lean_object* x_27; 
x_27 = l_ZkRV32I_Binary_readELF32ProgramHeaders___closed__2;
return x_27;
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_readELF32ProgramHeaders___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4) {
_start:
{
lean_object* x_5; 
x_5 = l_ZkRV32I_Binary_readELF32ProgramHeaders(x_1, x_2, x_3, x_4);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
lean_dec(x_1);
return x_5;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_parseELF32(lean_object* x_1) {
_start:
{
lean_object* x_2; 
x_2 = l_ZkRV32I_Binary_parseELF32Header(x_1);
if (lean_obj_tag(x_2) == 0)
{
lean_object* x_3; 
lean_dec(x_1);
x_3 = lean_box(0);
return x_3;
}
else
{
lean_object* x_4; lean_object* x_5; lean_object* x_6; lean_object* x_7; lean_object* x_8; 
x_4 = lean_ctor_get(x_2, 0);
lean_inc(x_4);
lean_dec(x_2);
x_5 = lean_ctor_get(x_4, 2);
lean_inc(x_5);
x_6 = lean_ctor_get(x_4, 3);
lean_inc(x_6);
x_7 = lean_ctor_get(x_4, 4);
lean_inc(x_7);
x_8 = l_ZkRV32I_Binary_readELF32ProgramHeaders(x_1, x_5, x_6, x_7);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
if (lean_obj_tag(x_8) == 0)
{
lean_object* x_9; 
lean_dec(x_4);
lean_dec(x_1);
x_9 = lean_box(0);
return x_9;
}
else
{
uint8_t x_10; 
x_10 = !lean_is_exclusive(x_8);
if (x_10 == 0)
{
lean_object* x_11; lean_object* x_12; 
x_11 = lean_ctor_get(x_8, 0);
x_12 = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(x_12, 0, x_4);
lean_ctor_set(x_12, 1, x_11);
lean_ctor_set(x_12, 2, x_1);
lean_ctor_set(x_8, 0, x_12);
return x_8;
}
else
{
lean_object* x_13; lean_object* x_14; lean_object* x_15; 
x_13 = lean_ctor_get(x_8, 0);
lean_inc(x_13);
lean_dec(x_8);
x_14 = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(x_14, 0, x_4);
lean_ctor_set(x_14, 1, x_13);
lean_ctor_set(x_14, 2, x_1);
x_15 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_15, 0, x_14);
return x_15;
}
}
}
}
}
LEAN_EXPORT uint8_t l_ZkRV32I_Binary_ELF32ProgramHeader_isLoadableExecutable(lean_object* x_1) {
_start:
{
lean_object* x_2; lean_object* x_3; uint8_t x_4; 
x_2 = lean_ctor_get(x_1, 0);
x_3 = lean_unsigned_to_nat(1u);
x_4 = lean_nat_dec_eq(x_2, x_3);
if (x_4 == 0)
{
uint8_t x_5; 
x_5 = 0;
return x_5;
}
else
{
lean_object* x_6; lean_object* x_7; lean_object* x_8; uint8_t x_9; 
x_6 = lean_ctor_get(x_1, 5);
x_7 = lean_nat_land(x_6, x_3);
x_8 = lean_unsigned_to_nat(0u);
x_9 = lean_nat_dec_eq(x_7, x_8);
lean_dec(x_7);
if (x_9 == 0)
{
uint8_t x_10; 
x_10 = 1;
return x_10;
}
else
{
uint8_t x_11; 
x_11 = 0;
return x_11;
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_ELF32ProgramHeader_isLoadableExecutable___boxed(lean_object* x_1) {
_start:
{
uint8_t x_2; lean_object* x_3; 
x_2 = l_ZkRV32I_Binary_ELF32ProgramHeader_isLoadableExecutable(x_1);
lean_dec(x_1);
x_3 = lean_box(x_2);
return x_3;
}
}
LEAN_EXPORT uint8_t l_ZkRV32I_Binary_segmentFits(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5, lean_object* x_6) {
_start:
{
lean_object* x_7; lean_object* x_8; uint8_t x_9; 
x_7 = lean_nat_add(x_3, x_4);
x_8 = lean_array_get_size(x_2);
x_9 = lean_nat_dec_le(x_7, x_8);
lean_dec(x_8);
lean_dec(x_7);
if (x_9 == 0)
{
uint8_t x_10; 
x_10 = 0;
return x_10;
}
else
{
uint8_t x_11; 
x_11 = lean_nat_dec_le(x_4, x_6);
if (x_11 == 0)
{
uint8_t x_12; 
x_12 = 0;
return x_12;
}
else
{
lean_object* x_13; lean_object* x_14; uint8_t x_15; 
x_13 = lean_nat_add(x_5, x_6);
x_14 = lean_cstr_to_nat("4294967296");
x_15 = lean_nat_dec_le(x_13, x_14);
lean_dec(x_13);
if (x_15 == 0)
{
uint8_t x_16; 
x_16 = 0;
return x_16;
}
else
{
uint32_t x_17; lean_object* x_18; uint8_t x_19; 
x_17 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
x_18 = lean_uint32_to_nat(x_17);
x_19 = lean_nat_dec_le(x_18, x_5);
if (x_19 == 0)
{
uint8_t x_20; 
lean_dec(x_18);
x_20 = 0;
return x_20;
}
else
{
lean_object* x_21; lean_object* x_22; lean_object* x_23; uint8_t x_24; 
x_21 = lean_nat_sub(x_5, x_18);
lean_dec(x_18);
x_22 = lean_nat_add(x_21, x_6);
lean_dec(x_21);
x_23 = lean_ctor_get(x_1, 0);
x_24 = lean_nat_dec_le(x_22, x_23);
lean_dec(x_22);
return x_24;
}
}
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_segmentFits___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5, lean_object* x_6) {
_start:
{
uint8_t x_7; lean_object* x_8; 
x_7 = l_ZkRV32I_Binary_segmentFits(x_1, x_2, x_3, x_4, x_5, x_6);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
lean_dec(x_1);
x_8 = lean_box(x_7);
return x_8;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_loadSegment___lambda__1(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5, lean_object* x_6, lean_object* x_7) {
_start:
{
uint8_t x_8; 
x_8 = lean_nat_dec_le(x_1, x_7);
if (x_8 == 0)
{
lean_object* x_9; uint8_t x_10; 
x_9 = lean_nat_add(x_1, x_2);
x_10 = lean_nat_dec_le(x_9, x_7);
lean_dec(x_9);
if (x_10 == 0)
{
lean_object* x_11; lean_object* x_12; 
x_11 = lean_ctor_get(x_3, 1);
lean_inc(x_11);
lean_dec(x_3);
x_12 = lean_apply_1(x_11, x_7);
return x_12;
}
else
{
lean_object* x_13; uint8_t x_14; 
x_13 = lean_nat_add(x_1, x_4);
x_14 = lean_nat_dec_lt(x_7, x_13);
lean_dec(x_13);
if (x_14 == 0)
{
lean_object* x_15; lean_object* x_16; 
x_15 = lean_ctor_get(x_3, 1);
lean_inc(x_15);
lean_dec(x_3);
x_16 = lean_apply_1(x_15, x_7);
return x_16;
}
else
{
uint8_t x_17; lean_object* x_18; 
lean_dec(x_7);
lean_dec(x_3);
x_17 = 0;
x_18 = lean_box(x_17);
return x_18;
}
}
}
else
{
lean_object* x_19; uint8_t x_20; 
x_19 = lean_nat_add(x_1, x_2);
x_20 = lean_nat_dec_lt(x_7, x_19);
if (x_20 == 0)
{
uint8_t x_21; 
x_21 = lean_nat_dec_le(x_19, x_7);
lean_dec(x_19);
if (x_21 == 0)
{
lean_object* x_22; lean_object* x_23; 
x_22 = lean_ctor_get(x_3, 1);
lean_inc(x_22);
lean_dec(x_3);
x_23 = lean_apply_1(x_22, x_7);
return x_23;
}
else
{
lean_object* x_24; uint8_t x_25; 
x_24 = lean_nat_add(x_1, x_4);
x_25 = lean_nat_dec_lt(x_7, x_24);
lean_dec(x_24);
if (x_25 == 0)
{
lean_object* x_26; lean_object* x_27; 
x_26 = lean_ctor_get(x_3, 1);
lean_inc(x_26);
lean_dec(x_3);
x_27 = lean_apply_1(x_26, x_7);
return x_27;
}
else
{
uint8_t x_28; lean_object* x_29; 
lean_dec(x_7);
lean_dec(x_3);
x_28 = 0;
x_29 = lean_box(x_28);
return x_29;
}
}
}
else
{
lean_object* x_30; lean_object* x_31; lean_object* x_32; uint8_t x_33; 
lean_dec(x_19);
lean_dec(x_3);
x_30 = lean_nat_add(x_5, x_7);
lean_dec(x_7);
x_31 = lean_nat_sub(x_30, x_1);
lean_dec(x_30);
x_32 = lean_array_get_size(x_6);
x_33 = lean_nat_dec_lt(x_31, x_32);
lean_dec(x_32);
if (x_33 == 0)
{
uint8_t x_34; lean_object* x_35; 
lean_dec(x_31);
x_34 = 0;
x_35 = lean_box(x_34);
return x_35;
}
else
{
lean_object* x_36; 
x_36 = lean_array_fget(x_6, x_31);
lean_dec(x_31);
return x_36;
}
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_loadSegment(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5, lean_object* x_6) {
_start:
{
uint8_t x_7; 
x_7 = l_ZkRV32I_Binary_segmentFits(x_1, x_2, x_3, x_4, x_5, x_6);
if (x_7 == 0)
{
lean_object* x_8; 
lean_dec(x_6);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
lean_dec(x_1);
x_8 = lean_box(0);
return x_8;
}
else
{
uint32_t x_9; lean_object* x_10; lean_object* x_11; lean_object* x_12; lean_object* x_13; uint8_t x_14; 
x_9 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
x_10 = lean_ctor_get(x_1, 0);
lean_inc(x_10);
x_11 = lean_uint32_to_nat(x_9);
x_12 = lean_nat_sub(x_5, x_11);
lean_dec(x_11);
lean_inc(x_1);
x_13 = lean_alloc_closure((void*)(l_ZkRV32I_Binary_loadSegment___lambda__1___boxed), 7, 6);
lean_closure_set(x_13, 0, x_12);
lean_closure_set(x_13, 1, x_4);
lean_closure_set(x_13, 2, x_1);
lean_closure_set(x_13, 3, x_6);
lean_closure_set(x_13, 4, x_3);
lean_closure_set(x_13, 5, x_2);
x_14 = !lean_is_exclusive(x_1);
if (x_14 == 0)
{
lean_object* x_15; lean_object* x_16; lean_object* x_17; 
x_15 = lean_ctor_get(x_1, 1);
lean_dec(x_15);
x_16 = lean_ctor_get(x_1, 0);
lean_dec(x_16);
lean_ctor_set(x_1, 1, x_13);
x_17 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_17, 0, x_1);
return x_17;
}
else
{
lean_object* x_18; lean_object* x_19; 
lean_dec(x_1);
x_18 = lean_alloc_ctor(0, 2, 4);
lean_ctor_set(x_18, 0, x_10);
lean_ctor_set(x_18, 1, x_13);
lean_ctor_set_uint32(x_18, sizeof(void*)*2, x_9);
x_19 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_19, 0, x_18);
return x_19;
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_loadSegment___lambda__1___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5, lean_object* x_6, lean_object* x_7) {
_start:
{
lean_object* x_8; 
x_8 = l_ZkRV32I_Binary_loadSegment___lambda__1(x_1, x_2, x_3, x_4, x_5, x_6, x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_2);
lean_dec(x_1);
return x_8;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_loadSegment___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5, lean_object* x_6) {
_start:
{
lean_object* x_7; 
x_7 = l_ZkRV32I_Binary_loadSegment(x_1, x_2, x_3, x_4, x_5, x_6);
lean_dec(x_5);
return x_7;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_loadELF32Segments(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
if (lean_obj_tag(x_3) == 0)
{
lean_object* x_4; 
lean_dec(x_2);
x_4 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_4, 0, x_1);
return x_4;
}
else
{
lean_object* x_5; lean_object* x_6; lean_object* x_7; lean_object* x_8; uint8_t x_9; 
x_5 = lean_ctor_get(x_3, 0);
lean_inc(x_5);
x_6 = lean_ctor_get(x_3, 1);
lean_inc(x_6);
lean_dec(x_3);
x_7 = lean_ctor_get(x_5, 0);
lean_inc(x_7);
x_8 = lean_unsigned_to_nat(1u);
x_9 = lean_nat_dec_eq(x_7, x_8);
lean_dec(x_7);
if (x_9 == 0)
{
lean_dec(x_5);
x_3 = x_6;
goto _start;
}
else
{
lean_object* x_11; lean_object* x_12; lean_object* x_13; lean_object* x_14; lean_object* x_15; lean_object* x_16; 
x_11 = lean_ctor_get(x_2, 2);
lean_inc(x_11);
x_12 = lean_ctor_get(x_5, 1);
lean_inc(x_12);
x_13 = lean_ctor_get(x_5, 3);
lean_inc(x_13);
x_14 = lean_ctor_get(x_5, 2);
lean_inc(x_14);
x_15 = lean_ctor_get(x_5, 4);
lean_inc(x_15);
lean_dec(x_5);
x_16 = l_ZkRV32I_Binary_loadSegment(x_1, x_11, x_12, x_13, x_14, x_15);
lean_dec(x_14);
if (lean_obj_tag(x_16) == 0)
{
lean_object* x_17; 
lean_dec(x_6);
lean_dec(x_2);
x_17 = lean_box(0);
return x_17;
}
else
{
lean_object* x_18; 
x_18 = lean_ctor_get(x_16, 0);
lean_inc(x_18);
lean_dec(x_16);
x_1 = x_18;
x_3 = x_6;
goto _start;
}
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_ELF32Image_loadMemory(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; 
x_3 = lean_ctor_get(x_1, 1);
lean_inc(x_3);
x_4 = lean_array_to_list(x_3);
x_5 = l_ZkRV32I_Binary_loadELF32Segments(x_2, x_1, x_4);
return x_5;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_fetch32(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; uint8_t x_6; 
x_3 = lean_unsigned_to_nat(4u);
x_4 = lean_nat_mod(x_2, x_3);
x_5 = lean_unsigned_to_nat(0u);
x_6 = lean_nat_dec_eq(x_4, x_5);
lean_dec(x_4);
if (x_6 == 0)
{
lean_object* x_7; 
lean_dec(x_1);
x_7 = lean_box(0);
return x_7;
}
else
{
uint8_t x_8; 
x_8 = l_ZkRV32I_Memory_validRange(x_1, x_2, x_3, x_3);
if (x_8 == 0)
{
lean_object* x_9; 
lean_dec(x_1);
x_9 = lean_box(0);
return x_9;
}
else
{
uint32_t x_10; lean_object* x_11; lean_object* x_12; lean_object* x_13; lean_object* x_14; uint8_t x_15; lean_object* x_16; lean_object* x_17; lean_object* x_18; lean_object* x_19; uint8_t x_20; lean_object* x_21; lean_object* x_22; lean_object* x_23; lean_object* x_24; lean_object* x_25; lean_object* x_26; lean_object* x_27; uint8_t x_28; lean_object* x_29; lean_object* x_30; lean_object* x_31; lean_object* x_32; lean_object* x_33; lean_object* x_34; lean_object* x_35; uint8_t x_36; lean_object* x_37; lean_object* x_38; lean_object* x_39; lean_object* x_40; lean_object* x_41; lean_object* x_42; lean_object* x_43; 
x_10 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
x_11 = lean_uint32_to_nat(x_10);
x_12 = lean_nat_sub(x_2, x_11);
lean_dec(x_11);
x_13 = lean_ctor_get(x_1, 1);
lean_inc(x_13);
lean_dec(x_1);
lean_inc(x_13);
lean_inc(x_12);
x_14 = lean_apply_1(x_13, x_12);
x_15 = lean_unbox(x_14);
lean_dec(x_14);
x_16 = lean_uint8_to_nat(x_15);
x_17 = lean_unsigned_to_nat(1u);
x_18 = lean_nat_add(x_12, x_17);
lean_inc(x_13);
x_19 = lean_apply_1(x_13, x_18);
x_20 = lean_unbox(x_19);
lean_dec(x_19);
x_21 = lean_uint8_to_nat(x_20);
x_22 = lean_unsigned_to_nat(256u);
x_23 = lean_nat_mul(x_21, x_22);
lean_dec(x_21);
x_24 = lean_nat_add(x_16, x_23);
lean_dec(x_23);
lean_dec(x_16);
x_25 = lean_unsigned_to_nat(2u);
x_26 = lean_nat_add(x_12, x_25);
lean_inc(x_13);
x_27 = lean_apply_1(x_13, x_26);
x_28 = lean_unbox(x_27);
lean_dec(x_27);
x_29 = lean_uint8_to_nat(x_28);
x_30 = lean_unsigned_to_nat(65536u);
x_31 = lean_nat_mul(x_29, x_30);
lean_dec(x_29);
x_32 = lean_nat_add(x_24, x_31);
lean_dec(x_31);
lean_dec(x_24);
x_33 = lean_unsigned_to_nat(3u);
x_34 = lean_nat_add(x_12, x_33);
lean_dec(x_12);
x_35 = lean_apply_1(x_13, x_34);
x_36 = lean_unbox(x_35);
lean_dec(x_35);
x_37 = lean_uint8_to_nat(x_36);
x_38 = lean_unsigned_to_nat(16777216u);
x_39 = lean_nat_mul(x_37, x_38);
lean_dec(x_37);
x_40 = lean_nat_add(x_32, x_39);
lean_dec(x_39);
lean_dec(x_32);
x_41 = lean_unsigned_to_nat(32u);
x_42 = l_BitVec_ofNat(x_41, x_40);
lean_dec(x_40);
x_43 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_43, 0, x_42);
return x_43;
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_fetch32___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = l_ZkRV32I_Binary_fetch32(x_1, x_2);
lean_dec(x_2);
return x_3;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_decodeBitVec32(lean_object* x_1) {
_start:
{
uint32_t x_2; lean_object* x_3; 
x_2 = lean_uint32_of_nat(x_1);
x_3 = l_ZkRV32I_decode(x_2);
return x_3;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_decodeBitVec32___boxed(lean_object* x_1) {
_start:
{
lean_object* x_2; 
x_2 = l_ZkRV32I_Binary_decodeBitVec32(x_1);
lean_dec(x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_fetchDecode(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = l_ZkRV32I_Binary_fetch32(x_1, x_2);
if (lean_obj_tag(x_3) == 0)
{
lean_object* x_4; 
x_4 = lean_box(0);
return x_4;
}
else
{
uint8_t x_5; 
x_5 = !lean_is_exclusive(x_3);
if (x_5 == 0)
{
lean_object* x_6; lean_object* x_7; 
x_6 = lean_ctor_get(x_3, 0);
x_7 = l_ZkRV32I_Binary_decodeBitVec32(x_6);
lean_dec(x_6);
lean_ctor_set(x_3, 0, x_7);
return x_3;
}
else
{
lean_object* x_8; lean_object* x_9; lean_object* x_10; 
x_8 = lean_ctor_get(x_3, 0);
lean_inc(x_8);
lean_dec(x_3);
x_9 = l_ZkRV32I_Binary_decodeBitVec32(x_8);
lean_dec(x_8);
x_10 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_10, 0, x_9);
return x_10;
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_fetchDecode___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; 
x_3 = l_ZkRV32I_Binary_fetchDecode(x_1, x_2);
lean_dec(x_2);
return x_3;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Binary_binaryStep(lean_object* x_1) {
_start:
{
lean_object* x_2; uint32_t x_3; lean_object* x_4; lean_object* x_5; 
x_2 = lean_ctor_get(x_1, 1);
lean_inc(x_2);
x_3 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
x_4 = lean_uint32_to_nat(x_3);
x_5 = l_ZkRV32I_Binary_fetch32(x_2, x_4);
lean_dec(x_4);
if (lean_obj_tag(x_5) == 0)
{
lean_object* x_6; 
lean_dec(x_1);
x_6 = lean_box(0);
return x_6;
}
else
{
lean_object* x_7; lean_object* x_8; 
x_7 = lean_ctor_get(x_5, 0);
lean_inc(x_7);
lean_dec(x_5);
x_8 = l_ZkRV32I_Binary_decodeBitVec32(x_7);
lean_dec(x_7);
if (lean_obj_tag(x_8) == 0)
{
lean_object* x_9; 
lean_dec(x_8);
lean_dec(x_1);
x_9 = lean_box(0);
return x_9;
}
else
{
lean_object* x_10; lean_object* x_11; 
x_10 = lean_ctor_get(x_8, 0);
lean_inc(x_10);
lean_dec(x_8);
x_11 = l_ZkRV32I_step(x_1, x_10);
return x_11;
}
}
}
}
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__Except_toBool_match__1_splitter___rarg(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
if (lean_obj_tag(x_1) == 0)
{
lean_object* x_4; lean_object* x_5; 
lean_dec(x_2);
x_4 = lean_ctor_get(x_1, 0);
lean_inc(x_4);
lean_dec(x_1);
x_5 = lean_apply_1(x_3, x_4);
return x_5;
}
else
{
lean_object* x_6; lean_object* x_7; 
lean_dec(x_3);
x_6 = lean_ctor_get(x_1, 0);
lean_inc(x_6);
lean_dec(x_1);
x_7 = lean_apply_1(x_2, x_6);
return x_7;
}
}
}
LEAN_EXPORT lean_object* l___private_ZkRV32I_Binary_0__Except_toBool_match__1_splitter(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; 
x_4 = lean_alloc_closure((void*)(l___private_ZkRV32I_Binary_0__Except_toBool_match__1_splitter___rarg), 3, 0);
return x_4;
}
}
lean_object* initialize_Init(uint8_t builtin, lean_object*);
lean_object* initialize_ZkRV32I_Trace(uint8_t builtin, lean_object*);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_ZkRV32I_Binary(uint8_t builtin, lean_object* w) {
lean_object * res;
if (_G_initialized) return lean_io_result_mk_ok(lean_box(0));
_G_initialized = true;
res = initialize_Init(builtin, lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_ZkRV32I_Trace(builtin, lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__1 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__1();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__1);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__2 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__2();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__2);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__3 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__3();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__3);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__4 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__4();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__4);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__5 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__5();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__5);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__6 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__6();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__6);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__7 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__7();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__7);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__8 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__8();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__8);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__9 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__9();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__9);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__10 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__10();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__10);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__11 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__11();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__11);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__12 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__12();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__12);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__13 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__13();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__13);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__14 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__14();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__14);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__15 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__15();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__15);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__16 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__16();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__16);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__17 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__17();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__17);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__18 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__18();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__18);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__19 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__19();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__19);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__20 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__20();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__20);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__21 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__21();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__21);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__22 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__22();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__22);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__23 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__23();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__23);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__24 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__24();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__24);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__25 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__25();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__25);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__26 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__26();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__26);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__27 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__27();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__27);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__28 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__28();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__28);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__29 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__29();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__29);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__30 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__30();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32Header____x40_ZkRV32I_Binary___hyg_627____closed__30);
l_ZkRV32I_Binary_instReprELF32Header___closed__1 = _init_l_ZkRV32I_Binary_instReprELF32Header___closed__1();
lean_mark_persistent(l_ZkRV32I_Binary_instReprELF32Header___closed__1);
l_ZkRV32I_Binary_instReprELF32Header = _init_l_ZkRV32I_Binary_instReprELF32Header();
lean_mark_persistent(l_ZkRV32I_Binary_instReprELF32Header);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__1 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__1();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__1);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__2 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__2();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__2);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__3 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__3();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__3);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__4 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__4();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__4);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__5 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__5();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__5);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__6 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__6();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__6);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__7 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__7();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__7);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__8 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__8();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__8);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__9 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__9();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__9);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__10 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__10();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__10);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__11 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__11();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__11);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__12 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__12();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__12);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__13 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__13();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__13);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__14 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__14();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__14);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__15 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__15();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__15);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__16 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__16();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__16);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__17 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__17();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__17);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__18 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__18();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__18);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__19 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__19();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__19);
l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__20 = _init_l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__20();
lean_mark_persistent(l___private_ZkRV32I_Binary_0__ZkRV32I_Binary_reprELF32ProgramHeader____x40_ZkRV32I_Binary___hyg_1275____closed__20);
l_ZkRV32I_Binary_instReprELF32ProgramHeader___closed__1 = _init_l_ZkRV32I_Binary_instReprELF32ProgramHeader___closed__1();
lean_mark_persistent(l_ZkRV32I_Binary_instReprELF32ProgramHeader___closed__1);
l_ZkRV32I_Binary_instReprELF32ProgramHeader = _init_l_ZkRV32I_Binary_instReprELF32ProgramHeader();
lean_mark_persistent(l_ZkRV32I_Binary_instReprELF32ProgramHeader);
l_ZkRV32I_Binary_parseELF32Header___closed__1 = _init_l_ZkRV32I_Binary_parseELF32Header___closed__1();
lean_mark_persistent(l_ZkRV32I_Binary_parseELF32Header___closed__1);
l_ZkRV32I_Binary_parseELF32Header___closed__2 = _init_l_ZkRV32I_Binary_parseELF32Header___closed__2();
lean_mark_persistent(l_ZkRV32I_Binary_parseELF32Header___closed__2);
l_ZkRV32I_Binary_parseELF32Header___closed__3 = _init_l_ZkRV32I_Binary_parseELF32Header___closed__3();
lean_mark_persistent(l_ZkRV32I_Binary_parseELF32Header___closed__3);
l_ZkRV32I_Binary_parseELF32Header___closed__4 = _init_l_ZkRV32I_Binary_parseELF32Header___closed__4();
lean_mark_persistent(l_ZkRV32I_Binary_parseELF32Header___closed__4);
l_ZkRV32I_Binary_parseELF32Header___closed__5 = _init_l_ZkRV32I_Binary_parseELF32Header___closed__5();
lean_mark_persistent(l_ZkRV32I_Binary_parseELF32Header___closed__5);
l_ZkRV32I_Binary_readELF32ProgramHeaders___closed__1 = _init_l_ZkRV32I_Binary_readELF32ProgramHeaders___closed__1();
lean_mark_persistent(l_ZkRV32I_Binary_readELF32ProgramHeaders___closed__1);
l_ZkRV32I_Binary_readELF32ProgramHeaders___closed__2 = _init_l_ZkRV32I_Binary_readELF32ProgramHeaders___closed__2();
lean_mark_persistent(l_ZkRV32I_Binary_readELF32ProgramHeaders___closed__2);
return lean_io_result_mk_ok(lean_box(0));
}
#ifdef __cplusplus
}
#endif
