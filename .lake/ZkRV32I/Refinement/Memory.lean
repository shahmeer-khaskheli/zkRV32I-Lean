import ZkRV32I.Base

namespace ZkRV32I.Refinement

open ZkRV32I

structure RustMemory (size : Nat) where
  base : Word32
  bytes : Fin size → UInt8

def RustMemory.byteAt {size : Nat} (memory : RustMemory size) (index : Nat) : UInt8 :=
  if h : index < size then memory.bytes ⟨index, h⟩ else 0

def RustMemory.toLean {size : Nat} (memory : RustMemory size) : Memory :=
  ⟨memory.base, size, memory.byteAt⟩

def RustMemory.ofLean (size : Nat) (memory : Memory) : RustMemory size :=
  ⟨memory.base, fun index => memory.bytes index.val⟩

def RustMemory.Refines {size : Nat} (rust : RustMemory size) (lean : Memory) : Prop :=
  lean.base = rust.base ∧
    lean.size = size ∧
    ∀ index (hindex : index < size),
      lean.bytes index = rust.bytes ⟨index, hindex⟩

theorem rustMemory_toLean_refines {size : Nat} (memory : RustMemory size) :
    memory.Refines memory.toLean := by
  refine ⟨rfl, rfl, ?_⟩
  intro index hindex
  simp [RustMemory.toLean, RustMemory.byteAt, hindex]

theorem ofLean_toLean_bytes_identity {size : Nat} (memory : RustMemory size) :
    RustMemory.ofLean size memory.toLean = memory := by
  cases memory with
  | mk base bytes =>
      apply congrArg (fun values => RustMemory.mk base values)
      funext index
      simp [RustMemory.ofLean, RustMemory.toLean, RustMemory.byteAt, index.isLt]

theorem lean_toRust_refines {size : Nat} (memory : Memory) (hsize : memory.size = size) :
    (RustMemory.ofLean size memory).Refines memory := by
  refine ⟨rfl, hsize, ?_⟩
  intro index hindex
  rfl

inductive RustMemoryError where
  | outOfBounds
  | misaligned
  | addressOverflow
  deriving DecidableEq, Repr

/-- `usize::MAX` for the x86_64 target used by the pinned Rust toolchain. -/
def rustUsizeMax : Nat := 2 ^ 64 - 1

theorem checkedOffset_end_fits_usize64 (base : Word32) (address width : Nat)
    (hbase : base.toNat ≤ address) (hwidth : 0 < width)
    (haddress : address + (width - 1) < 4294967296) :
    address - base.toNat + width ≤ rustUsizeMax := by
  simp [rustUsizeMax]
  omega

/-- The checked-offset behavior for the supported 64-bit target profile. -/
def RustMemory.checkedOffset (size : Nat) (base : Word32) (address width alignment : Nat) :
    Except RustMemoryError Nat :=
  if alignment > 1 && address % alignment != 0 then
    .error .misaligned
  else if width = 0 then
    .error .outOfBounds
  else if base.toNat > address then
    .error .outOfBounds
  else if address + (width - 1) ≥ 4294967296 then
    .error .addressOverflow
  else if address - base.toNat + width > size then
    .error .outOfBounds
  else
    .ok (address - base.toNat)

theorem checkedOffset_success_iff_validRange
    (size : Nat) (base : Word32) (address width alignment : Nat) :
    (RustMemory.checkedOffset size base address width alignment).isOk =
      Memory.validRange ⟨base, size, fun _ => 0⟩ address width alignment := by
  by_cases hmis : alignment > 1 && address % alignment != 0
  · simp [RustMemory.checkedOffset, Memory.validRange, Except.isOk, Except.toBool, hmis]
  · by_cases hw : width = 0
    · simp [RustMemory.checkedOffset, Memory.validRange, Except.isOk, Except.toBool, hmis, hw]
    · by_cases hbase : base.toNat > address
      · simp [RustMemory.checkedOffset, Memory.validRange, Except.isOk, Except.toBool,
          hmis, hw, hbase]
      · by_cases hoverflow : address + (width - 1) ≥ 4294967296
        · simp [RustMemory.checkedOffset, Memory.validRange, Except.isOk, Except.toBool,
            hmis, hw, hbase, hoverflow]
        · by_cases hsize : size < address - base.toNat + width
          · simp [RustMemory.checkedOffset, Memory.validRange, Except.isOk, Except.toBool,
              hmis, hw, hbase, hoverflow, hsize]
          · simp [RustMemory.checkedOffset, Memory.validRange, Except.isOk, Except.toBool,
              hmis, hw, hbase, hoverflow, hsize] <;> omega

