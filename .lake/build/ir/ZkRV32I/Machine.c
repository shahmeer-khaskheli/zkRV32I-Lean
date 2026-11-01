// Lean compiler output
// Module: ZkRV32I.Machine
// Imports: Init ZkRV32I.ISA
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
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_noConfusion___rarg___lambda__1(lean_object*);
LEAN_EXPORT uint32_t l_ZkRV32I_nextPC(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_regWrite(lean_object*, uint32_t, lean_object*, uint32_t);
lean_object* l_ZkRV32I_Word32_signed(uint32_t);
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_noConfusion(lean_object*);
static lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__14;
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_noConfusion___rarg___lambda__1___boxed(lean_object*);
lean_object* lean_uint32_to_nat(uint32_t);
lean_object* l_ZkRV32I_decode(uint32_t);
LEAN_EXPORT lean_object* l_ZkRV32I_loadValue(lean_object*, uint32_t, lean_object*, lean_object*, uint8_t);
LEAN_EXPORT lean_object* l_ZkRV32I_shiftRightArithmetic___boxed(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__3;
LEAN_EXPORT lean_object* l_ZkRV32I_shiftLeft___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_shiftRightLogical___boxed(lean_object*, lean_object*);
lean_object* l_ZkRV32I_RegisterFile_write(lean_object*, lean_object*, uint32_t);
LEAN_EXPORT lean_object* l_ZkRV32I_nextPC___boxed(lean_object*);
lean_object* lean_int_emod(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108_(uint8_t, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_branch___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_step_match__1_splitter___rarg___boxed(lean_object**);
LEAN_EXPORT lean_object* l_ZkRV32I_regRead(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__4;
LEAN_EXPORT lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_step_match__1_splitter(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_regWrite___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
uint8_t lean_int_dec_le(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_execute(lean_object*, uint32_t);
LEAN_EXPORT lean_object* l_ZkRV32I_boolWord___boxed(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_ofNat___boxed(lean_object*);
LEAN_EXPORT uint32_t l_ZkRV32I_wordXor(uint32_t, uint32_t);
uint8_t lean_nat_dec_eq(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_wordAnd___boxed(lean_object*, lean_object*);
static lean_object* l_ZkRV32I_TerminalState_noConfusion___rarg___closed__1;
LEAN_EXPORT uint32_t l_ZkRV32I_shiftLeft(uint32_t, lean_object*);
uint8_t lean_uint32_dec_le(uint32_t, uint32_t);
lean_object* lean_nat_to_int(lean_object*);
uint32_t lean_uint32_of_nat(lean_object*);
LEAN_EXPORT uint8_t l_ZkRV32I_TerminalState_ofNat(lean_object*);
lean_object* lean_nat_div(lean_object*, lean_object*);
lean_object* l_ZkRV32I_Memory_load(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_branch(lean_object*, uint8_t, uint32_t);
LEAN_EXPORT uint32_t l_ZkRV32I_shiftRightArithmetic(uint32_t, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_noConfusion___rarg___boxed(lean_object*, lean_object*, lean_object*);
extern lean_object* l_ZkRV32I_RegisterFile_zeroed;
LEAN_EXPORT uint8_t l_ZkRV32I_instDecidableEqTerminalState(uint8_t, uint8_t);
LEAN_EXPORT lean_object* l_ZkRV32I_instReprTerminalState;
static lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__1;
uint32_t l_ZkRV32I_Word32_signExtend(lean_object*, lean_object*);
lean_object* lean_nat_land(lean_object*, lean_object*);
LEAN_EXPORT uint32_t l_ZkRV32I_wordAnd(uint32_t, uint32_t);
static lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__6;
static lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__5;
LEAN_EXPORT lean_object* l_ZkRV32I_wordXor___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint32_t l_ZkRV32I_shiftRightLogical(uint32_t, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_execute___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_step_match__1_splitter___rarg(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__7;
lean_object* l_ZkRV32I_Memory_store(lean_object*, lean_object*, lean_object*, lean_object*, uint32_t);
lean_object* lean_nat_lxor(lean_object*, lean_object*);
uint32_t lean_uint32_sub(uint32_t, uint32_t);
LEAN_EXPORT lean_object* l_ZkRV32I_loadValue___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_instDecidableEqTerminalState___boxed(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__8;
static lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__2;
lean_object* lean_nat_pow(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_storeValue___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
uint8_t lean_nat_dec_eq(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_MachineState_initial___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_toCtorIdx(uint8_t);
lean_object* lean_nat_mod(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__13;
uint8_t lean_uint32_dec_eq(uint32_t, uint32_t);
LEAN_EXPORT lean_object* l_ZkRV32I_MachineState_initial(uint32_t, lean_object*);
lean_object* l_Int_toNat(lean_object*);
lean_object* l_Repr_addAppParen(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_noConfusion___rarg(uint8_t, uint8_t, lean_object*);
uint8_t lean_int_dec_lt(lean_object*, lean_object*);
lean_object* lean_nat_mul(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__12;
LEAN_EXPORT lean_object* l_ZkRV32I_wordOr___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint32_t l_ZkRV32I_wordOr(uint32_t, uint32_t);
static lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__10;
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_toCtorIdx___boxed(lean_object*);
uint8_t lean_uint32_dec_lt(uint32_t, uint32_t);
lean_object* l_ZkRV32I_RegisterFile_read(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_step(lean_object*, lean_object*);
uint32_t lean_uint32_add(uint32_t, uint32_t);
LEAN_EXPORT uint32_t l_ZkRV32I_boolWord(uint8_t);
lean_object* lean_int_ediv(lean_object*, lean_object*);
uint8_t lean_nat_dec_le(lean_object*, lean_object*);
static lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__9;
LEAN_EXPORT lean_object* l_ZkRV32I_storeValue(lean_object*, uint32_t, uint32_t, lean_object*, lean_object*, uint32_t);
static lean_object* l_ZkRV32I_shiftRightArithmetic___closed__1;
LEAN_EXPORT lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____boxed(lean_object*, lean_object*);
static lean_object* l_ZkRV32I_instReprTerminalState___closed__1;
static lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__11;
lean_object* lean_nat_lor(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_toCtorIdx(uint8_t x_1) {
_start:
{
if (x_1 == 0)
{
lean_object* x_2; 
x_2 = lean_unsigned_to_nat(0u);
return x_2;
}
else
{
lean_object* x_3; 
x_3 = lean_unsigned_to_nat(1u);
return x_3;
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_toCtorIdx___boxed(lean_object* x_1) {
_start:
{
uint8_t x_2; lean_object* x_3; 
x_2 = lean_unbox(x_1);
lean_dec(x_1);
x_3 = l_ZkRV32I_TerminalState_toCtorIdx(x_2);
return x_3;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_noConfusion___rarg___lambda__1(lean_object* x_1) {
_start:
{
lean_inc(x_1);
return x_1;
}
}
static lean_object* _init_l_ZkRV32I_TerminalState_noConfusion___rarg___closed__1() {
_start:
{
lean_object* x_1; 
x_1 = lean_alloc_closure((void*)(l_ZkRV32I_TerminalState_noConfusion___rarg___lambda__1___boxed), 1, 0);
return x_1;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_noConfusion___rarg(uint8_t x_1, uint8_t x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; 
x_4 = l_ZkRV32I_TerminalState_noConfusion___rarg___closed__1;
return x_4;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_noConfusion(lean_object* x_1) {
_start:
{
lean_object* x_2; 
x_2 = lean_alloc_closure((void*)(l_ZkRV32I_TerminalState_noConfusion___rarg___boxed), 3, 0);
return x_2;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_noConfusion___rarg___lambda__1___boxed(lean_object* x_1) {
_start:
{
lean_object* x_2; 
x_2 = l_ZkRV32I_TerminalState_noConfusion___rarg___lambda__1(x_1);
lean_dec(x_1);
return x_2;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_noConfusion___rarg___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
uint8_t x_4; uint8_t x_5; lean_object* x_6; 
x_4 = lean_unbox(x_1);
lean_dec(x_1);
x_5 = lean_unbox(x_2);
lean_dec(x_2);
x_6 = l_ZkRV32I_TerminalState_noConfusion___rarg(x_4, x_5, x_3);
return x_6;
}
}
LEAN_EXPORT uint8_t l_ZkRV32I_TerminalState_ofNat(lean_object* x_1) {
_start:
{
lean_object* x_2; uint8_t x_3; 
x_2 = lean_unsigned_to_nat(0u);
x_3 = lean_nat_dec_eq(x_1, x_2);
if (x_3 == 0)
{
uint8_t x_4; 
x_4 = 1;
return x_4;
}
else
{
uint8_t x_5; 
x_5 = 0;
return x_5;
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_TerminalState_ofNat___boxed(lean_object* x_1) {
_start:
{
uint8_t x_2; lean_object* x_3; 
x_2 = l_ZkRV32I_TerminalState_ofNat(x_1);
lean_dec(x_1);
x_3 = lean_box(x_2);
return x_3;
}
}
LEAN_EXPORT uint8_t l_ZkRV32I_instDecidableEqTerminalState(uint8_t x_1, uint8_t x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; uint8_t x_5; 
x_3 = l_ZkRV32I_TerminalState_toCtorIdx(x_1);
x_4 = l_ZkRV32I_TerminalState_toCtorIdx(x_2);
x_5 = lean_nat_dec_eq(x_3, x_4);
lean_dec(x_4);
lean_dec(x_3);
return x_5;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_instDecidableEqTerminalState___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint8_t x_3; uint8_t x_4; uint8_t x_5; lean_object* x_6; 
x_3 = lean_unbox(x_1);
lean_dec(x_1);
x_4 = lean_unbox(x_2);
lean_dec(x_2);
x_5 = l_ZkRV32I_instDecidableEqTerminalState(x_3, x_4);
x_6 = lean_box(x_5);
return x_6;
}
}
static lean_object* _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__1() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("ZkRV32I.TerminalState.running", 29, 29);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__2() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__1;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__3() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_unsigned_to_nat(2u);
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__4() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__3;
x_2 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__2;
x_3 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_3, 0, x_1);
lean_ctor_set(x_3, 1, x_2);
return x_3;
}
}
static lean_object* _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__5() {
_start:
{
lean_object* x_1; uint8_t x_2; lean_object* x_3; 
x_1 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__4;
x_2 = 0;
x_3 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_3, 0, x_1);
lean_ctor_set_uint8(x_3, sizeof(void*)*1, x_2);
return x_3;
}
}
static lean_object* _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__6() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_unsigned_to_nat(1u);
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__7() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__6;
x_2 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__2;
x_3 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_3, 0, x_1);
lean_ctor_set(x_3, 1, x_2);
return x_3;
}
}
static lean_object* _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__8() {
_start:
{
lean_object* x_1; uint8_t x_2; lean_object* x_3; 
x_1 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__7;
x_2 = 0;
x_3 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_3, 0, x_1);
lean_ctor_set_uint8(x_3, sizeof(void*)*1, x_2);
return x_3;
}
}
static lean_object* _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__9() {
_start:
{
lean_object* x_1; 
x_1 = lean_mk_string_unchecked("ZkRV32I.TerminalState.halted", 28, 28);
return x_1;
}
}
static lean_object* _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__10() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__9;
x_2 = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(x_2, 0, x_1);
return x_2;
}
}
static lean_object* _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__11() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__3;
x_2 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__10;
x_3 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_3, 0, x_1);
lean_ctor_set(x_3, 1, x_2);
return x_3;
}
}
static lean_object* _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__12() {
_start:
{
lean_object* x_1; uint8_t x_2; lean_object* x_3; 
x_1 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__11;
x_2 = 0;
x_3 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_3, 0, x_1);
lean_ctor_set_uint8(x_3, sizeof(void*)*1, x_2);
return x_3;
}
}
static lean_object* _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__13() {
_start:
{
lean_object* x_1; lean_object* x_2; lean_object* x_3; 
x_1 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__6;
x_2 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__10;
x_3 = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(x_3, 0, x_1);
lean_ctor_set(x_3, 1, x_2);
return x_3;
}
}
static lean_object* _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__14() {
_start:
{
lean_object* x_1; uint8_t x_2; lean_object* x_3; 
x_1 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__13;
x_2 = 0;
x_3 = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(x_3, 0, x_1);
lean_ctor_set_uint8(x_3, sizeof(void*)*1, x_2);
return x_3;
}
}
LEAN_EXPORT lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108_(uint8_t x_1, lean_object* x_2) {
_start:
{
if (x_1 == 0)
{
lean_object* x_3; uint8_t x_4; 
x_3 = lean_unsigned_to_nat(1024u);
x_4 = lean_nat_dec_le(x_3, x_2);
if (x_4 == 0)
{
lean_object* x_5; lean_object* x_6; 
x_5 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__5;
x_6 = l_Repr_addAppParen(x_5, x_2);
return x_6;
}
else
{
lean_object* x_7; lean_object* x_8; 
x_7 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__8;
x_8 = l_Repr_addAppParen(x_7, x_2);
return x_8;
}
}
else
{
lean_object* x_9; uint8_t x_10; 
x_9 = lean_unsigned_to_nat(1024u);
x_10 = lean_nat_dec_le(x_9, x_2);
if (x_10 == 0)
{
lean_object* x_11; lean_object* x_12; 
x_11 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__12;
x_12 = l_Repr_addAppParen(x_11, x_2);
return x_12;
}
else
{
lean_object* x_13; lean_object* x_14; 
x_13 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__14;
x_14 = l_Repr_addAppParen(x_13, x_2);
return x_14;
}
}
}
}
LEAN_EXPORT lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint8_t x_3; lean_object* x_4; 
x_3 = lean_unbox(x_1);
lean_dec(x_1);
x_4 = l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108_(x_3, x_2);
lean_dec(x_2);
return x_4;
}
}
static lean_object* _init_l_ZkRV32I_instReprTerminalState___closed__1() {
_start:
{
lean_object* x_1; 
x_1 = lean_alloc_closure((void*)(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____boxed), 2, 0);
return x_1;
}
}
static lean_object* _init_l_ZkRV32I_instReprTerminalState() {
_start:
{
lean_object* x_1; 
x_1 = l_ZkRV32I_instReprTerminalState___closed__1;
return x_1;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_MachineState_initial(uint32_t x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; uint8_t x_4; lean_object* x_5; 
x_3 = l_ZkRV32I_RegisterFile_zeroed;
x_4 = 0;
x_5 = lean_alloc_ctor(0, 2, 5);
lean_ctor_set(x_5, 0, x_3);
lean_ctor_set(x_5, 1, x_2);
lean_ctor_set_uint32(x_5, sizeof(void*)*2, x_1);
lean_ctor_set_uint8(x_5, sizeof(void*)*2 + 4, x_4);
return x_5;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_MachineState_initial___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint32_t x_3; lean_object* x_4; 
x_3 = lean_unbox_uint32(x_1);
lean_dec(x_1);
x_4 = l_ZkRV32I_MachineState_initial(x_3, x_2);
return x_4;
}
}
LEAN_EXPORT uint32_t l_ZkRV32I_nextPC(lean_object* x_1) {
_start:
{
uint32_t x_2; uint32_t x_3; uint32_t x_4; 
x_2 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
x_3 = 4;
x_4 = lean_uint32_add(x_2, x_3);
return x_4;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_nextPC___boxed(lean_object* x_1) {
_start:
{
uint32_t x_2; lean_object* x_3; 
x_2 = l_ZkRV32I_nextPC(x_1);
lean_dec(x_1);
x_3 = lean_box_uint32(x_2);
return x_3;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_regRead(lean_object* x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; 
x_3 = lean_ctor_get(x_1, 0);
lean_inc(x_3);
lean_dec(x_1);
x_4 = l_ZkRV32I_RegisterFile_read(x_3, x_2);
return x_4;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_regWrite(lean_object* x_1, uint32_t x_2, lean_object* x_3, uint32_t x_4) {
_start:
{
uint8_t x_5; 
x_5 = !lean_is_exclusive(x_1);
if (x_5 == 0)
{
lean_object* x_6; lean_object* x_7; 
x_6 = lean_ctor_get(x_1, 0);
x_7 = l_ZkRV32I_RegisterFile_write(x_6, x_3, x_4);
lean_ctor_set(x_1, 0, x_7);
lean_ctor_set_uint32(x_1, sizeof(void*)*2, x_2);
return x_1;
}
else
{
lean_object* x_8; lean_object* x_9; uint8_t x_10; lean_object* x_11; lean_object* x_12; 
x_8 = lean_ctor_get(x_1, 0);
x_9 = lean_ctor_get(x_1, 1);
x_10 = lean_ctor_get_uint8(x_1, sizeof(void*)*2 + 4);
lean_inc(x_9);
lean_inc(x_8);
lean_dec(x_1);
x_11 = l_ZkRV32I_RegisterFile_write(x_8, x_3, x_4);
x_12 = lean_alloc_ctor(0, 2, 5);
lean_ctor_set(x_12, 0, x_11);
lean_ctor_set(x_12, 1, x_9);
lean_ctor_set_uint32(x_12, sizeof(void*)*2, x_2);
lean_ctor_set_uint8(x_12, sizeof(void*)*2 + 4, x_10);
return x_12;
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_regWrite___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4) {
_start:
{
uint32_t x_5; uint32_t x_6; lean_object* x_7; 
x_5 = lean_unbox_uint32(x_2);
lean_dec(x_2);
x_6 = lean_unbox_uint32(x_4);
lean_dec(x_4);
x_7 = l_ZkRV32I_regWrite(x_1, x_5, x_3, x_6);
return x_7;
}
}
LEAN_EXPORT uint32_t l_ZkRV32I_boolWord(uint8_t x_1) {
_start:
{
if (x_1 == 0)
{
uint32_t x_2; 
x_2 = 0;
return x_2;
}
else
{
uint32_t x_3; 
x_3 = 1;
return x_3;
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_boolWord___boxed(lean_object* x_1) {
_start:
{
uint8_t x_2; uint32_t x_3; lean_object* x_4; 
x_2 = lean_unbox(x_1);
lean_dec(x_1);
x_3 = l_ZkRV32I_boolWord(x_2);
x_4 = lean_box_uint32(x_3);
return x_4;
}
}
LEAN_EXPORT uint32_t l_ZkRV32I_wordAnd(uint32_t x_1, uint32_t x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; uint32_t x_6; 
x_3 = lean_uint32_to_nat(x_1);
x_4 = lean_uint32_to_nat(x_2);
x_5 = lean_nat_land(x_3, x_4);
lean_dec(x_4);
lean_dec(x_3);
x_6 = lean_uint32_of_nat(x_5);
lean_dec(x_5);
return x_6;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_wordAnd___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint32_t x_3; uint32_t x_4; uint32_t x_5; lean_object* x_6; 
x_3 = lean_unbox_uint32(x_1);
lean_dec(x_1);
x_4 = lean_unbox_uint32(x_2);
lean_dec(x_2);
x_5 = l_ZkRV32I_wordAnd(x_3, x_4);
x_6 = lean_box_uint32(x_5);
return x_6;
}
}
LEAN_EXPORT uint32_t l_ZkRV32I_wordOr(uint32_t x_1, uint32_t x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; uint32_t x_6; 
x_3 = lean_uint32_to_nat(x_1);
x_4 = lean_uint32_to_nat(x_2);
x_5 = lean_nat_lor(x_3, x_4);
lean_dec(x_4);
lean_dec(x_3);
x_6 = lean_uint32_of_nat(x_5);
lean_dec(x_5);
return x_6;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_wordOr___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint32_t x_3; uint32_t x_4; uint32_t x_5; lean_object* x_6; 
x_3 = lean_unbox_uint32(x_1);
lean_dec(x_1);
x_4 = lean_unbox_uint32(x_2);
lean_dec(x_2);
x_5 = l_ZkRV32I_wordOr(x_3, x_4);
x_6 = lean_box_uint32(x_5);
return x_6;
}
}
LEAN_EXPORT uint32_t l_ZkRV32I_wordXor(uint32_t x_1, uint32_t x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; uint32_t x_6; 
x_3 = lean_uint32_to_nat(x_1);
x_4 = lean_uint32_to_nat(x_2);
x_5 = lean_nat_lxor(x_3, x_4);
lean_dec(x_4);
lean_dec(x_3);
x_6 = lean_uint32_of_nat(x_5);
lean_dec(x_5);
return x_6;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_wordXor___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint32_t x_3; uint32_t x_4; uint32_t x_5; lean_object* x_6; 
x_3 = lean_unbox_uint32(x_1);
lean_dec(x_1);
x_4 = lean_unbox_uint32(x_2);
lean_dec(x_2);
x_5 = l_ZkRV32I_wordXor(x_3, x_4);
x_6 = lean_box_uint32(x_5);
return x_6;
}
}
LEAN_EXPORT uint32_t l_ZkRV32I_shiftLeft(uint32_t x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; lean_object* x_6; lean_object* x_7; lean_object* x_8; uint32_t x_9; 
x_3 = lean_uint32_to_nat(x_1);
x_4 = lean_unsigned_to_nat(32u);
x_5 = lean_nat_mod(x_2, x_4);
x_6 = lean_unsigned_to_nat(2u);
x_7 = lean_nat_pow(x_6, x_5);
lean_dec(x_5);
x_8 = lean_nat_mul(x_3, x_7);
lean_dec(x_7);
lean_dec(x_3);
x_9 = lean_uint32_of_nat(x_8);
lean_dec(x_8);
return x_9;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_shiftLeft___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint32_t x_3; uint32_t x_4; lean_object* x_5; 
x_3 = lean_unbox_uint32(x_1);
lean_dec(x_1);
x_4 = l_ZkRV32I_shiftLeft(x_3, x_2);
lean_dec(x_2);
x_5 = lean_box_uint32(x_4);
return x_5;
}
}
LEAN_EXPORT uint32_t l_ZkRV32I_shiftRightLogical(uint32_t x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; lean_object* x_6; lean_object* x_7; lean_object* x_8; uint32_t x_9; 
x_3 = lean_uint32_to_nat(x_1);
x_4 = lean_unsigned_to_nat(32u);
x_5 = lean_nat_mod(x_2, x_4);
x_6 = lean_unsigned_to_nat(2u);
x_7 = lean_nat_pow(x_6, x_5);
lean_dec(x_5);
x_8 = lean_nat_div(x_3, x_7);
lean_dec(x_7);
lean_dec(x_3);
x_9 = lean_uint32_of_nat(x_8);
lean_dec(x_8);
return x_9;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_shiftRightLogical___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint32_t x_3; uint32_t x_4; lean_object* x_5; 
x_3 = lean_unbox_uint32(x_1);
lean_dec(x_1);
x_4 = l_ZkRV32I_shiftRightLogical(x_3, x_2);
lean_dec(x_2);
x_5 = lean_box_uint32(x_4);
return x_5;
}
}
static lean_object* _init_l_ZkRV32I_shiftRightArithmetic___closed__1() {
_start:
{
lean_object* x_1; lean_object* x_2; 
x_1 = lean_cstr_to_nat("4294967296");
x_2 = lean_nat_to_int(x_1);
return x_2;
}
}
LEAN_EXPORT uint32_t l_ZkRV32I_shiftRightArithmetic(uint32_t x_1, lean_object* x_2) {
_start:
{
lean_object* x_3; lean_object* x_4; lean_object* x_5; lean_object* x_6; lean_object* x_7; lean_object* x_8; lean_object* x_9; lean_object* x_10; lean_object* x_11; lean_object* x_12; uint32_t x_13; 
x_3 = l_ZkRV32I_Word32_signed(x_1);
x_4 = lean_unsigned_to_nat(32u);
x_5 = lean_nat_mod(x_2, x_4);
x_6 = lean_unsigned_to_nat(2u);
x_7 = lean_nat_pow(x_6, x_5);
lean_dec(x_5);
x_8 = lean_nat_to_int(x_7);
x_9 = lean_int_ediv(x_3, x_8);
lean_dec(x_8);
lean_dec(x_3);
x_10 = l_ZkRV32I_shiftRightArithmetic___closed__1;
x_11 = lean_int_emod(x_9, x_10);
lean_dec(x_9);
x_12 = l_Int_toNat(x_11);
lean_dec(x_11);
x_13 = lean_uint32_of_nat(x_12);
lean_dec(x_12);
return x_13;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_shiftRightArithmetic___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint32_t x_3; uint32_t x_4; lean_object* x_5; 
x_3 = lean_unbox_uint32(x_1);
lean_dec(x_1);
x_4 = l_ZkRV32I_shiftRightArithmetic(x_3, x_2);
lean_dec(x_2);
x_5 = lean_box_uint32(x_4);
return x_5;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_loadValue(lean_object* x_1, uint32_t x_2, lean_object* x_3, lean_object* x_4, uint8_t x_5) {
_start:
{
lean_object* x_6; lean_object* x_7; lean_object* x_8; 
x_6 = lean_ctor_get(x_1, 1);
lean_inc(x_6);
lean_dec(x_1);
x_7 = lean_uint32_to_nat(x_2);
lean_inc(x_3);
x_8 = l_ZkRV32I_Memory_load(x_6, x_7, x_3, x_4);
lean_dec(x_7);
if (lean_obj_tag(x_8) == 0)
{
lean_object* x_9; 
lean_dec(x_3);
x_9 = lean_box(0);
return x_9;
}
else
{
if (x_5 == 0)
{
uint8_t x_10; 
lean_dec(x_3);
x_10 = !lean_is_exclusive(x_8);
if (x_10 == 0)
{
return x_8;
}
else
{
lean_object* x_11; lean_object* x_12; 
x_11 = lean_ctor_get(x_8, 0);
lean_inc(x_11);
lean_dec(x_8);
x_12 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_12, 0, x_11);
return x_12;
}
}
else
{
uint8_t x_13; 
x_13 = !lean_is_exclusive(x_8);
if (x_13 == 0)
{
lean_object* x_14; uint32_t x_15; lean_object* x_16; lean_object* x_17; lean_object* x_18; uint32_t x_19; lean_object* x_20; 
x_14 = lean_ctor_get(x_8, 0);
x_15 = lean_unbox_uint32(x_14);
lean_dec(x_14);
x_16 = lean_uint32_to_nat(x_15);
x_17 = lean_unsigned_to_nat(8u);
x_18 = lean_nat_mul(x_3, x_17);
lean_dec(x_3);
x_19 = l_ZkRV32I_Word32_signExtend(x_16, x_18);
lean_dec(x_18);
lean_dec(x_16);
x_20 = lean_box_uint32(x_19);
lean_ctor_set(x_8, 0, x_20);
return x_8;
}
else
{
lean_object* x_21; uint32_t x_22; lean_object* x_23; lean_object* x_24; lean_object* x_25; uint32_t x_26; lean_object* x_27; lean_object* x_28; 
x_21 = lean_ctor_get(x_8, 0);
lean_inc(x_21);
lean_dec(x_8);
x_22 = lean_unbox_uint32(x_21);
lean_dec(x_21);
x_23 = lean_uint32_to_nat(x_22);
x_24 = lean_unsigned_to_nat(8u);
x_25 = lean_nat_mul(x_3, x_24);
lean_dec(x_3);
x_26 = l_ZkRV32I_Word32_signExtend(x_23, x_25);
lean_dec(x_25);
lean_dec(x_23);
x_27 = lean_box_uint32(x_26);
x_28 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_28, 0, x_27);
return x_28;
}
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_loadValue___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5) {
_start:
{
uint32_t x_6; uint8_t x_7; lean_object* x_8; 
x_6 = lean_unbox_uint32(x_2);
lean_dec(x_2);
x_7 = lean_unbox(x_5);
lean_dec(x_5);
x_8 = l_ZkRV32I_loadValue(x_1, x_6, x_3, x_4, x_7);
lean_dec(x_4);
return x_8;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_storeValue(lean_object* x_1, uint32_t x_2, uint32_t x_3, lean_object* x_4, lean_object* x_5, uint32_t x_6) {
_start:
{
uint8_t x_7; 
x_7 = !lean_is_exclusive(x_1);
if (x_7 == 0)
{
lean_object* x_8; lean_object* x_9; lean_object* x_10; lean_object* x_11; 
x_8 = lean_ctor_get(x_1, 0);
x_9 = lean_ctor_get(x_1, 1);
x_10 = lean_uint32_to_nat(x_3);
x_11 = l_ZkRV32I_Memory_store(x_9, x_10, x_4, x_5, x_6);
lean_dec(x_10);
if (lean_obj_tag(x_11) == 0)
{
lean_object* x_12; 
lean_free_object(x_1);
lean_dec(x_8);
x_12 = lean_box(0);
return x_12;
}
else
{
uint8_t x_13; 
x_13 = !lean_is_exclusive(x_11);
if (x_13 == 0)
{
lean_object* x_14; 
x_14 = lean_ctor_get(x_11, 0);
lean_ctor_set(x_1, 1, x_14);
lean_ctor_set_uint32(x_1, sizeof(void*)*2, x_2);
lean_ctor_set(x_11, 0, x_1);
return x_11;
}
else
{
lean_object* x_15; lean_object* x_16; 
x_15 = lean_ctor_get(x_11, 0);
lean_inc(x_15);
lean_dec(x_11);
lean_ctor_set(x_1, 1, x_15);
lean_ctor_set_uint32(x_1, sizeof(void*)*2, x_2);
x_16 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_16, 0, x_1);
return x_16;
}
}
}
else
{
lean_object* x_17; lean_object* x_18; uint8_t x_19; lean_object* x_20; lean_object* x_21; 
x_17 = lean_ctor_get(x_1, 0);
x_18 = lean_ctor_get(x_1, 1);
x_19 = lean_ctor_get_uint8(x_1, sizeof(void*)*2 + 4);
lean_inc(x_18);
lean_inc(x_17);
lean_dec(x_1);
x_20 = lean_uint32_to_nat(x_3);
x_21 = l_ZkRV32I_Memory_store(x_18, x_20, x_4, x_5, x_6);
lean_dec(x_20);
if (lean_obj_tag(x_21) == 0)
{
lean_object* x_22; 
lean_dec(x_17);
x_22 = lean_box(0);
return x_22;
}
else
{
lean_object* x_23; lean_object* x_24; lean_object* x_25; lean_object* x_26; 
x_23 = lean_ctor_get(x_21, 0);
lean_inc(x_23);
if (lean_is_exclusive(x_21)) {
 lean_ctor_release(x_21, 0);
 x_24 = x_21;
} else {
 lean_dec_ref(x_21);
 x_24 = lean_box(0);
}
x_25 = lean_alloc_ctor(0, 2, 5);
lean_ctor_set(x_25, 0, x_17);
lean_ctor_set(x_25, 1, x_23);
lean_ctor_set_uint32(x_25, sizeof(void*)*2, x_2);
lean_ctor_set_uint8(x_25, sizeof(void*)*2 + 4, x_19);
if (lean_is_scalar(x_24)) {
 x_26 = lean_alloc_ctor(1, 1, 0);
} else {
 x_26 = x_24;
}
lean_ctor_set(x_26, 0, x_25);
return x_26;
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_storeValue___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5, lean_object* x_6) {
_start:
{
uint32_t x_7; uint32_t x_8; uint32_t x_9; lean_object* x_10; 
x_7 = lean_unbox_uint32(x_2);
lean_dec(x_2);
x_8 = lean_unbox_uint32(x_3);
lean_dec(x_3);
x_9 = lean_unbox_uint32(x_6);
lean_dec(x_6);
x_10 = l_ZkRV32I_storeValue(x_1, x_7, x_8, x_4, x_5, x_9);
lean_dec(x_5);
return x_10;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_branch(lean_object* x_1, uint8_t x_2, uint32_t x_3) {
_start:
{
if (x_2 == 0)
{
uint32_t x_4; lean_object* x_5; lean_object* x_6; lean_object* x_7; lean_object* x_8; uint8_t x_9; 
x_4 = l_ZkRV32I_nextPC(x_1);
x_5 = lean_uint32_to_nat(x_4);
x_6 = lean_unsigned_to_nat(4u);
x_7 = lean_nat_mod(x_5, x_6);
lean_dec(x_5);
x_8 = lean_unsigned_to_nat(0u);
x_9 = lean_nat_dec_eq(x_7, x_8);
lean_dec(x_7);
if (x_9 == 0)
{
lean_object* x_10; 
lean_dec(x_1);
x_10 = lean_box(0);
return x_10;
}
else
{
uint8_t x_11; 
x_11 = !lean_is_exclusive(x_1);
if (x_11 == 0)
{
lean_object* x_12; 
lean_ctor_set_uint32(x_1, sizeof(void*)*2, x_4);
x_12 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_12, 0, x_1);
return x_12;
}
else
{
lean_object* x_13; lean_object* x_14; uint8_t x_15; lean_object* x_16; lean_object* x_17; 
x_13 = lean_ctor_get(x_1, 0);
x_14 = lean_ctor_get(x_1, 1);
x_15 = lean_ctor_get_uint8(x_1, sizeof(void*)*2 + 4);
lean_inc(x_14);
lean_inc(x_13);
lean_dec(x_1);
x_16 = lean_alloc_ctor(0, 2, 5);
lean_ctor_set(x_16, 0, x_13);
lean_ctor_set(x_16, 1, x_14);
lean_ctor_set_uint32(x_16, sizeof(void*)*2, x_4);
lean_ctor_set_uint8(x_16, sizeof(void*)*2 + 4, x_15);
x_17 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_17, 0, x_16);
return x_17;
}
}
}
else
{
uint8_t x_18; 
x_18 = !lean_is_exclusive(x_1);
if (x_18 == 0)
{
uint32_t x_19; lean_object* x_20; lean_object* x_21; uint32_t x_22; lean_object* x_23; lean_object* x_24; lean_object* x_25; lean_object* x_26; uint8_t x_27; 
x_19 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
x_20 = lean_ctor_get(x_1, 0);
x_21 = lean_ctor_get(x_1, 1);
x_22 = lean_uint32_add(x_19, x_3);
x_23 = lean_uint32_to_nat(x_22);
x_24 = lean_unsigned_to_nat(4u);
x_25 = lean_nat_mod(x_23, x_24);
lean_dec(x_23);
x_26 = lean_unsigned_to_nat(0u);
x_27 = lean_nat_dec_eq(x_25, x_26);
lean_dec(x_25);
if (x_27 == 0)
{
lean_object* x_28; 
lean_free_object(x_1);
lean_dec(x_21);
lean_dec(x_20);
x_28 = lean_box(0);
return x_28;
}
else
{
lean_object* x_29; 
lean_ctor_set_uint32(x_1, sizeof(void*)*2, x_22);
x_29 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_29, 0, x_1);
return x_29;
}
}
else
{
uint32_t x_30; lean_object* x_31; lean_object* x_32; uint8_t x_33; uint32_t x_34; lean_object* x_35; lean_object* x_36; lean_object* x_37; lean_object* x_38; uint8_t x_39; 
x_30 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
x_31 = lean_ctor_get(x_1, 0);
x_32 = lean_ctor_get(x_1, 1);
x_33 = lean_ctor_get_uint8(x_1, sizeof(void*)*2 + 4);
lean_inc(x_32);
lean_inc(x_31);
lean_dec(x_1);
x_34 = lean_uint32_add(x_30, x_3);
x_35 = lean_uint32_to_nat(x_34);
x_36 = lean_unsigned_to_nat(4u);
x_37 = lean_nat_mod(x_35, x_36);
lean_dec(x_35);
x_38 = lean_unsigned_to_nat(0u);
x_39 = lean_nat_dec_eq(x_37, x_38);
lean_dec(x_37);
if (x_39 == 0)
{
lean_object* x_40; 
lean_dec(x_32);
lean_dec(x_31);
x_40 = lean_box(0);
return x_40;
}
else
{
lean_object* x_41; lean_object* x_42; 
x_41 = lean_alloc_ctor(0, 2, 5);
lean_ctor_set(x_41, 0, x_31);
lean_ctor_set(x_41, 1, x_32);
lean_ctor_set_uint32(x_41, sizeof(void*)*2, x_34);
lean_ctor_set_uint8(x_41, sizeof(void*)*2 + 4, x_33);
x_42 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_42, 0, x_41);
return x_42;
}
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_branch___boxed(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
uint8_t x_4; uint32_t x_5; lean_object* x_6; 
x_4 = lean_unbox(x_2);
lean_dec(x_2);
x_5 = lean_unbox_uint32(x_3);
lean_dec(x_3);
x_6 = l_ZkRV32I_branch(x_1, x_4, x_5);
return x_6;
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_step(lean_object* x_1, lean_object* x_2) {
_start:
{
uint32_t x_3; lean_object* x_4; lean_object* x_5; uint8_t x_6; uint8_t x_7; uint8_t x_8; 
x_3 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
x_4 = lean_ctor_get(x_1, 0);
lean_inc(x_4);
x_5 = lean_ctor_get(x_1, 1);
lean_inc(x_5);
x_6 = lean_ctor_get_uint8(x_1, sizeof(void*)*2 + 4);
x_7 = 1;
x_8 = l_ZkRV32I_instDecidableEqTerminalState(x_6, x_7);
if (x_8 == 0)
{
uint32_t x_9; 
x_9 = l_ZkRV32I_nextPC(x_1);
switch (lean_obj_tag(x_2)) {
case 0:
{
lean_object* x_10; uint32_t x_11; lean_object* x_12; lean_object* x_13; 
lean_dec(x_5);
lean_dec(x_4);
x_10 = lean_ctor_get(x_2, 0);
lean_inc(x_10);
x_11 = lean_ctor_get_uint32(x_2, sizeof(void*)*1);
lean_dec(x_2);
x_12 = l_ZkRV32I_regWrite(x_1, x_9, x_10, x_11);
x_13 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_13, 0, x_12);
return x_13;
}
case 1:
{
lean_object* x_14; uint32_t x_15; uint32_t x_16; lean_object* x_17; lean_object* x_18; 
lean_dec(x_5);
lean_dec(x_4);
x_14 = lean_ctor_get(x_2, 0);
lean_inc(x_14);
x_15 = lean_ctor_get_uint32(x_2, sizeof(void*)*1);
lean_dec(x_2);
x_16 = lean_uint32_add(x_3, x_15);
x_17 = l_ZkRV32I_regWrite(x_1, x_9, x_14, x_16);
x_18 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_18, 0, x_17);
return x_18;
}
case 2:
{
lean_object* x_19; uint32_t x_20; uint32_t x_21; lean_object* x_22; lean_object* x_23; lean_object* x_24; lean_object* x_25; uint8_t x_26; 
lean_dec(x_5);
lean_dec(x_4);
x_19 = lean_ctor_get(x_2, 0);
lean_inc(x_19);
x_20 = lean_ctor_get_uint32(x_2, sizeof(void*)*1);
lean_dec(x_2);
x_21 = lean_uint32_add(x_3, x_20);
x_22 = lean_uint32_to_nat(x_21);
x_23 = lean_unsigned_to_nat(4u);
x_24 = lean_nat_mod(x_22, x_23);
lean_dec(x_22);
x_25 = lean_unsigned_to_nat(0u);
x_26 = lean_nat_dec_eq(x_24, x_25);
lean_dec(x_24);
if (x_26 == 0)
{
lean_object* x_27; 
lean_dec(x_19);
lean_dec(x_1);
x_27 = lean_box(0);
return x_27;
}
else
{
lean_object* x_28; lean_object* x_29; 
x_28 = l_ZkRV32I_regWrite(x_1, x_21, x_19, x_9);
x_29 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_29, 0, x_28);
return x_29;
}
}
case 3:
{
lean_object* x_30; lean_object* x_31; uint32_t x_32; lean_object* x_33; uint32_t x_34; uint32_t x_35; lean_object* x_36; uint32_t x_37; lean_object* x_38; lean_object* x_39; lean_object* x_40; lean_object* x_41; uint32_t x_42; lean_object* x_43; lean_object* x_44; lean_object* x_45; lean_object* x_46; uint8_t x_47; 
lean_dec(x_5);
lean_dec(x_4);
x_30 = lean_ctor_get(x_2, 0);
lean_inc(x_30);
x_31 = lean_ctor_get(x_2, 1);
lean_inc(x_31);
x_32 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_33 = l_ZkRV32I_regRead(x_1, x_31);
x_34 = lean_unbox_uint32(x_33);
lean_dec(x_33);
x_35 = lean_uint32_add(x_34, x_32);
x_36 = lean_uint32_to_nat(x_35);
x_37 = lean_uint32_of_nat(x_36);
lean_dec(x_36);
x_38 = lean_uint32_to_nat(x_37);
x_39 = lean_unsigned_to_nat(2u);
x_40 = lean_nat_div(x_38, x_39);
lean_dec(x_38);
x_41 = lean_nat_mul(x_40, x_39);
lean_dec(x_40);
x_42 = lean_uint32_of_nat(x_41);
lean_dec(x_41);
x_43 = lean_uint32_to_nat(x_42);
x_44 = lean_unsigned_to_nat(4u);
x_45 = lean_nat_mod(x_43, x_44);
lean_dec(x_43);
x_46 = lean_unsigned_to_nat(0u);
x_47 = lean_nat_dec_eq(x_45, x_46);
lean_dec(x_45);
if (x_47 == 0)
{
lean_object* x_48; 
lean_dec(x_30);
lean_dec(x_1);
x_48 = lean_box(0);
return x_48;
}
else
{
lean_object* x_49; lean_object* x_50; 
x_49 = l_ZkRV32I_regWrite(x_1, x_42, x_30, x_9);
x_50 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_50, 0, x_49);
return x_50;
}
}
case 4:
{
lean_object* x_51; lean_object* x_52; uint32_t x_53; lean_object* x_54; uint32_t x_55; lean_object* x_56; uint32_t x_57; uint8_t x_58; lean_object* x_59; 
lean_dec(x_5);
lean_dec(x_4);
x_51 = lean_ctor_get(x_2, 0);
lean_inc(x_51);
x_52 = lean_ctor_get(x_2, 1);
lean_inc(x_52);
x_53 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_54 = l_ZkRV32I_regRead(x_1, x_51);
x_55 = lean_unbox_uint32(x_54);
lean_dec(x_54);
lean_inc(x_1);
x_56 = l_ZkRV32I_regRead(x_1, x_52);
x_57 = lean_unbox_uint32(x_56);
lean_dec(x_56);
x_58 = lean_uint32_dec_eq(x_55, x_57);
x_59 = l_ZkRV32I_branch(x_1, x_58, x_53);
return x_59;
}
case 5:
{
lean_object* x_60; lean_object* x_61; uint32_t x_62; lean_object* x_63; uint32_t x_64; lean_object* x_65; uint32_t x_66; uint8_t x_67; 
lean_dec(x_5);
lean_dec(x_4);
x_60 = lean_ctor_get(x_2, 0);
lean_inc(x_60);
x_61 = lean_ctor_get(x_2, 1);
lean_inc(x_61);
x_62 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_63 = l_ZkRV32I_regRead(x_1, x_60);
x_64 = lean_unbox_uint32(x_63);
lean_dec(x_63);
lean_inc(x_1);
x_65 = l_ZkRV32I_regRead(x_1, x_61);
x_66 = lean_unbox_uint32(x_65);
lean_dec(x_65);
x_67 = lean_uint32_dec_eq(x_64, x_66);
if (x_67 == 0)
{
uint8_t x_68; lean_object* x_69; 
x_68 = 1;
x_69 = l_ZkRV32I_branch(x_1, x_68, x_62);
return x_69;
}
else
{
uint8_t x_70; lean_object* x_71; 
x_70 = 0;
x_71 = l_ZkRV32I_branch(x_1, x_70, x_62);
return x_71;
}
}
case 6:
{
lean_object* x_72; lean_object* x_73; uint32_t x_74; lean_object* x_75; uint32_t x_76; lean_object* x_77; lean_object* x_78; uint32_t x_79; lean_object* x_80; uint8_t x_81; lean_object* x_82; 
lean_dec(x_5);
lean_dec(x_4);
x_72 = lean_ctor_get(x_2, 0);
lean_inc(x_72);
x_73 = lean_ctor_get(x_2, 1);
lean_inc(x_73);
x_74 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_75 = l_ZkRV32I_regRead(x_1, x_72);
x_76 = lean_unbox_uint32(x_75);
lean_dec(x_75);
x_77 = l_ZkRV32I_Word32_signed(x_76);
lean_inc(x_1);
x_78 = l_ZkRV32I_regRead(x_1, x_73);
x_79 = lean_unbox_uint32(x_78);
lean_dec(x_78);
x_80 = l_ZkRV32I_Word32_signed(x_79);
x_81 = lean_int_dec_lt(x_77, x_80);
lean_dec(x_80);
lean_dec(x_77);
x_82 = l_ZkRV32I_branch(x_1, x_81, x_74);
return x_82;
}
case 7:
{
lean_object* x_83; lean_object* x_84; uint32_t x_85; lean_object* x_86; uint32_t x_87; lean_object* x_88; lean_object* x_89; uint32_t x_90; lean_object* x_91; uint8_t x_92; lean_object* x_93; 
lean_dec(x_5);
lean_dec(x_4);
x_83 = lean_ctor_get(x_2, 0);
lean_inc(x_83);
x_84 = lean_ctor_get(x_2, 1);
lean_inc(x_84);
x_85 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_86 = l_ZkRV32I_regRead(x_1, x_84);
x_87 = lean_unbox_uint32(x_86);
lean_dec(x_86);
x_88 = l_ZkRV32I_Word32_signed(x_87);
lean_inc(x_1);
x_89 = l_ZkRV32I_regRead(x_1, x_83);
x_90 = lean_unbox_uint32(x_89);
lean_dec(x_89);
x_91 = l_ZkRV32I_Word32_signed(x_90);
x_92 = lean_int_dec_le(x_88, x_91);
lean_dec(x_91);
lean_dec(x_88);
x_93 = l_ZkRV32I_branch(x_1, x_92, x_85);
return x_93;
}
case 8:
{
lean_object* x_94; lean_object* x_95; uint32_t x_96; lean_object* x_97; uint32_t x_98; lean_object* x_99; uint32_t x_100; uint8_t x_101; lean_object* x_102; 
lean_dec(x_5);
lean_dec(x_4);
x_94 = lean_ctor_get(x_2, 0);
lean_inc(x_94);
x_95 = lean_ctor_get(x_2, 1);
lean_inc(x_95);
x_96 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_97 = l_ZkRV32I_regRead(x_1, x_94);
x_98 = lean_unbox_uint32(x_97);
lean_dec(x_97);
lean_inc(x_1);
x_99 = l_ZkRV32I_regRead(x_1, x_95);
x_100 = lean_unbox_uint32(x_99);
lean_dec(x_99);
x_101 = lean_uint32_dec_lt(x_98, x_100);
x_102 = l_ZkRV32I_branch(x_1, x_101, x_96);
return x_102;
}
case 9:
{
lean_object* x_103; lean_object* x_104; uint32_t x_105; lean_object* x_106; uint32_t x_107; lean_object* x_108; uint32_t x_109; uint8_t x_110; lean_object* x_111; 
lean_dec(x_5);
lean_dec(x_4);
x_103 = lean_ctor_get(x_2, 0);
lean_inc(x_103);
x_104 = lean_ctor_get(x_2, 1);
lean_inc(x_104);
x_105 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_106 = l_ZkRV32I_regRead(x_1, x_104);
x_107 = lean_unbox_uint32(x_106);
lean_dec(x_106);
lean_inc(x_1);
x_108 = l_ZkRV32I_regRead(x_1, x_103);
x_109 = lean_unbox_uint32(x_108);
lean_dec(x_108);
x_110 = lean_uint32_dec_le(x_107, x_109);
x_111 = l_ZkRV32I_branch(x_1, x_110, x_105);
return x_111;
}
case 10:
{
lean_object* x_112; lean_object* x_113; uint32_t x_114; lean_object* x_115; uint32_t x_116; uint32_t x_117; lean_object* x_118; uint8_t x_119; lean_object* x_120; 
lean_dec(x_5);
lean_dec(x_4);
x_112 = lean_ctor_get(x_2, 0);
lean_inc(x_112);
x_113 = lean_ctor_get(x_2, 1);
lean_inc(x_113);
x_114 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_115 = l_ZkRV32I_regRead(x_1, x_113);
x_116 = lean_unbox_uint32(x_115);
lean_dec(x_115);
x_117 = lean_uint32_add(x_116, x_114);
x_118 = lean_unsigned_to_nat(1u);
x_119 = 1;
lean_inc(x_1);
x_120 = l_ZkRV32I_loadValue(x_1, x_117, x_118, x_118, x_119);
if (lean_obj_tag(x_120) == 0)
{
lean_object* x_121; 
lean_dec(x_112);
lean_dec(x_1);
x_121 = lean_box(0);
return x_121;
}
else
{
uint8_t x_122; 
x_122 = !lean_is_exclusive(x_120);
if (x_122 == 0)
{
lean_object* x_123; uint32_t x_124; lean_object* x_125; 
x_123 = lean_ctor_get(x_120, 0);
x_124 = lean_unbox_uint32(x_123);
lean_dec(x_123);
x_125 = l_ZkRV32I_regWrite(x_1, x_9, x_112, x_124);
lean_ctor_set(x_120, 0, x_125);
return x_120;
}
else
{
lean_object* x_126; uint32_t x_127; lean_object* x_128; lean_object* x_129; 
x_126 = lean_ctor_get(x_120, 0);
lean_inc(x_126);
lean_dec(x_120);
x_127 = lean_unbox_uint32(x_126);
lean_dec(x_126);
x_128 = l_ZkRV32I_regWrite(x_1, x_9, x_112, x_127);
x_129 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_129, 0, x_128);
return x_129;
}
}
}
case 11:
{
lean_object* x_130; lean_object* x_131; uint32_t x_132; lean_object* x_133; uint32_t x_134; uint32_t x_135; lean_object* x_136; uint8_t x_137; lean_object* x_138; 
lean_dec(x_5);
lean_dec(x_4);
x_130 = lean_ctor_get(x_2, 0);
lean_inc(x_130);
x_131 = lean_ctor_get(x_2, 1);
lean_inc(x_131);
x_132 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_133 = l_ZkRV32I_regRead(x_1, x_131);
x_134 = lean_unbox_uint32(x_133);
lean_dec(x_133);
x_135 = lean_uint32_add(x_134, x_132);
x_136 = lean_unsigned_to_nat(2u);
x_137 = 1;
lean_inc(x_1);
x_138 = l_ZkRV32I_loadValue(x_1, x_135, x_136, x_136, x_137);
if (lean_obj_tag(x_138) == 0)
{
lean_object* x_139; 
lean_dec(x_130);
lean_dec(x_1);
x_139 = lean_box(0);
return x_139;
}
else
{
uint8_t x_140; 
x_140 = !lean_is_exclusive(x_138);
if (x_140 == 0)
{
lean_object* x_141; uint32_t x_142; lean_object* x_143; 
x_141 = lean_ctor_get(x_138, 0);
x_142 = lean_unbox_uint32(x_141);
lean_dec(x_141);
x_143 = l_ZkRV32I_regWrite(x_1, x_9, x_130, x_142);
lean_ctor_set(x_138, 0, x_143);
return x_138;
}
else
{
lean_object* x_144; uint32_t x_145; lean_object* x_146; lean_object* x_147; 
x_144 = lean_ctor_get(x_138, 0);
lean_inc(x_144);
lean_dec(x_138);
x_145 = lean_unbox_uint32(x_144);
lean_dec(x_144);
x_146 = l_ZkRV32I_regWrite(x_1, x_9, x_130, x_145);
x_147 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_147, 0, x_146);
return x_147;
}
}
}
case 12:
{
lean_object* x_148; lean_object* x_149; uint32_t x_150; lean_object* x_151; uint32_t x_152; uint32_t x_153; lean_object* x_154; uint8_t x_155; lean_object* x_156; 
lean_dec(x_5);
lean_dec(x_4);
x_148 = lean_ctor_get(x_2, 0);
lean_inc(x_148);
x_149 = lean_ctor_get(x_2, 1);
lean_inc(x_149);
x_150 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_151 = l_ZkRV32I_regRead(x_1, x_149);
x_152 = lean_unbox_uint32(x_151);
lean_dec(x_151);
x_153 = lean_uint32_add(x_152, x_150);
x_154 = lean_unsigned_to_nat(4u);
x_155 = 1;
lean_inc(x_1);
x_156 = l_ZkRV32I_loadValue(x_1, x_153, x_154, x_154, x_155);
if (lean_obj_tag(x_156) == 0)
{
lean_object* x_157; 
lean_dec(x_148);
lean_dec(x_1);
x_157 = lean_box(0);
return x_157;
}
else
{
uint8_t x_158; 
x_158 = !lean_is_exclusive(x_156);
if (x_158 == 0)
{
lean_object* x_159; uint32_t x_160; lean_object* x_161; 
x_159 = lean_ctor_get(x_156, 0);
x_160 = lean_unbox_uint32(x_159);
lean_dec(x_159);
x_161 = l_ZkRV32I_regWrite(x_1, x_9, x_148, x_160);
lean_ctor_set(x_156, 0, x_161);
return x_156;
}
else
{
lean_object* x_162; uint32_t x_163; lean_object* x_164; lean_object* x_165; 
x_162 = lean_ctor_get(x_156, 0);
lean_inc(x_162);
lean_dec(x_156);
x_163 = lean_unbox_uint32(x_162);
lean_dec(x_162);
x_164 = l_ZkRV32I_regWrite(x_1, x_9, x_148, x_163);
x_165 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_165, 0, x_164);
return x_165;
}
}
}
case 13:
{
lean_object* x_166; lean_object* x_167; uint32_t x_168; lean_object* x_169; uint32_t x_170; uint32_t x_171; lean_object* x_172; uint8_t x_173; lean_object* x_174; 
lean_dec(x_5);
lean_dec(x_4);
x_166 = lean_ctor_get(x_2, 0);
lean_inc(x_166);
x_167 = lean_ctor_get(x_2, 1);
lean_inc(x_167);
x_168 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_169 = l_ZkRV32I_regRead(x_1, x_167);
x_170 = lean_unbox_uint32(x_169);
lean_dec(x_169);
x_171 = lean_uint32_add(x_170, x_168);
x_172 = lean_unsigned_to_nat(1u);
x_173 = 0;
lean_inc(x_1);
x_174 = l_ZkRV32I_loadValue(x_1, x_171, x_172, x_172, x_173);
if (lean_obj_tag(x_174) == 0)
{
lean_object* x_175; 
lean_dec(x_166);
lean_dec(x_1);
x_175 = lean_box(0);
return x_175;
}
else
{
uint8_t x_176; 
x_176 = !lean_is_exclusive(x_174);
if (x_176 == 0)
{
lean_object* x_177; uint32_t x_178; lean_object* x_179; 
x_177 = lean_ctor_get(x_174, 0);
x_178 = lean_unbox_uint32(x_177);
lean_dec(x_177);
x_179 = l_ZkRV32I_regWrite(x_1, x_9, x_166, x_178);
lean_ctor_set(x_174, 0, x_179);
return x_174;
}
else
{
lean_object* x_180; uint32_t x_181; lean_object* x_182; lean_object* x_183; 
x_180 = lean_ctor_get(x_174, 0);
lean_inc(x_180);
lean_dec(x_174);
x_181 = lean_unbox_uint32(x_180);
lean_dec(x_180);
x_182 = l_ZkRV32I_regWrite(x_1, x_9, x_166, x_181);
x_183 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_183, 0, x_182);
return x_183;
}
}
}
case 14:
{
lean_object* x_184; lean_object* x_185; uint32_t x_186; lean_object* x_187; uint32_t x_188; uint32_t x_189; lean_object* x_190; uint8_t x_191; lean_object* x_192; 
lean_dec(x_5);
lean_dec(x_4);
x_184 = lean_ctor_get(x_2, 0);
lean_inc(x_184);
x_185 = lean_ctor_get(x_2, 1);
lean_inc(x_185);
x_186 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_187 = l_ZkRV32I_regRead(x_1, x_185);
x_188 = lean_unbox_uint32(x_187);
lean_dec(x_187);
x_189 = lean_uint32_add(x_188, x_186);
x_190 = lean_unsigned_to_nat(2u);
x_191 = 0;
lean_inc(x_1);
x_192 = l_ZkRV32I_loadValue(x_1, x_189, x_190, x_190, x_191);
if (lean_obj_tag(x_192) == 0)
{
lean_object* x_193; 
lean_dec(x_184);
lean_dec(x_1);
x_193 = lean_box(0);
return x_193;
}
else
{
uint8_t x_194; 
x_194 = !lean_is_exclusive(x_192);
if (x_194 == 0)
{
lean_object* x_195; uint32_t x_196; lean_object* x_197; 
x_195 = lean_ctor_get(x_192, 0);
x_196 = lean_unbox_uint32(x_195);
lean_dec(x_195);
x_197 = l_ZkRV32I_regWrite(x_1, x_9, x_184, x_196);
lean_ctor_set(x_192, 0, x_197);
return x_192;
}
else
{
lean_object* x_198; uint32_t x_199; lean_object* x_200; lean_object* x_201; 
x_198 = lean_ctor_get(x_192, 0);
lean_inc(x_198);
lean_dec(x_192);
x_199 = lean_unbox_uint32(x_198);
lean_dec(x_198);
x_200 = l_ZkRV32I_regWrite(x_1, x_9, x_184, x_199);
x_201 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_201, 0, x_200);
return x_201;
}
}
}
case 15:
{
lean_object* x_202; lean_object* x_203; uint32_t x_204; lean_object* x_205; uint32_t x_206; uint32_t x_207; lean_object* x_208; uint32_t x_209; lean_object* x_210; lean_object* x_211; 
lean_dec(x_5);
lean_dec(x_4);
x_202 = lean_ctor_get(x_2, 0);
lean_inc(x_202);
x_203 = lean_ctor_get(x_2, 1);
lean_inc(x_203);
x_204 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_205 = l_ZkRV32I_regRead(x_1, x_202);
x_206 = lean_unbox_uint32(x_205);
lean_dec(x_205);
x_207 = lean_uint32_add(x_206, x_204);
lean_inc(x_1);
x_208 = l_ZkRV32I_regRead(x_1, x_203);
x_209 = lean_unbox_uint32(x_208);
lean_dec(x_208);
x_210 = lean_unsigned_to_nat(1u);
x_211 = l_ZkRV32I_storeValue(x_1, x_9, x_207, x_210, x_210, x_209);
return x_211;
}
case 16:
{
lean_object* x_212; lean_object* x_213; uint32_t x_214; lean_object* x_215; uint32_t x_216; uint32_t x_217; lean_object* x_218; uint32_t x_219; lean_object* x_220; lean_object* x_221; 
lean_dec(x_5);
lean_dec(x_4);
x_212 = lean_ctor_get(x_2, 0);
lean_inc(x_212);
x_213 = lean_ctor_get(x_2, 1);
lean_inc(x_213);
x_214 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_215 = l_ZkRV32I_regRead(x_1, x_212);
x_216 = lean_unbox_uint32(x_215);
lean_dec(x_215);
x_217 = lean_uint32_add(x_216, x_214);
lean_inc(x_1);
x_218 = l_ZkRV32I_regRead(x_1, x_213);
x_219 = lean_unbox_uint32(x_218);
lean_dec(x_218);
x_220 = lean_unsigned_to_nat(2u);
x_221 = l_ZkRV32I_storeValue(x_1, x_9, x_217, x_220, x_220, x_219);
return x_221;
}
case 17:
{
lean_object* x_222; lean_object* x_223; uint32_t x_224; lean_object* x_225; uint32_t x_226; uint32_t x_227; lean_object* x_228; uint32_t x_229; lean_object* x_230; lean_object* x_231; 
lean_dec(x_5);
lean_dec(x_4);
x_222 = lean_ctor_get(x_2, 0);
lean_inc(x_222);
x_223 = lean_ctor_get(x_2, 1);
lean_inc(x_223);
x_224 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_225 = l_ZkRV32I_regRead(x_1, x_222);
x_226 = lean_unbox_uint32(x_225);
lean_dec(x_225);
x_227 = lean_uint32_add(x_226, x_224);
lean_inc(x_1);
x_228 = l_ZkRV32I_regRead(x_1, x_223);
x_229 = lean_unbox_uint32(x_228);
lean_dec(x_228);
x_230 = lean_unsigned_to_nat(4u);
x_231 = l_ZkRV32I_storeValue(x_1, x_9, x_227, x_230, x_230, x_229);
return x_231;
}
case 18:
{
lean_object* x_232; lean_object* x_233; uint32_t x_234; lean_object* x_235; uint32_t x_236; uint32_t x_237; lean_object* x_238; lean_object* x_239; 
lean_dec(x_5);
lean_dec(x_4);
x_232 = lean_ctor_get(x_2, 0);
lean_inc(x_232);
x_233 = lean_ctor_get(x_2, 1);
lean_inc(x_233);
x_234 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_235 = l_ZkRV32I_regRead(x_1, x_233);
x_236 = lean_unbox_uint32(x_235);
lean_dec(x_235);
x_237 = lean_uint32_add(x_236, x_234);
x_238 = l_ZkRV32I_regWrite(x_1, x_9, x_232, x_237);
x_239 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_239, 0, x_238);
return x_239;
}
case 19:
{
lean_object* x_240; lean_object* x_241; uint32_t x_242; lean_object* x_243; uint32_t x_244; lean_object* x_245; lean_object* x_246; uint8_t x_247; uint32_t x_248; lean_object* x_249; lean_object* x_250; 
lean_dec(x_5);
lean_dec(x_4);
x_240 = lean_ctor_get(x_2, 0);
lean_inc(x_240);
x_241 = lean_ctor_get(x_2, 1);
lean_inc(x_241);
x_242 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_243 = l_ZkRV32I_regRead(x_1, x_241);
x_244 = lean_unbox_uint32(x_243);
lean_dec(x_243);
x_245 = l_ZkRV32I_Word32_signed(x_244);
x_246 = l_ZkRV32I_Word32_signed(x_242);
x_247 = lean_int_dec_lt(x_245, x_246);
lean_dec(x_246);
lean_dec(x_245);
x_248 = l_ZkRV32I_boolWord(x_247);
x_249 = l_ZkRV32I_regWrite(x_1, x_9, x_240, x_248);
x_250 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_250, 0, x_249);
return x_250;
}
case 20:
{
lean_object* x_251; lean_object* x_252; uint32_t x_253; lean_object* x_254; uint32_t x_255; uint8_t x_256; uint32_t x_257; lean_object* x_258; lean_object* x_259; 
lean_dec(x_5);
lean_dec(x_4);
x_251 = lean_ctor_get(x_2, 0);
lean_inc(x_251);
x_252 = lean_ctor_get(x_2, 1);
lean_inc(x_252);
x_253 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_254 = l_ZkRV32I_regRead(x_1, x_252);
x_255 = lean_unbox_uint32(x_254);
lean_dec(x_254);
x_256 = lean_uint32_dec_lt(x_255, x_253);
x_257 = l_ZkRV32I_boolWord(x_256);
x_258 = l_ZkRV32I_regWrite(x_1, x_9, x_251, x_257);
x_259 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_259, 0, x_258);
return x_259;
}
case 21:
{
lean_object* x_260; lean_object* x_261; uint32_t x_262; lean_object* x_263; uint32_t x_264; uint32_t x_265; lean_object* x_266; lean_object* x_267; 
lean_dec(x_5);
lean_dec(x_4);
x_260 = lean_ctor_get(x_2, 0);
lean_inc(x_260);
x_261 = lean_ctor_get(x_2, 1);
lean_inc(x_261);
x_262 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_263 = l_ZkRV32I_regRead(x_1, x_261);
x_264 = lean_unbox_uint32(x_263);
lean_dec(x_263);
x_265 = l_ZkRV32I_wordXor(x_264, x_262);
x_266 = l_ZkRV32I_regWrite(x_1, x_9, x_260, x_265);
x_267 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_267, 0, x_266);
return x_267;
}
case 22:
{
lean_object* x_268; lean_object* x_269; uint32_t x_270; lean_object* x_271; uint32_t x_272; uint32_t x_273; lean_object* x_274; lean_object* x_275; 
lean_dec(x_5);
lean_dec(x_4);
x_268 = lean_ctor_get(x_2, 0);
lean_inc(x_268);
x_269 = lean_ctor_get(x_2, 1);
lean_inc(x_269);
x_270 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_271 = l_ZkRV32I_regRead(x_1, x_269);
x_272 = lean_unbox_uint32(x_271);
lean_dec(x_271);
x_273 = l_ZkRV32I_wordOr(x_272, x_270);
x_274 = l_ZkRV32I_regWrite(x_1, x_9, x_268, x_273);
x_275 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_275, 0, x_274);
return x_275;
}
case 23:
{
lean_object* x_276; lean_object* x_277; uint32_t x_278; lean_object* x_279; uint32_t x_280; uint32_t x_281; lean_object* x_282; lean_object* x_283; 
lean_dec(x_5);
lean_dec(x_4);
x_276 = lean_ctor_get(x_2, 0);
lean_inc(x_276);
x_277 = lean_ctor_get(x_2, 1);
lean_inc(x_277);
x_278 = lean_ctor_get_uint32(x_2, sizeof(void*)*2);
lean_dec(x_2);
lean_inc(x_1);
x_279 = l_ZkRV32I_regRead(x_1, x_277);
x_280 = lean_unbox_uint32(x_279);
lean_dec(x_279);
x_281 = l_ZkRV32I_wordAnd(x_280, x_278);
x_282 = l_ZkRV32I_regWrite(x_1, x_9, x_276, x_281);
x_283 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_283, 0, x_282);
return x_283;
}
case 24:
{
lean_object* x_284; lean_object* x_285; lean_object* x_286; lean_object* x_287; uint32_t x_288; uint32_t x_289; lean_object* x_290; lean_object* x_291; 
lean_dec(x_5);
lean_dec(x_4);
x_284 = lean_ctor_get(x_2, 0);
lean_inc(x_284);
x_285 = lean_ctor_get(x_2, 1);
lean_inc(x_285);
x_286 = lean_ctor_get(x_2, 2);
lean_inc(x_286);
lean_dec(x_2);
lean_inc(x_1);
x_287 = l_ZkRV32I_regRead(x_1, x_285);
x_288 = lean_unbox_uint32(x_287);
lean_dec(x_287);
x_289 = l_ZkRV32I_shiftLeft(x_288, x_286);
lean_dec(x_286);
x_290 = l_ZkRV32I_regWrite(x_1, x_9, x_284, x_289);
x_291 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_291, 0, x_290);
return x_291;
}
case 25:
{
lean_object* x_292; lean_object* x_293; lean_object* x_294; lean_object* x_295; uint32_t x_296; uint32_t x_297; lean_object* x_298; lean_object* x_299; 
lean_dec(x_5);
lean_dec(x_4);
x_292 = lean_ctor_get(x_2, 0);
lean_inc(x_292);
x_293 = lean_ctor_get(x_2, 1);
lean_inc(x_293);
x_294 = lean_ctor_get(x_2, 2);
lean_inc(x_294);
lean_dec(x_2);
lean_inc(x_1);
x_295 = l_ZkRV32I_regRead(x_1, x_293);
x_296 = lean_unbox_uint32(x_295);
lean_dec(x_295);
x_297 = l_ZkRV32I_shiftRightLogical(x_296, x_294);
lean_dec(x_294);
x_298 = l_ZkRV32I_regWrite(x_1, x_9, x_292, x_297);
x_299 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_299, 0, x_298);
return x_299;
}
case 26:
{
lean_object* x_300; lean_object* x_301; lean_object* x_302; lean_object* x_303; uint32_t x_304; uint32_t x_305; lean_object* x_306; lean_object* x_307; 
lean_dec(x_5);
lean_dec(x_4);
x_300 = lean_ctor_get(x_2, 0);
lean_inc(x_300);
x_301 = lean_ctor_get(x_2, 1);
lean_inc(x_301);
x_302 = lean_ctor_get(x_2, 2);
lean_inc(x_302);
lean_dec(x_2);
lean_inc(x_1);
x_303 = l_ZkRV32I_regRead(x_1, x_301);
x_304 = lean_unbox_uint32(x_303);
lean_dec(x_303);
x_305 = l_ZkRV32I_shiftRightArithmetic(x_304, x_302);
lean_dec(x_302);
x_306 = l_ZkRV32I_regWrite(x_1, x_9, x_300, x_305);
x_307 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_307, 0, x_306);
return x_307;
}
case 27:
{
lean_object* x_308; lean_object* x_309; lean_object* x_310; lean_object* x_311; uint32_t x_312; lean_object* x_313; uint32_t x_314; uint32_t x_315; lean_object* x_316; lean_object* x_317; 
lean_dec(x_5);
lean_dec(x_4);
x_308 = lean_ctor_get(x_2, 0);
lean_inc(x_308);
x_309 = lean_ctor_get(x_2, 1);
lean_inc(x_309);
x_310 = lean_ctor_get(x_2, 2);
lean_inc(x_310);
lean_dec(x_2);
lean_inc(x_1);
x_311 = l_ZkRV32I_regRead(x_1, x_309);
x_312 = lean_unbox_uint32(x_311);
lean_dec(x_311);
lean_inc(x_1);
x_313 = l_ZkRV32I_regRead(x_1, x_310);
x_314 = lean_unbox_uint32(x_313);
lean_dec(x_313);
x_315 = lean_uint32_add(x_312, x_314);
x_316 = l_ZkRV32I_regWrite(x_1, x_9, x_308, x_315);
x_317 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_317, 0, x_316);
return x_317;
}
case 28:
{
lean_object* x_318; lean_object* x_319; lean_object* x_320; lean_object* x_321; uint32_t x_322; lean_object* x_323; uint32_t x_324; uint32_t x_325; lean_object* x_326; lean_object* x_327; 
lean_dec(x_5);
lean_dec(x_4);
x_318 = lean_ctor_get(x_2, 0);
lean_inc(x_318);
x_319 = lean_ctor_get(x_2, 1);
lean_inc(x_319);
x_320 = lean_ctor_get(x_2, 2);
lean_inc(x_320);
lean_dec(x_2);
lean_inc(x_1);
x_321 = l_ZkRV32I_regRead(x_1, x_319);
x_322 = lean_unbox_uint32(x_321);
lean_dec(x_321);
lean_inc(x_1);
x_323 = l_ZkRV32I_regRead(x_1, x_320);
x_324 = lean_unbox_uint32(x_323);
lean_dec(x_323);
x_325 = lean_uint32_sub(x_322, x_324);
x_326 = l_ZkRV32I_regWrite(x_1, x_9, x_318, x_325);
x_327 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_327, 0, x_326);
return x_327;
}
case 29:
{
lean_object* x_328; lean_object* x_329; lean_object* x_330; lean_object* x_331; uint32_t x_332; lean_object* x_333; uint32_t x_334; lean_object* x_335; uint32_t x_336; lean_object* x_337; lean_object* x_338; 
lean_dec(x_5);
lean_dec(x_4);
x_328 = lean_ctor_get(x_2, 0);
lean_inc(x_328);
x_329 = lean_ctor_get(x_2, 1);
lean_inc(x_329);
x_330 = lean_ctor_get(x_2, 2);
lean_inc(x_330);
lean_dec(x_2);
lean_inc(x_1);
x_331 = l_ZkRV32I_regRead(x_1, x_329);
x_332 = lean_unbox_uint32(x_331);
lean_dec(x_331);
lean_inc(x_1);
x_333 = l_ZkRV32I_regRead(x_1, x_330);
x_334 = lean_unbox_uint32(x_333);
lean_dec(x_333);
x_335 = lean_uint32_to_nat(x_334);
x_336 = l_ZkRV32I_shiftLeft(x_332, x_335);
lean_dec(x_335);
x_337 = l_ZkRV32I_regWrite(x_1, x_9, x_328, x_336);
x_338 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_338, 0, x_337);
return x_338;
}
case 30:
{
lean_object* x_339; lean_object* x_340; lean_object* x_341; lean_object* x_342; uint32_t x_343; lean_object* x_344; lean_object* x_345; uint32_t x_346; lean_object* x_347; uint8_t x_348; uint32_t x_349; lean_object* x_350; lean_object* x_351; 
lean_dec(x_5);
lean_dec(x_4);
x_339 = lean_ctor_get(x_2, 0);
lean_inc(x_339);
x_340 = lean_ctor_get(x_2, 1);
lean_inc(x_340);
x_341 = lean_ctor_get(x_2, 2);
lean_inc(x_341);
lean_dec(x_2);
lean_inc(x_1);
x_342 = l_ZkRV32I_regRead(x_1, x_340);
x_343 = lean_unbox_uint32(x_342);
lean_dec(x_342);
x_344 = l_ZkRV32I_Word32_signed(x_343);
lean_inc(x_1);
x_345 = l_ZkRV32I_regRead(x_1, x_341);
x_346 = lean_unbox_uint32(x_345);
lean_dec(x_345);
x_347 = l_ZkRV32I_Word32_signed(x_346);
x_348 = lean_int_dec_lt(x_344, x_347);
lean_dec(x_347);
lean_dec(x_344);
x_349 = l_ZkRV32I_boolWord(x_348);
x_350 = l_ZkRV32I_regWrite(x_1, x_9, x_339, x_349);
x_351 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_351, 0, x_350);
return x_351;
}
case 31:
{
lean_object* x_352; lean_object* x_353; lean_object* x_354; lean_object* x_355; uint32_t x_356; lean_object* x_357; uint32_t x_358; uint8_t x_359; uint32_t x_360; lean_object* x_361; lean_object* x_362; 
lean_dec(x_5);
lean_dec(x_4);
x_352 = lean_ctor_get(x_2, 0);
lean_inc(x_352);
x_353 = lean_ctor_get(x_2, 1);
lean_inc(x_353);
x_354 = lean_ctor_get(x_2, 2);
lean_inc(x_354);
lean_dec(x_2);
lean_inc(x_1);
x_355 = l_ZkRV32I_regRead(x_1, x_353);
x_356 = lean_unbox_uint32(x_355);
lean_dec(x_355);
lean_inc(x_1);
x_357 = l_ZkRV32I_regRead(x_1, x_354);
x_358 = lean_unbox_uint32(x_357);
lean_dec(x_357);
x_359 = lean_uint32_dec_lt(x_356, x_358);
x_360 = l_ZkRV32I_boolWord(x_359);
x_361 = l_ZkRV32I_regWrite(x_1, x_9, x_352, x_360);
x_362 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_362, 0, x_361);
return x_362;
}
case 32:
{
lean_object* x_363; lean_object* x_364; lean_object* x_365; lean_object* x_366; uint32_t x_367; lean_object* x_368; uint32_t x_369; uint32_t x_370; lean_object* x_371; lean_object* x_372; 
lean_dec(x_5);
lean_dec(x_4);
x_363 = lean_ctor_get(x_2, 0);
lean_inc(x_363);
x_364 = lean_ctor_get(x_2, 1);
lean_inc(x_364);
x_365 = lean_ctor_get(x_2, 2);
lean_inc(x_365);
lean_dec(x_2);
lean_inc(x_1);
x_366 = l_ZkRV32I_regRead(x_1, x_364);
x_367 = lean_unbox_uint32(x_366);
lean_dec(x_366);
lean_inc(x_1);
x_368 = l_ZkRV32I_regRead(x_1, x_365);
x_369 = lean_unbox_uint32(x_368);
lean_dec(x_368);
x_370 = l_ZkRV32I_wordXor(x_367, x_369);
x_371 = l_ZkRV32I_regWrite(x_1, x_9, x_363, x_370);
x_372 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_372, 0, x_371);
return x_372;
}
case 33:
{
lean_object* x_373; lean_object* x_374; lean_object* x_375; lean_object* x_376; uint32_t x_377; lean_object* x_378; uint32_t x_379; lean_object* x_380; uint32_t x_381; lean_object* x_382; lean_object* x_383; 
lean_dec(x_5);
lean_dec(x_4);
x_373 = lean_ctor_get(x_2, 0);
lean_inc(x_373);
x_374 = lean_ctor_get(x_2, 1);
lean_inc(x_374);
x_375 = lean_ctor_get(x_2, 2);
lean_inc(x_375);
lean_dec(x_2);
lean_inc(x_1);
x_376 = l_ZkRV32I_regRead(x_1, x_374);
x_377 = lean_unbox_uint32(x_376);
lean_dec(x_376);
lean_inc(x_1);
x_378 = l_ZkRV32I_regRead(x_1, x_375);
x_379 = lean_unbox_uint32(x_378);
lean_dec(x_378);
x_380 = lean_uint32_to_nat(x_379);
x_381 = l_ZkRV32I_shiftRightLogical(x_377, x_380);
lean_dec(x_380);
x_382 = l_ZkRV32I_regWrite(x_1, x_9, x_373, x_381);
x_383 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_383, 0, x_382);
return x_383;
}
case 34:
{
lean_object* x_384; lean_object* x_385; lean_object* x_386; lean_object* x_387; uint32_t x_388; lean_object* x_389; uint32_t x_390; lean_object* x_391; uint32_t x_392; lean_object* x_393; lean_object* x_394; 
lean_dec(x_5);
lean_dec(x_4);
x_384 = lean_ctor_get(x_2, 0);
lean_inc(x_384);
x_385 = lean_ctor_get(x_2, 1);
lean_inc(x_385);
x_386 = lean_ctor_get(x_2, 2);
lean_inc(x_386);
lean_dec(x_2);
lean_inc(x_1);
x_387 = l_ZkRV32I_regRead(x_1, x_385);
x_388 = lean_unbox_uint32(x_387);
lean_dec(x_387);
lean_inc(x_1);
x_389 = l_ZkRV32I_regRead(x_1, x_386);
x_390 = lean_unbox_uint32(x_389);
lean_dec(x_389);
x_391 = lean_uint32_to_nat(x_390);
x_392 = l_ZkRV32I_shiftRightArithmetic(x_388, x_391);
lean_dec(x_391);
x_393 = l_ZkRV32I_regWrite(x_1, x_9, x_384, x_392);
x_394 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_394, 0, x_393);
return x_394;
}
case 35:
{
lean_object* x_395; lean_object* x_396; lean_object* x_397; lean_object* x_398; uint32_t x_399; lean_object* x_400; uint32_t x_401; uint32_t x_402; lean_object* x_403; lean_object* x_404; 
lean_dec(x_5);
lean_dec(x_4);
x_395 = lean_ctor_get(x_2, 0);
lean_inc(x_395);
x_396 = lean_ctor_get(x_2, 1);
lean_inc(x_396);
x_397 = lean_ctor_get(x_2, 2);
lean_inc(x_397);
lean_dec(x_2);
lean_inc(x_1);
x_398 = l_ZkRV32I_regRead(x_1, x_396);
x_399 = lean_unbox_uint32(x_398);
lean_dec(x_398);
lean_inc(x_1);
x_400 = l_ZkRV32I_regRead(x_1, x_397);
x_401 = lean_unbox_uint32(x_400);
lean_dec(x_400);
x_402 = l_ZkRV32I_wordOr(x_399, x_401);
x_403 = l_ZkRV32I_regWrite(x_1, x_9, x_395, x_402);
x_404 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_404, 0, x_403);
return x_404;
}
case 36:
{
lean_object* x_405; lean_object* x_406; lean_object* x_407; lean_object* x_408; uint32_t x_409; lean_object* x_410; uint32_t x_411; uint32_t x_412; lean_object* x_413; lean_object* x_414; 
lean_dec(x_5);
lean_dec(x_4);
x_405 = lean_ctor_get(x_2, 0);
lean_inc(x_405);
x_406 = lean_ctor_get(x_2, 1);
lean_inc(x_406);
x_407 = lean_ctor_get(x_2, 2);
lean_inc(x_407);
lean_dec(x_2);
lean_inc(x_1);
x_408 = l_ZkRV32I_regRead(x_1, x_406);
x_409 = lean_unbox_uint32(x_408);
lean_dec(x_408);
lean_inc(x_1);
x_410 = l_ZkRV32I_regRead(x_1, x_407);
x_411 = lean_unbox_uint32(x_410);
lean_dec(x_410);
x_412 = l_ZkRV32I_wordAnd(x_409, x_411);
x_413 = l_ZkRV32I_regWrite(x_1, x_9, x_405, x_412);
x_414 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_414, 0, x_413);
return x_414;
}
case 37:
{
uint8_t x_415; 
x_415 = !lean_is_exclusive(x_1);
if (x_415 == 0)
{
lean_object* x_416; lean_object* x_417; lean_object* x_418; 
x_416 = lean_ctor_get(x_1, 1);
lean_dec(x_416);
x_417 = lean_ctor_get(x_1, 0);
lean_dec(x_417);
lean_ctor_set_uint32(x_1, sizeof(void*)*2, x_9);
x_418 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_418, 0, x_1);
return x_418;
}
else
{
lean_object* x_419; lean_object* x_420; 
lean_dec(x_1);
x_419 = lean_alloc_ctor(0, 2, 5);
lean_ctor_set(x_419, 0, x_4);
lean_ctor_set(x_419, 1, x_5);
lean_ctor_set_uint32(x_419, sizeof(void*)*2, x_9);
lean_ctor_set_uint8(x_419, sizeof(void*)*2 + 4, x_6);
x_420 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_420, 0, x_419);
return x_420;
}
}
default: 
{
uint8_t x_421; 
lean_dec(x_2);
x_421 = !lean_is_exclusive(x_1);
if (x_421 == 0)
{
lean_object* x_422; lean_object* x_423; lean_object* x_424; 
x_422 = lean_ctor_get(x_1, 1);
lean_dec(x_422);
x_423 = lean_ctor_get(x_1, 0);
lean_dec(x_423);
lean_ctor_set_uint8(x_1, sizeof(void*)*2 + 4, x_7);
x_424 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_424, 0, x_1);
return x_424;
}
else
{
lean_object* x_425; lean_object* x_426; 
lean_dec(x_1);
x_425 = lean_alloc_ctor(0, 2, 5);
lean_ctor_set(x_425, 0, x_4);
lean_ctor_set(x_425, 1, x_5);
lean_ctor_set_uint32(x_425, sizeof(void*)*2, x_3);
lean_ctor_set_uint8(x_425, sizeof(void*)*2 + 4, x_7);
x_426 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_426, 0, x_425);
return x_426;
}
}
}
}
else
{
lean_object* x_427; 
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_2);
lean_dec(x_1);
x_427 = lean_box(0);
return x_427;
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_execute(lean_object* x_1, uint32_t x_2) {
_start:
{
lean_object* x_3; 
x_3 = l_ZkRV32I_decode(x_2);
if (lean_obj_tag(x_3) == 0)
{
lean_object* x_4; 
lean_dec(x_3);
lean_dec(x_1);
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
x_7 = l_ZkRV32I_step(x_1, x_6);
if (lean_obj_tag(x_7) == 0)
{
lean_object* x_8; 
lean_free_object(x_3);
x_8 = lean_box(0);
return x_8;
}
else
{
uint8_t x_9; 
x_9 = !lean_is_exclusive(x_7);
if (x_9 == 0)
{
lean_object* x_10; uint8_t x_11; uint8_t x_12; uint8_t x_13; 
x_10 = lean_ctor_get(x_7, 0);
x_11 = lean_ctor_get_uint8(x_10, sizeof(void*)*2 + 4);
x_12 = 1;
x_13 = l_ZkRV32I_instDecidableEqTerminalState(x_11, x_12);
if (x_13 == 0)
{
lean_ctor_set_tag(x_3, 0);
lean_ctor_set(x_3, 0, x_10);
lean_ctor_set(x_7, 0, x_3);
return x_7;
}
else
{
lean_ctor_set(x_3, 0, x_10);
lean_ctor_set(x_7, 0, x_3);
return x_7;
}
}
else
{
lean_object* x_14; uint8_t x_15; uint8_t x_16; uint8_t x_17; 
x_14 = lean_ctor_get(x_7, 0);
lean_inc(x_14);
lean_dec(x_7);
x_15 = lean_ctor_get_uint8(x_14, sizeof(void*)*2 + 4);
x_16 = 1;
x_17 = l_ZkRV32I_instDecidableEqTerminalState(x_15, x_16);
if (x_17 == 0)
{
lean_object* x_18; 
lean_ctor_set_tag(x_3, 0);
lean_ctor_set(x_3, 0, x_14);
x_18 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_18, 0, x_3);
return x_18;
}
else
{
lean_object* x_19; 
lean_ctor_set(x_3, 0, x_14);
x_19 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_19, 0, x_3);
return x_19;
}
}
}
}
else
{
lean_object* x_20; lean_object* x_21; 
x_20 = lean_ctor_get(x_3, 0);
lean_inc(x_20);
lean_dec(x_3);
x_21 = l_ZkRV32I_step(x_1, x_20);
if (lean_obj_tag(x_21) == 0)
{
lean_object* x_22; 
x_22 = lean_box(0);
return x_22;
}
else
{
lean_object* x_23; lean_object* x_24; uint8_t x_25; uint8_t x_26; uint8_t x_27; 
x_23 = lean_ctor_get(x_21, 0);
lean_inc(x_23);
if (lean_is_exclusive(x_21)) {
 lean_ctor_release(x_21, 0);
 x_24 = x_21;
} else {
 lean_dec_ref(x_21);
 x_24 = lean_box(0);
}
x_25 = lean_ctor_get_uint8(x_23, sizeof(void*)*2 + 4);
x_26 = 1;
x_27 = l_ZkRV32I_instDecidableEqTerminalState(x_25, x_26);
if (x_27 == 0)
{
lean_object* x_28; lean_object* x_29; 
x_28 = lean_alloc_ctor(0, 1, 0);
lean_ctor_set(x_28, 0, x_23);
if (lean_is_scalar(x_24)) {
 x_29 = lean_alloc_ctor(1, 1, 0);
} else {
 x_29 = x_24;
}
lean_ctor_set(x_29, 0, x_28);
return x_29;
}
else
{
lean_object* x_30; lean_object* x_31; 
x_30 = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(x_30, 0, x_23);
if (lean_is_scalar(x_24)) {
 x_31 = lean_alloc_ctor(1, 1, 0);
} else {
 x_31 = x_24;
}
lean_ctor_set(x_31, 0, x_30);
return x_31;
}
}
}
}
}
}
LEAN_EXPORT lean_object* l_ZkRV32I_execute___boxed(lean_object* x_1, lean_object* x_2) {
_start:
{
uint32_t x_3; lean_object* x_4; 
x_3 = lean_unbox_uint32(x_2);
lean_dec(x_2);
x_4 = l_ZkRV32I_execute(x_1, x_3);
return x_4;
}
}
LEAN_EXPORT lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_step_match__1_splitter___rarg(lean_object* x_1, lean_object* x_2, lean_object* x_3, lean_object* x_4, lean_object* x_5, lean_object* x_6, lean_object* x_7, lean_object* x_8, lean_object* x_9, lean_object* x_10, lean_object* x_11, lean_object* x_12, lean_object* x_13, lean_object* x_14, lean_object* x_15, lean_object* x_16, lean_object* x_17, lean_object* x_18, lean_object* x_19, lean_object* x_20, lean_object* x_21, lean_object* x_22, lean_object* x_23, lean_object* x_24, lean_object* x_25, lean_object* x_26, lean_object* x_27, lean_object* x_28, lean_object* x_29, lean_object* x_30, lean_object* x_31, lean_object* x_32, lean_object* x_33, lean_object* x_34, lean_object* x_35, lean_object* x_36, lean_object* x_37, lean_object* x_38, lean_object* x_39, lean_object* x_40, lean_object* x_41) {
_start:
{
switch (lean_obj_tag(x_1)) {
case 0:
{
lean_object* x_42; uint32_t x_43; lean_object* x_44; lean_object* x_45; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
x_42 = lean_ctor_get(x_1, 0);
lean_inc(x_42);
x_43 = lean_ctor_get_uint32(x_1, sizeof(void*)*1);
lean_dec(x_1);
x_44 = lean_box_uint32(x_43);
x_45 = lean_apply_2(x_2, x_42, x_44);
return x_45;
}
case 1:
{
lean_object* x_46; uint32_t x_47; lean_object* x_48; lean_object* x_49; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_2);
x_46 = lean_ctor_get(x_1, 0);
lean_inc(x_46);
x_47 = lean_ctor_get_uint32(x_1, sizeof(void*)*1);
lean_dec(x_1);
x_48 = lean_box_uint32(x_47);
x_49 = lean_apply_2(x_3, x_46, x_48);
return x_49;
}
case 2:
{
lean_object* x_50; uint32_t x_51; lean_object* x_52; lean_object* x_53; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_3);
lean_dec(x_2);
x_50 = lean_ctor_get(x_1, 0);
lean_inc(x_50);
x_51 = lean_ctor_get_uint32(x_1, sizeof(void*)*1);
lean_dec(x_1);
x_52 = lean_box_uint32(x_51);
x_53 = lean_apply_2(x_4, x_50, x_52);
return x_53;
}
case 3:
{
lean_object* x_54; lean_object* x_55; uint32_t x_56; lean_object* x_57; lean_object* x_58; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_54 = lean_ctor_get(x_1, 0);
lean_inc(x_54);
x_55 = lean_ctor_get(x_1, 1);
lean_inc(x_55);
x_56 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_57 = lean_box_uint32(x_56);
x_58 = lean_apply_3(x_5, x_54, x_55, x_57);
return x_58;
}
case 4:
{
lean_object* x_59; lean_object* x_60; uint32_t x_61; lean_object* x_62; lean_object* x_63; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_59 = lean_ctor_get(x_1, 0);
lean_inc(x_59);
x_60 = lean_ctor_get(x_1, 1);
lean_inc(x_60);
x_61 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_62 = lean_box_uint32(x_61);
x_63 = lean_apply_3(x_6, x_59, x_60, x_62);
return x_63;
}
case 5:
{
lean_object* x_64; lean_object* x_65; uint32_t x_66; lean_object* x_67; lean_object* x_68; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_64 = lean_ctor_get(x_1, 0);
lean_inc(x_64);
x_65 = lean_ctor_get(x_1, 1);
lean_inc(x_65);
x_66 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_67 = lean_box_uint32(x_66);
x_68 = lean_apply_3(x_7, x_64, x_65, x_67);
return x_68;
}
case 6:
{
lean_object* x_69; lean_object* x_70; uint32_t x_71; lean_object* x_72; lean_object* x_73; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_69 = lean_ctor_get(x_1, 0);
lean_inc(x_69);
x_70 = lean_ctor_get(x_1, 1);
lean_inc(x_70);
x_71 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_72 = lean_box_uint32(x_71);
x_73 = lean_apply_3(x_8, x_69, x_70, x_72);
return x_73;
}
case 7:
{
lean_object* x_74; lean_object* x_75; uint32_t x_76; lean_object* x_77; lean_object* x_78; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_74 = lean_ctor_get(x_1, 0);
lean_inc(x_74);
x_75 = lean_ctor_get(x_1, 1);
lean_inc(x_75);
x_76 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_77 = lean_box_uint32(x_76);
x_78 = lean_apply_3(x_9, x_74, x_75, x_77);
return x_78;
}
case 8:
{
lean_object* x_79; lean_object* x_80; uint32_t x_81; lean_object* x_82; lean_object* x_83; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_79 = lean_ctor_get(x_1, 0);
lean_inc(x_79);
x_80 = lean_ctor_get(x_1, 1);
lean_inc(x_80);
x_81 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_82 = lean_box_uint32(x_81);
x_83 = lean_apply_3(x_10, x_79, x_80, x_82);
return x_83;
}
case 9:
{
lean_object* x_84; lean_object* x_85; uint32_t x_86; lean_object* x_87; lean_object* x_88; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_84 = lean_ctor_get(x_1, 0);
lean_inc(x_84);
x_85 = lean_ctor_get(x_1, 1);
lean_inc(x_85);
x_86 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_87 = lean_box_uint32(x_86);
x_88 = lean_apply_3(x_11, x_84, x_85, x_87);
return x_88;
}
case 10:
{
lean_object* x_89; lean_object* x_90; uint32_t x_91; lean_object* x_92; lean_object* x_93; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_89 = lean_ctor_get(x_1, 0);
lean_inc(x_89);
x_90 = lean_ctor_get(x_1, 1);
lean_inc(x_90);
x_91 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_92 = lean_box_uint32(x_91);
x_93 = lean_apply_3(x_12, x_89, x_90, x_92);
return x_93;
}
case 11:
{
lean_object* x_94; lean_object* x_95; uint32_t x_96; lean_object* x_97; lean_object* x_98; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_94 = lean_ctor_get(x_1, 0);
lean_inc(x_94);
x_95 = lean_ctor_get(x_1, 1);
lean_inc(x_95);
x_96 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_97 = lean_box_uint32(x_96);
x_98 = lean_apply_3(x_13, x_94, x_95, x_97);
return x_98;
}
case 12:
{
lean_object* x_99; lean_object* x_100; uint32_t x_101; lean_object* x_102; lean_object* x_103; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_99 = lean_ctor_get(x_1, 0);
lean_inc(x_99);
x_100 = lean_ctor_get(x_1, 1);
lean_inc(x_100);
x_101 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_102 = lean_box_uint32(x_101);
x_103 = lean_apply_3(x_14, x_99, x_100, x_102);
return x_103;
}
case 13:
{
lean_object* x_104; lean_object* x_105; uint32_t x_106; lean_object* x_107; lean_object* x_108; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_104 = lean_ctor_get(x_1, 0);
lean_inc(x_104);
x_105 = lean_ctor_get(x_1, 1);
lean_inc(x_105);
x_106 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_107 = lean_box_uint32(x_106);
x_108 = lean_apply_3(x_15, x_104, x_105, x_107);
return x_108;
}
case 14:
{
lean_object* x_109; lean_object* x_110; uint32_t x_111; lean_object* x_112; lean_object* x_113; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_109 = lean_ctor_get(x_1, 0);
lean_inc(x_109);
x_110 = lean_ctor_get(x_1, 1);
lean_inc(x_110);
x_111 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_112 = lean_box_uint32(x_111);
x_113 = lean_apply_3(x_16, x_109, x_110, x_112);
return x_113;
}
case 15:
{
lean_object* x_114; lean_object* x_115; uint32_t x_116; lean_object* x_117; lean_object* x_118; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_114 = lean_ctor_get(x_1, 0);
lean_inc(x_114);
x_115 = lean_ctor_get(x_1, 1);
lean_inc(x_115);
x_116 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_117 = lean_box_uint32(x_116);
x_118 = lean_apply_3(x_17, x_114, x_115, x_117);
return x_118;
}
case 16:
{
lean_object* x_119; lean_object* x_120; uint32_t x_121; lean_object* x_122; lean_object* x_123; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_119 = lean_ctor_get(x_1, 0);
lean_inc(x_119);
x_120 = lean_ctor_get(x_1, 1);
lean_inc(x_120);
x_121 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_122 = lean_box_uint32(x_121);
x_123 = lean_apply_3(x_18, x_119, x_120, x_122);
return x_123;
}
case 17:
{
lean_object* x_124; lean_object* x_125; uint32_t x_126; lean_object* x_127; lean_object* x_128; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_124 = lean_ctor_get(x_1, 0);
lean_inc(x_124);
x_125 = lean_ctor_get(x_1, 1);
lean_inc(x_125);
x_126 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_127 = lean_box_uint32(x_126);
x_128 = lean_apply_3(x_19, x_124, x_125, x_127);
return x_128;
}
case 18:
{
lean_object* x_129; lean_object* x_130; uint32_t x_131; lean_object* x_132; lean_object* x_133; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_129 = lean_ctor_get(x_1, 0);
lean_inc(x_129);
x_130 = lean_ctor_get(x_1, 1);
lean_inc(x_130);
x_131 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_132 = lean_box_uint32(x_131);
x_133 = lean_apply_3(x_20, x_129, x_130, x_132);
return x_133;
}
case 19:
{
lean_object* x_134; lean_object* x_135; uint32_t x_136; lean_object* x_137; lean_object* x_138; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_134 = lean_ctor_get(x_1, 0);
lean_inc(x_134);
x_135 = lean_ctor_get(x_1, 1);
lean_inc(x_135);
x_136 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_137 = lean_box_uint32(x_136);
x_138 = lean_apply_3(x_21, x_134, x_135, x_137);
return x_138;
}
case 20:
{
lean_object* x_139; lean_object* x_140; uint32_t x_141; lean_object* x_142; lean_object* x_143; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_139 = lean_ctor_get(x_1, 0);
lean_inc(x_139);
x_140 = lean_ctor_get(x_1, 1);
lean_inc(x_140);
x_141 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_142 = lean_box_uint32(x_141);
x_143 = lean_apply_3(x_22, x_139, x_140, x_142);
return x_143;
}
case 21:
{
lean_object* x_144; lean_object* x_145; uint32_t x_146; lean_object* x_147; lean_object* x_148; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_144 = lean_ctor_get(x_1, 0);
lean_inc(x_144);
x_145 = lean_ctor_get(x_1, 1);
lean_inc(x_145);
x_146 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_147 = lean_box_uint32(x_146);
x_148 = lean_apply_3(x_23, x_144, x_145, x_147);
return x_148;
}
case 22:
{
lean_object* x_149; lean_object* x_150; uint32_t x_151; lean_object* x_152; lean_object* x_153; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_149 = lean_ctor_get(x_1, 0);
lean_inc(x_149);
x_150 = lean_ctor_get(x_1, 1);
lean_inc(x_150);
x_151 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_152 = lean_box_uint32(x_151);
x_153 = lean_apply_3(x_24, x_149, x_150, x_152);
return x_153;
}
case 23:
{
lean_object* x_154; lean_object* x_155; uint32_t x_156; lean_object* x_157; lean_object* x_158; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_154 = lean_ctor_get(x_1, 0);
lean_inc(x_154);
x_155 = lean_ctor_get(x_1, 1);
lean_inc(x_155);
x_156 = lean_ctor_get_uint32(x_1, sizeof(void*)*2);
lean_dec(x_1);
x_157 = lean_box_uint32(x_156);
x_158 = lean_apply_3(x_25, x_154, x_155, x_157);
return x_158;
}
case 24:
{
lean_object* x_159; lean_object* x_160; lean_object* x_161; lean_object* x_162; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_159 = lean_ctor_get(x_1, 0);
lean_inc(x_159);
x_160 = lean_ctor_get(x_1, 1);
lean_inc(x_160);
x_161 = lean_ctor_get(x_1, 2);
lean_inc(x_161);
lean_dec(x_1);
x_162 = lean_apply_3(x_26, x_159, x_160, x_161);
return x_162;
}
case 25:
{
lean_object* x_163; lean_object* x_164; lean_object* x_165; lean_object* x_166; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_163 = lean_ctor_get(x_1, 0);
lean_inc(x_163);
x_164 = lean_ctor_get(x_1, 1);
lean_inc(x_164);
x_165 = lean_ctor_get(x_1, 2);
lean_inc(x_165);
lean_dec(x_1);
x_166 = lean_apply_3(x_27, x_163, x_164, x_165);
return x_166;
}
case 26:
{
lean_object* x_167; lean_object* x_168; lean_object* x_169; lean_object* x_170; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_167 = lean_ctor_get(x_1, 0);
lean_inc(x_167);
x_168 = lean_ctor_get(x_1, 1);
lean_inc(x_168);
x_169 = lean_ctor_get(x_1, 2);
lean_inc(x_169);
lean_dec(x_1);
x_170 = lean_apply_3(x_28, x_167, x_168, x_169);
return x_170;
}
case 27:
{
lean_object* x_171; lean_object* x_172; lean_object* x_173; lean_object* x_174; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_171 = lean_ctor_get(x_1, 0);
lean_inc(x_171);
x_172 = lean_ctor_get(x_1, 1);
lean_inc(x_172);
x_173 = lean_ctor_get(x_1, 2);
lean_inc(x_173);
lean_dec(x_1);
x_174 = lean_apply_3(x_29, x_171, x_172, x_173);
return x_174;
}
case 28:
{
lean_object* x_175; lean_object* x_176; lean_object* x_177; lean_object* x_178; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_175 = lean_ctor_get(x_1, 0);
lean_inc(x_175);
x_176 = lean_ctor_get(x_1, 1);
lean_inc(x_176);
x_177 = lean_ctor_get(x_1, 2);
lean_inc(x_177);
lean_dec(x_1);
x_178 = lean_apply_3(x_30, x_175, x_176, x_177);
return x_178;
}
case 29:
{
lean_object* x_179; lean_object* x_180; lean_object* x_181; lean_object* x_182; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_179 = lean_ctor_get(x_1, 0);
lean_inc(x_179);
x_180 = lean_ctor_get(x_1, 1);
lean_inc(x_180);
x_181 = lean_ctor_get(x_1, 2);
lean_inc(x_181);
lean_dec(x_1);
x_182 = lean_apply_3(x_31, x_179, x_180, x_181);
return x_182;
}
case 30:
{
lean_object* x_183; lean_object* x_184; lean_object* x_185; lean_object* x_186; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_183 = lean_ctor_get(x_1, 0);
lean_inc(x_183);
x_184 = lean_ctor_get(x_1, 1);
lean_inc(x_184);
x_185 = lean_ctor_get(x_1, 2);
lean_inc(x_185);
lean_dec(x_1);
x_186 = lean_apply_3(x_32, x_183, x_184, x_185);
return x_186;
}
case 31:
{
lean_object* x_187; lean_object* x_188; lean_object* x_189; lean_object* x_190; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_187 = lean_ctor_get(x_1, 0);
lean_inc(x_187);
x_188 = lean_ctor_get(x_1, 1);
lean_inc(x_188);
x_189 = lean_ctor_get(x_1, 2);
lean_inc(x_189);
lean_dec(x_1);
x_190 = lean_apply_3(x_33, x_187, x_188, x_189);
return x_190;
}
case 32:
{
lean_object* x_191; lean_object* x_192; lean_object* x_193; lean_object* x_194; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_191 = lean_ctor_get(x_1, 0);
lean_inc(x_191);
x_192 = lean_ctor_get(x_1, 1);
lean_inc(x_192);
x_193 = lean_ctor_get(x_1, 2);
lean_inc(x_193);
lean_dec(x_1);
x_194 = lean_apply_3(x_34, x_191, x_192, x_193);
return x_194;
}
case 33:
{
lean_object* x_195; lean_object* x_196; lean_object* x_197; lean_object* x_198; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_195 = lean_ctor_get(x_1, 0);
lean_inc(x_195);
x_196 = lean_ctor_get(x_1, 1);
lean_inc(x_196);
x_197 = lean_ctor_get(x_1, 2);
lean_inc(x_197);
lean_dec(x_1);
x_198 = lean_apply_3(x_35, x_195, x_196, x_197);
return x_198;
}
case 34:
{
lean_object* x_199; lean_object* x_200; lean_object* x_201; lean_object* x_202; 
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_199 = lean_ctor_get(x_1, 0);
lean_inc(x_199);
x_200 = lean_ctor_get(x_1, 1);
lean_inc(x_200);
x_201 = lean_ctor_get(x_1, 2);
lean_inc(x_201);
lean_dec(x_1);
x_202 = lean_apply_3(x_36, x_199, x_200, x_201);
return x_202;
}
case 35:
{
lean_object* x_203; lean_object* x_204; lean_object* x_205; lean_object* x_206; 
lean_dec(x_38);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_203 = lean_ctor_get(x_1, 0);
lean_inc(x_203);
x_204 = lean_ctor_get(x_1, 1);
lean_inc(x_204);
x_205 = lean_ctor_get(x_1, 2);
lean_inc(x_205);
lean_dec(x_1);
x_206 = lean_apply_3(x_37, x_203, x_204, x_205);
return x_206;
}
case 36:
{
lean_object* x_207; lean_object* x_208; lean_object* x_209; lean_object* x_210; 
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
x_207 = lean_ctor_get(x_1, 0);
lean_inc(x_207);
x_208 = lean_ctor_get(x_1, 1);
lean_inc(x_208);
x_209 = lean_ctor_get(x_1, 2);
lean_inc(x_209);
lean_dec(x_1);
x_210 = lean_apply_3(x_38, x_207, x_208, x_209);
return x_210;
}
case 37:
{
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
lean_inc(x_39);
return x_39;
}
case 38:
{
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
lean_inc(x_40);
return x_40;
}
default: 
{
lean_dec(x_38);
lean_dec(x_37);
lean_dec(x_36);
lean_dec(x_35);
lean_dec(x_34);
lean_dec(x_33);
lean_dec(x_32);
lean_dec(x_31);
lean_dec(x_30);
lean_dec(x_29);
lean_dec(x_28);
lean_dec(x_27);
lean_dec(x_26);
lean_dec(x_25);
lean_dec(x_24);
lean_dec(x_23);
lean_dec(x_22);
lean_dec(x_21);
lean_dec(x_20);
lean_dec(x_19);
lean_dec(x_18);
lean_dec(x_17);
lean_dec(x_16);
lean_dec(x_15);
lean_dec(x_14);
lean_dec(x_13);
lean_dec(x_12);
lean_dec(x_11);
lean_dec(x_10);
lean_dec(x_9);
lean_dec(x_8);
lean_dec(x_7);
lean_dec(x_6);
lean_dec(x_5);
lean_dec(x_4);
lean_dec(x_3);
lean_dec(x_2);
lean_inc(x_41);
return x_41;
}
}
}
}
LEAN_EXPORT lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_step_match__1_splitter(lean_object* x_1) {
_start:
{
lean_object* x_2; 
x_2 = lean_alloc_closure((void*)(l___private_ZkRV32I_Machine_0__ZkRV32I_step_match__1_splitter___rarg___boxed), 41, 0);
return x_2;
}
}
LEAN_EXPORT lean_object* l___private_ZkRV32I_Machine_0__ZkRV32I_step_match__1_splitter___rarg___boxed(lean_object** _args) {
lean_object* x_1 = _args[0];
lean_object* x_2 = _args[1];
lean_object* x_3 = _args[2];
lean_object* x_4 = _args[3];
lean_object* x_5 = _args[4];
lean_object* x_6 = _args[5];
lean_object* x_7 = _args[6];
lean_object* x_8 = _args[7];
lean_object* x_9 = _args[8];
lean_object* x_10 = _args[9];
lean_object* x_11 = _args[10];
lean_object* x_12 = _args[11];
lean_object* x_13 = _args[12];
lean_object* x_14 = _args[13];
lean_object* x_15 = _args[14];
lean_object* x_16 = _args[15];
lean_object* x_17 = _args[16];
lean_object* x_18 = _args[17];
lean_object* x_19 = _args[18];
lean_object* x_20 = _args[19];
lean_object* x_21 = _args[20];
lean_object* x_22 = _args[21];
lean_object* x_23 = _args[22];
lean_object* x_24 = _args[23];
lean_object* x_25 = _args[24];
lean_object* x_26 = _args[25];
lean_object* x_27 = _args[26];
lean_object* x_28 = _args[27];
lean_object* x_29 = _args[28];
lean_object* x_30 = _args[29];
lean_object* x_31 = _args[30];
lean_object* x_32 = _args[31];
lean_object* x_33 = _args[32];
lean_object* x_34 = _args[33];
lean_object* x_35 = _args[34];
lean_object* x_36 = _args[35];
lean_object* x_37 = _args[36];
lean_object* x_38 = _args[37];
lean_object* x_39 = _args[38];
lean_object* x_40 = _args[39];
lean_object* x_41 = _args[40];
_start:
{
lean_object* x_42; 
x_42 = l___private_ZkRV32I_Machine_0__ZkRV32I_step_match__1_splitter___rarg(x_1, x_2, x_3, x_4, x_5, x_6, x_7, x_8, x_9, x_10, x_11, x_12, x_13, x_14, x_15, x_16, x_17, x_18, x_19, x_20, x_21, x_22, x_23, x_24, x_25, x_26, x_27, x_28, x_29, x_30, x_31, x_32, x_33, x_34, x_35, x_36, x_37, x_38, x_39, x_40, x_41);
lean_dec(x_41);
lean_dec(x_40);
lean_dec(x_39);
return x_42;
}
}
lean_object* initialize_Init(uint8_t builtin, lean_object*);
lean_object* initialize_ZkRV32I_ISA(uint8_t builtin, lean_object*);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_ZkRV32I_Machine(uint8_t builtin, lean_object* w) {
lean_object * res;
if (_G_initialized) return lean_io_result_mk_ok(lean_box(0));
_G_initialized = true;
res = initialize_Init(builtin, lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_ZkRV32I_ISA(builtin, lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
l_ZkRV32I_TerminalState_noConfusion___rarg___closed__1 = _init_l_ZkRV32I_TerminalState_noConfusion___rarg___closed__1();
lean_mark_persistent(l_ZkRV32I_TerminalState_noConfusion___rarg___closed__1);
l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__1 = _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__1();
lean_mark_persistent(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__1);
l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__2 = _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__2();
lean_mark_persistent(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__2);
l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__3 = _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__3();
lean_mark_persistent(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__3);
l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__4 = _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__4();
lean_mark_persistent(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__4);
l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__5 = _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__5();
lean_mark_persistent(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__5);
l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__6 = _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__6();
lean_mark_persistent(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__6);
l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__7 = _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__7();
lean_mark_persistent(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__7);
l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__8 = _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__8();
lean_mark_persistent(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__8);
l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__9 = _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__9();
lean_mark_persistent(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__9);
l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__10 = _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__10();
lean_mark_persistent(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__10);
l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__11 = _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__11();
lean_mark_persistent(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__11);
l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__12 = _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__12();
lean_mark_persistent(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__12);
l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__13 = _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__13();
lean_mark_persistent(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__13);
l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__14 = _init_l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__14();
lean_mark_persistent(l___private_ZkRV32I_Machine_0__ZkRV32I_reprTerminalState____x40_ZkRV32I_Machine___hyg_108____closed__14);
l_ZkRV32I_instReprTerminalState___closed__1 = _init_l_ZkRV32I_instReprTerminalState___closed__1();
lean_mark_persistent(l_ZkRV32I_instReprTerminalState___closed__1);
l_ZkRV32I_instReprTerminalState = _init_l_ZkRV32I_instReprTerminalState();
lean_mark_persistent(l_ZkRV32I_instReprTerminalState);
l_ZkRV32I_shiftRightArithmetic___closed__1 = _init_l_ZkRV32I_shiftRightArithmetic___closed__1();
lean_mark_persistent(l_ZkRV32I_shiftRightArithmetic___closed__1);
return lean_io_result_mk_ok(lean_box(0));
}
#ifdef __cplusplus
}
#endif
