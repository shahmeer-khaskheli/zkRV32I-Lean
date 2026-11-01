// Lean compiler output
// Module: ZkRV32I.Source
// Imports: Init ZkRV32I.Refinement.Step
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
lean_object* l_ZkRV32I_Refinement_rustFiniteStepSpec(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Refinement_rustSourceStep(lean_object*, lean_object*, lean_object*);
lean_object* l_ZkRV32I_Refinement_encodeInstruction(lean_object*);
LEAN_EXPORT lean_object* l_ZkRV32I_Refinement_rustSourceStep(lean_object* x_1, lean_object* x_2, lean_object* x_3) {
_start:
{
lean_object* x_4; lean_object* x_5; 
x_4 = l_ZkRV32I_Refinement_encodeInstruction(x_3);
x_5 = l_ZkRV32I_Refinement_rustFiniteStepSpec(x_1, x_2, x_4);
return x_5;
}
}
lean_object* initialize_Init(uint8_t builtin, lean_object*);
lean_object* initialize_ZkRV32I_Refinement_Step(uint8_t builtin, lean_object*);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_ZkRV32I_Source(uint8_t builtin, lean_object* w) {
lean_object * res;
if (_G_initialized) return lean_io_result_mk_ok(lean_box(0));
_G_initialized = true;
res = initialize_Init(builtin, lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_ZkRV32I_Refinement_Step(builtin, lean_io_mk_world());
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
return lean_io_result_mk_ok(lean_box(0));
}
#ifdef __cplusplus
}
#endif