def RustMemory.littleEndianValue (memory : RustMemory size) (offset width : Nat) : Nat :=
  (List.range width).foldl
    (fun acc byteIndex =>
      acc + (memory.byteAt (offset + byteIndex)).toNat * 256 ^ byteIndex) 0

def RustMemory.load (memory : RustMemory size) (address width alignment : Nat) :
    Option Word32 :=
  if Memory.validRange memory.toLean address width alignment then
    some (Word32.ofNat
      (memory.littleEndianValue (address - memory.base.toNat) width))
  else
    none

theorem rustLoad_matches_leanLoad {size : Nat} (rust : RustMemory size)
    (address width alignment : Nat) :
    rust.load address width alignment =
      Memory.load rust.toLean address width alignment := by
  simp [RustMemory.load, RustMemory.littleEndianValue, Memory.load,
    Memory.littleEndianValue, RustMemory.toLean, RustMemory.byteAt]

theorem rustLoad_u8_littleEndian {size : Nat} (rust : RustMemory size)
    (address : Nat) (hvalid : Memory.validRange rust.toLean address 1 1) :
    rust.load address 1 1 =
      some (Word32.ofNat
        (rust.littleEndianValue (address - rust.base.toNat) 1)) := by
  simp [RustMemory.load, hvalid]

theorem rustLoad_u16_littleEndian {size : Nat} (rust : RustMemory size)
    (address : Nat) (hvalid : Memory.validRange rust.toLean address 2 2) :
    rust.load address 2 2 =
      some (Word32.ofNat
        (rust.littleEndianValue (address - rust.base.toNat) 2)) := by
  simp [RustMemory.load, hvalid]

theorem rustLoad_u32_littleEndian {size : Nat} (rust : RustMemory size)
    (address : Nat) (hvalid : Memory.validRange rust.toLean address 4 4) :
    rust.load address 4 4 =
      some (Word32.ofNat
        (rust.littleEndianValue (address - rust.base.toNat) 4)) := by
  simp [RustMemory.load, hvalid]

def RustMemory.store (memory : RustMemory size) (address width alignment : Nat)
    (value : Word32) : Option (RustMemory size) :=
  if Memory.validRange memory.toLean address width alignment then
    let offset := address - memory.toLean.base.toNat
    some
      { memory with
        bytes := fun index =>
          if offset ≤ index.val && index.val < offset + width then
            UInt8.ofNat (value.toNat / 256 ^ (index.val - offset) % 256)
          else
            memory.bytes index }
  else
    none

theorem rustStore_success_refines_leanStore {size : Nat} (rust : RustMemory size)
    (address width alignment : Nat) (value : Word32)
    (hvalid : Memory.validRange rust.toLean address width alignment) :
    ∃ rustNext leanNext,
      rust.store address width alignment value = some rustNext ∧
      Memory.store rust.toLean address width alignment value = some leanNext ∧
      rustNext.Refines leanNext := by
  let offset := address - rust.toLean.base.toNat
  let rustNext : RustMemory size :=
    { rust with
      bytes := fun index =>
        if offset ≤ index.val && index.val < offset + width then
          UInt8.ofNat (value.toNat / 256 ^ (index.val - offset) % 256)
        else rust.bytes index }
  let leanNext : Memory :=
    { rust.toLean with bytes := Memory.storeBytes rust.toLean offset value.toNat width }
  refine ⟨rustNext, leanNext, ?_, ?_, ?_⟩
  · simp [RustMemory.store, hvalid, rustNext, offset]
  · simp [Memory.store, hvalid, leanNext, offset]
  · refine ⟨rfl, rfl, ?_⟩
    intro index hindex
    simp [rustNext, leanNext, Memory.storeBytes, RustMemory.toLean, RustMemory.byteAt,
      hindex, offset]

end ZkRV32I.Refinement
