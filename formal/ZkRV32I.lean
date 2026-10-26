import ZkRV32I.Circuit.Constraints
import ZkRV32I.Refinement.Step
import ZkRV32I.Source
import ZkRV32I.Hardware.SingleCycle
import ZkRV32I.Refinement.Memory
import ZkRV32I.Binary

export ZkRV32I (Word32 RegisterFile Memory Instruction MachineState TerminalState
  ExecutionOutcome DecodeError decode step MAX_TRACE Row Trace initial terminal valid_transition
  valid_trace)

export ZkRV32I.Hardware (ALUControl aluExecute selectALUInputs
  singleCycleALUStep singleCycleALUStep_refines_step)

export ZkRV32I.Circuit (FieldElem PublicInputs AlgebraicGate PrivateWitness encode
  publicInputsFor boundaryConstraints transitionConstraints rangeCheckConstraints
  aluConstraints branchConstraints memoryConstraints publicOutputConstraints
  constraintsSatisfied)

export ZkRV32I.Refinement (RustState RustInstruction interpret related
  encodeInstruction rustStepSpec RustFiniteState RustFiniteState.toLean
  finiteRelated rustFiniteStepSpec rustFiniteInterpreterStep
  isCoveredInstruction)

export ZkRV32I.Refinement (RustSourceState rustSourceStep
  rust_to_rv32i_refinement rustSourceStore_success_validRange)

export ZkRV32I.Refinement (RustMemory RustMemoryError RustMemory.Refines
  RustMemory.toLean RustMemory.ofLean RustMemory.checkedOffset RustMemory.load
  RustMemory.store rustUsizeMax)

export ZkRV32I.Binary (ELF32Header ELF32ProgramHeader ELF32Image
  readU16LE readU32LE parseELF32Header parseELF32ProgramHeader
  readELF32ProgramHeaders parseELF32 loadSegment loadELF32Segments
  ELF32Image.loadMemory segmentFits segmentFits_preserves_address_bounds
  loadSegment_success_preserves_geometry loadSegment_success_has_bounded_addresses
  decodeBitVec32 fetch32 fetchDecode binaryStep binaryValidTransition
  fetchDecode_uses_isa_decoder binaryStep_success_is_binaryValidTransition
  binaryValidTransition_implies_valid_transition binaryValidTrace
  binaryValidTrace_implies_valid_trace)

theorem x0_preserved_by_step (s : MachineState) (i : Instruction) (s' : MachineState)
    (_h : step s i = some s') : s'.regs.x0 = 0 := by
  rfl
