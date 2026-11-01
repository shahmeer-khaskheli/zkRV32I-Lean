// Lean compiler output
// Module: ZkRV32I.Base
// Imports: Init
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
static lean_object* l_ZkRV32I_Word32_signed___closed__1;
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_validRange___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint32_t l_ZkRV32I_Word32_add(uint32_t, uint32_t);
LEAN_EXPORT lean_object* l_ZkRV32I_Word32_add___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Word32_signed(uint32_t);
LEAN_EXPORT uint8_t l_ZkRV32I_Memory_validRange(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Word32_ofNat___boxed(lean_object*);
lean_object* lean_uint32_to_nat(uint32_t);
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_storeBytes___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_littleEndianValue___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_List_foldl___at_ZkRV32I_Memory_littleEndianValue___spec__1___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_x0___boxed(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_write(lean_object*, lean_object*, uint32_t);
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_zeroed___elambda__1___boxed(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_storeBytes(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Word32_sub___boxed(lean_object*, lean_object*);
lean_object* lean_nat_to_int(lean_object*);
uint32_t lean_uint32_of_nat(lean_object*);
lean_object* lean_nat_div(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_load(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Word32_signExtend___boxed(lean_object*, lean_object*);
lean_object* l_List_range(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_write___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint32_t l_ZkRV32I_RegisterFile_zeroed___elambda__1(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_zeroed;
LEAN_EXPORT lean_object* l_List_foldl___at_ZkRV32I_Memory_littleEndianValue___spec__1(lean_object*, lean_object*, lean_object*, lean_object*);
static lean_object* l_ZkRV32I_RegisterFile_zeroed___closed__1;
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_empty(uint32_t, lean_object*);
LEAN_EXPORT uint32_t l_ZkRV32I_Word32_signExtend(lean_object*, lean_object*);
static lean_object* l_ZkRV32I_Memory_empty___closed__1;
lean_object* lean_int_sub(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_empty___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint32_t l_ZkRV32I_Word32_zero;
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_write___elambda__1(lean_object*, lean_object*, uint32_t, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_store(lean_object*, lean_object*, lean_object*, lean_object*, uint32_t);
uint32_t lean_uint32_sub(uint32_t, uint32_t);
lean_object* lean_nat_pow(lean_object*, lean_object*);
uint8_t lean_nat_dec_eq(lean_object*, lean_object*);
uint8_t lean_nat_dec_lt(lean_object*, lean_object*);
lean_object* lean_nat_mod(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_empty___elambda__1___boxed(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Word32_signed___boxed(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_read___boxed__const__1;
uint8_t lean_int_dec_lt(lean_object*, lean_object*);
lean_object* lean_nat_sub(lean_object*, lean_object*);
lean_object* lean_nat_mul(lean_object*, lean_object*);
uint8_t lean_uint8_of_nat(lean_object*);
LEAN_EXPORT uint8_t l_ZkRV32I_Memory_empty___elambda__1(lean_object*);
lean_object* lean_uint8_to_nat(uint8_t);
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_read(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_load___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
uint32_t lean_uint32_add(uint32_t, uint32_t);
LEAN_EXPORT uint32_t l_ZkRV32I_Word32_ofNat(lean_object*);
LEAN_EXPORT uint32_t l_ZkRV32I_RegisterFile_x0(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Word32_signedLessThan___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_store___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
uint8_t lean_nat_dec_le(lean_object*, lean_object*);
LEAN_EXPORT uint32_t l_ZkRV32I_Word32_sub(uint32_t, uint32_t);
lean_object* lean_nat_add(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_write___elambda__1___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t l_ZkRV32I_Word32_signedLessThan(uint32_t, uint32_t);
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_littleEndianValue(lean_object*, lean_object*, lean_object*);
static uint32_t _init_l_ZkRV32I_Word32_zero() {
_start:
{
uint32_t x_1; 
x_1 = 0;
return x_1;
}
}
LEAN_EXPORT uint32_t l_ZkRV32I_Word32_ofNat(lean_object* x_1) {
_start:
{
uint32_t x_2; 
x_2 = lean_uint32_of_nat(x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Word32_ofNat___boxed(lean_object* x_1) {
_start:
{
uint32_t x_2; lean_object* x_3; 
x_2 = l_ZkRV32I_Word32_ofNat(x_1);
lean_dec(x_1);
x_3 = lean_box_uint32(x_2);
return x_3;
}
}
static lean_object* _init_l_ZkRV32I_Word32_signed___closed__1() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_cstr_to_nat("4294967296");
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Word32_signed(uint32_t x_1) {
_start:
{
lean_object* x_2; lean_object* x_3; uint8_t x_4; 
x_2 = lean_uint32_to_nat(x_1);
x_3 = lean_unsigned_to_nat(2147483648u);
x_4 = lean_nat_dec_lt(x_2, x_3);
if (x_4 == 0)
{
lean_object* x_5; lean_object* x_6; lean_object* x_7; 
x_5 = lean_nat_to_int(x_2);
x_6 = l_ZkRV32I_Word32_signed___closed__1;
x_7 = lean_int_sub(x_5, x_6);
lean_dec(x_5);
return x_7;
}
else
{
lean_object* x_8; 
x_8 = lean_nat_to_int(x_2);
return x_8;
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Word32_signed___boxed(lean_object* x_1) {
_start:
{
uint32_t x_2; lean_object* x_3; 
x_2 = lean_unbox_uint32(x_1);
lean_dec(x_1);
x_3 = l_ZkRV32I_Word32_signed(x_2);
return x_3;
}
}
LEAN_EXPORT uint32_t l_ZkRV32I_Word32_signExtend(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; lean_object* x_6; lean_object* x_7; lean_object* x_8; uint8_t x_9; 
x_3 = lean_unsigned_to_nat(1u);
x_4 = lean_nat_sub(x_2, x_3);
x_5 = lean_unsigned_to_nat(2u);
x_6 = lean_nat_pow(x_5, x_4);
lean_dec(x_4);
x_7 = lean_nat_pow(x_5, x_2);
x_8 = lean_nat_mod(x_1, x_7);
x_9 = lean_nat_dec_le(x_6, x_8);
lean_dec(x_6);
if (x_9 == 0)
{
uint32_t x_10; 
lean_dec(x_7);
x_10 = lean_uint32_of_nat(x_8);
lean_dec(x_8);
return x_10;
}
else
{
lean_object* x_11; lean_object* x_12; lean_object* x_13; uint32_t x_14; 
x_11 = lean_cstr_to_nat("4294967296");
x_12 = lean_nat_add(x_8, x_11);
lean_dec(x_8);
x_13 = lean_nat_sub(x_12, x_7);
lean_dec(x_7);
lean_dec(x_12);
x_14 = lean_uint32_of_nat(x_13);
lean_dec(x_13);
return x_14;
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Word32_signExtend___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint32_t x_3; lean_object* x_4; 
x_3 = l_ZkRV32I_Word32_signExtend(x_1, x_2);
lean_dec(x_2);
lean_dec(x_1);
x_4 = lean_box_uint32(x_3);
return x_4;
}
}
LEAN_EXPORT uint32_t l_ZkRV32I_Word32_add(uint32_t x_1, uint32_t x_2) {
_start:
{
uint32_t x_3; 
x_3 = lean_uint32_add(x_1, x_2);
return x_3;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Word32_add___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint32_t x_3; uint32_t x_4; uint32_t x_5; lean_object* x_6; 
x_3 = lean_unbox_uint32(x_1);
lean_dec(x_1);
x_4 = lean_unbox_uint32(x_2);
lean_dec(x_2);
x_5 = l_ZkRV32I_Word32_add(x_3, x_4);
x_6 = lean_box_uint32(x_5);
return x_6;
}
}
LEAN_EXPORT uint32_t l_ZkRV32I_Word32_sub(uint32_t x_1, uint32_t x_2) {
_start:
{
uint32_t x_3; 
x_3 = lean_uint32_sub(x_1, x_2);
return x_3;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Word32_sub___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint32_t x_3; uint32_t x_4; uint32_t x_5; lean_object* x_6; 
x_3 = lean_unbox_uint32(x_1);
lean_dec(x_1);
x_4 = lean_unbox_uint32(x_2);
lean_dec(x_2);
x_5 = l_ZkRV32I_Word32_sub(x_3, x_4);
x_6 = lean_box_uint32(x_5);
return x_6;
}
}
LEAN_EXPORT uint8_t l_ZkRV32I_Word32_signedLessThan(uint32_t x_1, uint32_t x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; uint8_t x_5; 
x_3 = l_ZkRV32I_Word32_signed(x_1);
x_4 = l_ZkRV32I_Word32_signed(x_2);
x_5 = lean_int_dec_lt(x_3, x_4);
lean_dec(x_4);
lean_dec(x_3);
return x_5;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Word32_signedLessThan___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint32_t x_3; uint32_t x_4; uint8_t x_5; lean_object* x_6; 
x_3 = lean_unbox_uint32(x_1);
lean_dec(x_1);
x_4 = lean_unbox_uint32(x_2);
lean_dec(x_2);
x_5 = l_ZkRV32I_Word32_signedLessThan(x_3, x_4);
x_6 = lean_box(x_5);
return x_6;
}
}
LEAN_EXPORT uint32_t l_ZkRV32I_RegisterFile_zeroed___elambda__1(lean_object* x_1) {
_start:
{
uint32_t x_2; 
x_2 = 0;
return x_2;
}
}
static lean_object* _init_l_ZkRV32I_RegisterFile_zeroed___closed__1() {
_start:
{
lean_object* x_1; 
x_1 = lean_alloc_closure((void*)(l_ZkRV32I_RegisterFile_zeroed___elambda__1___boxed), 1, 0);
return x_1;
}
}
static lean_object* _init_l_ZkRV32I_RegisterFile_zeroed() {
_start:
{
lean_object* x_1; 
x_1 = l_ZkRV32I_RegisterFile_zeroed___closed__1;
return x_1;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_zeroed___elambda__1___boxed(lean_object* x_1) {
_start:
{
uint32_t x_2; lean_object* x_3; 
x_2 = l_ZkRV32I_RegisterFile_zeroed___elambda__1(x_1);
lean_dec(x_1);
x_3 = lean_box_uint32(x_2);
return x_3;
}
}
static lean_object* _init_l_ZkRV32I_RegisterFile_read___boxed__const__1() {
_start:
{
uint32_t x_1; lean_object* x_2; 
x_1 = 0;
x_2 = lean_box_uint32(x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_read(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; uint8_t x_4; 
x_3 = lean_unsigned_to_nat(0u);
x_4 = lean_nat_dec_eq(x_2, x_3);
if (x_4 == 0)
{
lean_object* x_5; 
x_5 = lean_apply_1(x_1, x_2);
return x_5;
}
else
{
lean_object* x_6; 
lean_dec(x_2);
lean_dec(x_1);
x_6 = l_ZkRV32I_RegisterFile_read___boxed__const__1;
return x_6;
}
}
}
LEAN_EXPORT uint32_t l_ZkRV32I_RegisterFile_x0(lean_object* x_1) {
_start:
{
uint32_t x_2; 
x_2 = 0;
return x_2;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_x0___boxed(lean_object* x_1) {
_start:
{
uint32_t x_2; lean_object* x_3; 
x_2 = l_ZkRV32I_RegisterFile_x0(x_1);
lean_dec(x_1);
x_3 = lean_box_uint32(x_2);
return x_3;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_write___elambda__1(lean_object* x_1, lean_object* x_2, uint32_t x_3, lean_object* x_4) {
_start:
{
uint8_t x_5; 
x_5 = lean_nat_dec_eq(x_4, x_2);
if (x_5 == 0)
{
lean_object* x_6; 
x_6 = lean_apply_1(x_1, x_4);
return x_6;
}
else
{
lean_object* x_7; 
lean_dec(x_4);
lean_dec(x_1);
x_7 = lean_box_uint32(x_3);
return x_7;
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_write(lean_object* x_1, lean_object* x_2, uint32_t x_3) {
_start:
{
lean_object* x_4; uint8_t x_5; 
x_4 = lean_unsigned_to_nat(0u);
x_5 = lean_nat_dec_eq(x_2, x_4);
if (x_5 == 0)
{
lean_object* x_6; lean_object* x_7; 
x_6 = lean_box_uint32(x_3);
x_7 = lean_alloc_closure((void*)(l_ZkRV32I_RegisterFile_write___elambda__1___boxed), 4, 3);
lean_closure_set(x_7, 0, x_1);
lean_closure_set(x_7, 1, x_2);
lean_closure_set(x_7, 2, x_6);
return x_7;
}
else
{
lean_dec(x_2);
return x_1;
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_write___elambda__1___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4) {
_start:
{
uint32_t x_5; lean_object* x_6; 
x_5 = lean_unbox_uint32(x_3);
lean_dec(x_3);
x_6 = l_ZkRV32I_RegisterFile_write___elambda__1(x_1, x_2, x_5, x_4);
lean_dec(x_2);
return x_6;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_RegisterFile_write___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
uint32_t x_4; lean_object* x_5; 
x_4 = lean_unbox_uint32(x_3);
lean_dec(x_3);
x_5 = l_ZkRV32I_RegisterFile_write(x_1, x_2, x_4);
return x_5;
}
}
LEAN_EXPORT uint8_t l_ZkRV32I_Memory_empty___elambda__1(lean_object* x_1) {
_start:
{
uint8_t x_2; 
x_2 = 0;
return x_2;
}
}
static lean_object* _init_l_ZkRV32I_Memory_empty___closed__1() {
_start:
{
lean_object* x_1; 
x_1 = lean_alloc_closure((void*)(l_ZkRV32I_Memory_empty___elambda__1___boxed), 1, 0);
return x_1;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_empty(uint32_t x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; 
x_3 = l_ZkRV32I_Memory_empty___closed__1;
x_4 = lean_alloc_ctor(0, 2, 4);
lean_ctor_set(x_4, 0, x_2);
lean_ctor_set(x_4, 1, x_3);
lean_ctor_set_uint32(x_4, sizeof(void*)*2, x_1);
return x_4;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_empty___elambda__1___boxed(lean_object* x_1) {
_start:
{
uint8_t x_2; lean_object* x_3; 
x_2 = l_ZkRV32I_Memory_empty___elambda__1(x_1);
lean_dec(x_1);
x_3 = lean_box(x_2);
return x_3;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_empty___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint32_t x_3; lean_object* x_4; 
x_3 = lean_unbox_uint32(x_1);
lean_dec(x_1);
x_4 = l_ZkRV32I_Memory_empty(x_3, x_2);
return x_4;
}
}
LEAN_EXPORT uint8_t l_ZkRV32I_Memory_validRange(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4) {
_start:
{
uint32_t x_5; lean_object* x_6; lean_object* x_7; lean_object* x_24; uint8_t x_25; 
x_5 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
x_6 = lean_uint32_to_nat(x_5);
x_24 = lean_unsigned_to_nat(1u);
x_25 = lean_nat_dec_lt(x_24, x_4);
if (x_25 == 0)
{
lean_object* x_26; 
x_26 = lean_box(0);
x_7 = x_26;
goto block_23;
}
else
{
lean_object* x_27; lean_object* x_28; uint8_t x_29; 
x_27 = lean_nat_mod(x_2, x_4);
x_28 = lean_unsigned_to_nat(0u);
x_29 = lean_nat_dec_eq(x_27, x_28);
lean_dec(x_27);
if (x_29 == 0)
{
uint8_t x_30; 
lean_dec(x_6);
x_30 = 0;
return x_30;
}
else
{
lean_object* x_31; 
x_31 = lean_box(0);
x_7 = x_31;
goto block_23;
}
}
block_23:
{
lean_object* x_8; uint8_t x_9; 
lean_dec(x_7);
x_8 = lean_unsigned_to_nat(0u);
x_9 = lean_nat_dec_eq(x_3, x_8);
if (x_9 == 0)
{
uint8_t x_10; 
x_10 = lean_nat_dec_lt(x_2, x_6);
if (x_10 == 0)
{
lean_object* x_11; lean_object* x_12; lean_object* x_13; lean_object* x_14; uint8_t x_15; 
x_11 = lean_unsigned_to_nat(1u);
x_12 = lean_nat_sub(x_3, x_11);
x_13 = lean_nat_add(x_2, x_12);
lean_dec(x_12);
x_14 = lean_cstr_to_nat("4294967296");
x_15 = lean_nat_dec_le(x_14, x_13);
lean_dec(x_13);
if (x_15 == 0)
{
lean_object* x_16; lean_object* x_17; lean_object* x_18; uint8_t x_19; 
x_16 = lean_nat_sub(x_2, x_6);
lean_dec(x_6);
x_17 = lean_nat_add(x_16, x_3);
lean_dec(x_16);
x_18 = lean_ctor_get(x_1, 0);
x_19 = lean_nat_dec_le(x_17, x_18);
lean_dec(x_17);
return x_19;
}
else
{
uint8_t x_20; 
lean_dec(x_6);
x_20 = 0;
return x_20;
}
}
else
{
uint8_t x_21; 
lean_dec(x_6);
x_21 = 0;
return x_21;
}
}
else
{
uint8_t x_22; 
lean_dec(x_6);
x_22 = 0;
return x_22;
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_validRange___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4) {
_start:
{
uint8_t x_5; lean_object* x_6; 
x_5 = l_ZkRV32I_Memory_validRange(x_1, x_2, x_3, x_4);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
lean_dec(x_1);
x_6 = lean_box(x_5);
return x_6;
}
}
LEAN_EXPORT lean_object* l_List_foldl___at_ZkRV32I_Memory_littleEndianValue___spec__1(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4) {
_start:
{
if (lean_obj_tag(x_4) == 0)
{
lean_dec(x_1);
return x_3;
}
else
{
lean_object* x_5; lean_object* x_6; lean_object* x_7; lean_object* x_8; lean_object* x_9; uint8_t x_10; lean_object* x_11; lean_object* x_12; lean_object* x_13; lean_object* x_14; lean_object* x_15; 
x_5 = lean_ctor_get(x_4, 0);
x_6 = lean_ctor_get(x_4, 1);
x_7 = lean_ctor_get(x_1, 1);
lean_inc(x_7);
x_8 = lean_nat_add(x_2, x_5);
x_9 = lean_apply_1(x_7, x_8);
x_10 = lean_unbox(x_9);
lean_dec(x_9);
x_11 = lean_uint8_to_nat(x_10);
x_12 = lean_unsigned_to_nat(256u);
x_13 = lean_nat_pow(x_12, x_5);
x_14 = lean_nat_mul(x_11, x_13);
lean_dec(x_13);
lean_dec(x_11);
x_15 = lean_nat_add(x_3, x_14);
lean_dec(x_14);
lean_dec(x_3);
x_3 = x_15;
x_4 = x_6;
goto _start;
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_littleEndianValue(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; lean_object* x_5; lean_object* x_6; 
x_4 = l_List_range(x_3);
x_5 = lean_unsigned_to_nat(0u);
x_6 = l_List_foldl___at_ZkRV32I_Memory_littleEndianValue___spec__1(x_1, x_2, x_5, x_4);
lean_dec(x_4);
return x_6;
}
}
LEAN_EXPORT lean_object* l_List_foldl___at_ZkRV32I_Memory_littleEndianValue___spec__1___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4) {
_start:
{
lean_object* x_5; 
x_5 = l_List_foldl___at_ZkRV32I_Memory_littleEndianValue___spec__1(x_1, x_2, x_3, x_4);
lean_dec(x_4);
lean_dec(x_2);
return x_5;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_littleEndianValue___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; 
x_4 = l_ZkRV32I_Memory_littleEndianValue(x_1, x_2, x_3);
lean_dec(x_2);
return x_4;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_load(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4) {
_start:
{
uint8_t x_5; 
x_5 = l_ZkRV32I_Memory_validRange(x_1, x_2, x_3, x_4);
if (x_5 == 0)
{
lean_object* x_6; 
lean_dec(x_3);
lean_dec(x_1);
x_6 = lean_box(0);
return x_6;
}
else
{
uint32_t x_7; lean_object* x_8; lean_object* x_9; lean_object* x_10; uint32_t x_11; lean_object* x_12; lean_object* x_13; 
x_7 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
x_8 = lean_uint32_to_nat(x_7);
x_9 = lean_nat_sub(x_2, x_8);
lean_dec(x_8);
x_10 = l_ZkRV32I_Memory_littleEndianValue(x_1, x_9, x_3);
lean_dec(x_9);
x_11 = lean_uint32_of_nat(x_10);
lean_dec(x_10);
x_12 = lean_box_uint32(x_11);
x_13 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_13, 0, x_12);
return x_13;
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_load___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4) {
_start:
{
lean_object* x_5; 
x_5 = l_ZkRV32I_Memory_load(x_1, x_2, x_3, x_4);
lean_dec(x_4);
lean_dec(x_2);
return x_5;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_storeBytes(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5) {
_start:
{
uint8_t x_6; 
x_6 = lean_nat_dec_le(x_2, x_5);
if (x_6 == 0)
{
lean_object* x_7; lean_object* x_8; 
x_7 = lean_ctor_get(x_1, 1);
lean_inc(x_7);
lean_dec(x_1);
x_8 = lean_apply_1(x_7, x_5);
return x_8;
}
else
{
lean_object* x_9; uint8_t x_10; 
x_9 = lean_nat_add(x_2, x_4);
x_10 = lean_nat_dec_lt(x_5, x_9);
lean_dec(x_9);
if (x_10 == 0)
{
lean_object* x_11; lean_object* x_12; 
x_11 = lean_ctor_get(x_1, 1);
lean_inc(x_11);
lean_dec(x_1);
x_12 = lean_apply_1(x_11, x_5);
return x_12;
}
else
{
lean_object* x_13; lean_object* x_14; lean_object* x_15; lean_object* x_16; lean_object* x_17; uint8_t x_18; lean_object* x_19; 
lean_dec(x_1);
x_13 = lean_nat_sub(x_5, x_2);
lean_dec(x_5);
x_14 = lean_unsigned_to_nat(256u);
x_15 = lean_nat_pow(x_14, x_13);
lean_dec(x_13);
x_16 = lean_nat_div(x_3, x_15);
lean_dec(x_15);
x_17 = lean_nat_mod(x_16, x_14);
lean_dec(x_16);
x_18 = lean_uint8_of_nat(x_17);
lean_dec(x_17);
x_19 = lean_box(x_18);
return x_19;
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_storeBytes___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5) {
_start:
{
lean_object* x_6; 
x_6 = l_ZkRV32I_Memory_storeBytes(x_1, x_2, x_3, x_4, x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
return x_6;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_store(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, uint32_t x_5) {
_start:
{
uint8_t x_6; 
x_6 = l_ZkRV32I_Memory_validRange(x_1, x_2, x_3, x_4);
if (x_6 == 0)
{
lean_object* x_7; 
lean_dec(x_3);
lean_dec(x_1);
x_7 = lean_box(0);
return x_7;
}
else
{
uint32_t x_8; lean_object* x_9; lean_object* x_10; lean_object* x_11; lean_object* x_12; lean_object* x_13; uint8_t x_14; 
x_8 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
x_9 = lean_ctor_get(x_1, 0);
lean_inc(x_9);
x_10 = lean_uint32_to_nat(x_8);
x_11 = lean_nat_sub(x_2, x_10);
lean_dec(x_10);
x_12 = lean_uint32_to_nat(x_5);
lean_inc(x_1);
x_13 = lean_alloc_closure((void*)(l_ZkRV32I_Memory_storeBytes___boxed), 5, 4);
lean_closure_set(x_13, 0, x_1);
lean_closure_set(x_13, 1, x_11);
lean_closure_set(x_13, 2, x_12);
lean_closure_set(x_13, 3, x_3);
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
lean_ctor_set(x_18, 0, x_9);
lean_ctor_set(x_18, 1, x_13);
lean_ctor_set_uint32(x_18, sizeof(void*)*2, x_8);
x_19 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_19, 0, x_18);
return x_19;
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_Memory_store___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5) {
_start:
{
uint32_t x_6; lean_object* x_7; 
x_6 = lean_unbox_uint32(x_5);
lean_dec(x_5);
x_7 = l_ZkRV32I_Memory_store(x_1, x_2, x_3, x_4, x_6);
lean_dec(x_4);
lean_dec(x_2);
return x_7;
}
}
lean_object* initialize_Init(uint8_t builtin, lean_object*);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_ZkRV32I_Base(uint8_t builtin, lean_object* w) {
lean_object * res;
if (_G_initialized) return lean_io_result_mk_ok(lean_box(0));
_G_initialized = true;
res = initialize_Init(builtin, lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
l_ZkRV32I_Word32_zero = _init_l_ZkRV32I_Word32_zero();
l_ZkRV32I_Word32_signed___closed__1 = _init_l_ZkRV32I_Word32_signed___closed__1();
lean_mark_persistent(l_ZkRV32I_Word32_signed___closed__1);
l_ZkRV32I_RegisterFile_zeroed___closed__1 = _init_l_ZkRV32I_RegisterFile_zeroed___closed__1();
lean_mark_persistent(l_ZkRV32I_RegisterFile_zeroed___closed__1);
l_ZkRV32I_RegisterFile_zeroed = _init_l_ZkRV32I_RegisterFile_zeroed();
lean_mark_persistent(l_ZkRV32I_RegisterFile_zeroed);
l_ZkRV32I_RegisterFile_read___boxed__const__1 = _init_l_ZkRV32I_RegisterFile_read___boxed__const__1();
lean_mark_persistent(l_ZkRV32I_RegisterFile_read___boxed__const__1);
l_ZkRV32I_Memory_empty___closed__1 = _init_l_ZkRV32I_Memory_empty___closed__1();
lean_mark_persistent(l_ZkRV32I_Memory_empty___closed__1);
return lean_io_result_mk_ok(lean_box(0));
}
#ifdef __cplusplus
}
#endif
