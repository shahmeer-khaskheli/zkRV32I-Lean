namespace ZkRV32I

abbrev Word32 := UInt32

namespace Word32

def zero : Word32 := 0

def ofNat (n : Nat) : Word32 := UInt32.ofNat n

def signed (w : Word32) : Int :=
  if w.toNat < 2147483648 then Int.ofNat w.toNat
  else Int.ofNat w.toNat - 4294967296

def signExtend (value width : Nat) : Word32 :=
  if value % 2 ^ width >= 2 ^ (width - 1) then
    ofNat (value % 2 ^ width + 2 ^ 32 - 2 ^ width)
  else
    ofNat (value % 2 ^ width)

def add (a b : Word32) : Word32 := a + b

def sub (a b : Word32) : Word32 := a - b

def signedLessThan (a b : Word32) : Bool := signed a < signed b

end Word32

structure RegisterFile where
  values : Fin 32 → Word32

namespace RegisterFile

def zeroed : RegisterFile := ⟨fun _ => 0⟩

def read (regs : RegisterFile) (index : Fin 32) : Word32 :=
  if index.val = 0 then 0 else regs.values index

def x0 (_regs : RegisterFile) : Word32 := 0

def write (regs : RegisterFile) (index : Fin 32) (value : Word32) : RegisterFile :=
  if index.val = 0 then regs else ⟨fun i => if i = index then value else regs.values i⟩

theorem x0_write_invariant (regs : RegisterFile) (index : Fin 32) (value : Word32) :
    (write regs index value).x0 = 0 := by
  rfl

end RegisterFile

structure Memory where
  base : Word32
  size : Nat
  bytes : Nat → UInt8

namespace Memory

def empty (base : Word32) (size : Nat) : Memory :=
  ⟨base, size, fun _ => 0⟩

def validRange (mem : Memory) (address width alignment : Nat) : Bool :=
  let base := mem.base.toNat
  if alignment > 1 && address % alignment != 0 then false
  else if width = 0 then false
  else if base > address then false
  else if address + (width - 1) ≥ 4294967296 then false
  else address - base + width ≤ mem.size

def littleEndianValue (mem : Memory) (offset width : Nat) : Nat :=
  (List.range width).foldl
    (fun acc i => acc + (mem.bytes (offset + i)).toNat * 256 ^ i) 0

def load (mem : Memory) (address width alignment : Nat) : Option Word32 :=
  if validRange mem address width alignment then
    let offset := address - mem.base.toNat
    some (Word32.ofNat (littleEndianValue mem offset width))
  else
    none

def storeBytes (mem : Memory) (offset value width : Nat) : Nat → UInt8 :=
  fun index =>
    if offset ≤ index && index < offset + width then
      UInt8.ofNat (value / 256 ^ (index - offset) % 256)
    else
      mem.bytes index

def store (mem : Memory) (address width alignment : Nat) (value : Word32) : Option Memory :=
  if validRange mem address width alignment then
    let offset := address - mem.base.toNat
    some { mem with bytes := storeBytes mem offset value.toNat width }
  else
    none

end Memory

end ZkRV32I
