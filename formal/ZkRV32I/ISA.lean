import ZkRV32I.Base

namespace ZkRV32I

inductive Instruction where
  | lui (rd : Fin 32) (imm : Word32)
  | auipc (rd : Fin 32) (imm : Word32)
  | jal (rd : Fin 32) (imm : Word32)
  | jalr (rd rs1 : Fin 32) (imm : Word32)
  | beq (rs1 rs2 : Fin 32) (imm : Word32)
  | bne (rs1 rs2 : Fin 32) (imm : Word32)
  | blt (rs1 rs2 : Fin 32) (imm : Word32)
  | bge (rs1 rs2 : Fin 32) (imm : Word32)
  | bltu (rs1 rs2 : Fin 32) (imm : Word32)
  | bgeu (rs1 rs2 : Fin 32) (imm : Word32)
  | lb (rd rs1 : Fin 32) (imm : Word32)
  | lh (rd rs1 : Fin 32) (imm : Word32)
  | lw (rd rs1 : Fin 32) (imm : Word32)
  | lbu (rd rs1 : Fin 32) (imm : Word32)
  | lhu (rd rs1 : Fin 32) (imm : Word32)
  | sb (rs1 rs2 : Fin 32) (imm : Word32)
  | sh (rs1 rs2 : Fin 32) (imm : Word32)
  | sw (rs1 rs2 : Fin 32) (imm : Word32)
  | addi (rd rs1 : Fin 32) (imm : Word32)
  | slti (rd rs1 : Fin 32) (imm : Word32)
  | sltiu (rd rs1 : Fin 32) (imm : Word32)
  | xori (rd rs1 : Fin 32) (imm : Word32)
  | ori (rd rs1 : Fin 32) (imm : Word32)
  | andi (rd rs1 : Fin 32) (imm : Word32)
  | slli (rd rs1 : Fin 32) (shamt : Nat)
  | srli (rd rs1 : Fin 32) (shamt : Nat)
  | srai (rd rs1 : Fin 32) (shamt : Nat)
  | add (rd rs1 rs2 : Fin 32)
  | sub (rd rs1 rs2 : Fin 32)
  | sll (rd rs1 rs2 : Fin 32)
  | slt (rd rs1 rs2 : Fin 32)
  | sltu (rd rs1 rs2 : Fin 32)
  | xor (rd rs1 rs2 : Fin 32)
  | srl (rd rs1 rs2 : Fin 32)
  | sra (rd rs1 rs2 : Fin 32)
  | or (rd rs1 rs2 : Fin 32)
  | and (rd rs1 rs2 : Fin 32)
  | fence
  | ecall
  | ebreak
  deriving DecidableEq, Repr

inductive DecodeError where
  | illegalEncoding
  | unsupportedInstruction
  deriving DecidableEq, Repr

def bitField (word low width : Nat) : Nat :=
  word / 2 ^ low % 2 ^ width

private def reg (index : Nat) : Fin 32 :=
  ⟨index % 32, Nat.mod_lt _ (by decide)⟩

private def signedImm (value width : Nat) : Word32 :=
  Word32.signExtend value width

def bImmediateRaw (bits : Nat) : Nat :=
  bitField bits 8 4 * 2 + bitField bits 25 6 * 32 +
    bitField bits 7 1 * 2048 + bitField bits 31 1 * 4096

theorem bImmediateRaw_uses_standard_bit_positions (bits : Nat) :
    bImmediateRaw bits =
      bitField bits 8 4 * 2 + bitField bits 25 6 * 32 +
        bitField bits 7 1 * 2 ^ 11 + bitField bits 31 1 * 2 ^ 12 := by
  rfl

theorem bImmediate_instruction_bit7_contribution :
    bImmediateRaw (2 ^ 7) = 2 ^ 11 := by
  decide

theorem bImmediate_instruction_bit31_contribution :
    bImmediateRaw (2 ^ 31) = 2 ^ 12 := by
  decide

theorem bImmediateSignExtension_is_13_bit (bits : Nat) :
    Word32.signExtend (bImmediateRaw bits) 13 =
      Word32.ofNat
        (if bImmediateRaw bits % 2 ^ 13 ≥ 2 ^ 12 then
          bImmediateRaw bits % 2 ^ 13 + 2 ^ 32 - 2 ^ 13
        else bImmediateRaw bits % 2 ^ 13) := by
  unfold Word32.signExtend
  split <;> congr 1 <;> omega

theorem bImmediate_negative_sign_extension :
    Word32.signExtend (2 ^ 12) 13 = Word32.ofNat (2 ^ 32 - 2 ^ 12) := by
  decide

theorem bImmediate_bit7_and_sign_bit_raw :
    bImmediateRaw (2 ^ 31 + 2 ^ 7) = 6144 := by
  decide

theorem bImmediate_bit7_and_sign_bit_sign_extension :
    Word32.signExtend 6144 13 = Word32.ofNat 0xfffff800 := by
  decide

def decode (word : Word32) : Except DecodeError Instruction := do
  let bits := word.toNat
  let opcode := bitField bits 0 7
  let rd := reg (bitField bits 7 5)
  let funct3 := bitField bits 12 3
  let rs1 := reg (bitField bits 15 5)
  let rs2 := reg (bitField bits 20 5)
  let funct7 := bitField bits 25 7
  let immI := signedImm (bitField bits 20 12) 12
  let immS := signedImm (bitField bits 7 5 + bitField bits 25 7 * 32) 12
  let immB := signedImm (bImmediateRaw bits) 13
  let immU := Word32.ofNat   (bitField bits 12 20 * 4096)
  let immJ := signedImm
    (bitField bits 21 10 * 2 + bitField bits 20 1 * 2048 +
      bitField bits 12 8 * 4096 + bitField bits 31 1 * 1048576) 21
  match opcode with
  | 55 => pure (.lui rd immU)
  | 23 => pure (.auipc rd immU)
  | 111 => pure (.jal rd immJ)
  | 103 =>
      if funct3 == 0 then pure (.jalr rd rs1 immI) else throw .illegalEncoding
  | 99 =>
      match funct3 with
      | 0 => pure (.beq rs1 rs2 immB)
      | 1 => pure (.bne rs1 rs2 immB)
      | 4 => pure (.blt rs1 rs2 immB)
      | 5 => pure (.bge rs1 rs2 immB)
      | 6 => pure (.bltu rs1 rs2 immB)
      | 7 => pure (.bgeu rs1 rs2 immB)
      | _ => throw .illegalEncoding
  | 3 =>
      match funct3 with
      | 0 => pure (.lb rd rs1 immI)
      | 1 => pure (.lh rd rs1 immI)
      | 2 => pure (.lw rd rs1 immI)
      | 4 => pure (.lbu rd rs1 immI)
      | 5 => pure (.lhu rd rs1 immI)
      | _ => throw .illegalEncoding
  | 35 =>
      match funct3 with
      | 0 => pure (.sb rs1 rs2 immS)
      | 1 => pure (.sh rs1 rs2 immS)
      | 2 => pure (.sw rs1 rs2 immS)
      | _ => throw .illegalEncoding
  | 19 =>
      match funct3 with
      | 0 => pure (.addi rd rs1 immI)
      | 2 => pure (.slti rd rs1 immI)
      | 3 => pure (.sltiu rd rs1 immI)
      | 4 => pure (.xori rd rs1 immI)
      | 6 => pure (.ori rd rs1 immI)
      | 7 => pure (.andi rd rs1 immI)
      | 1 =>
          if funct7 == 0 then pure (.slli rd rs1 (bitField bits 20 5))
          else throw .illegalEncoding
      | 5 =>
          if funct7 == 0 then pure (.srli rd rs1 (bitField bits 20 5))
          else if funct7 == 32 then pure (.srai rd rs1 (bitField bits 20 5))
          else throw .illegalEncoding
      | _ => throw .illegalEncoding
  | 51 =>
      match funct3, funct7 with
      | 0, 0 => pure (.add rd rs1 rs2)
      | 0, 32 => pure (.sub rd rs1 rs2)
      | 1, 0 => pure (.sll rd rs1 rs2)
      | 2, 0 => pure (.slt rd rs1 rs2)
      | 3, 0 => pure (.sltu rd rs1 rs2)
      | 4, 0 => pure (.xor rd rs1 rs2)
      | 5, 0 => pure (.srl rd rs1 rs2)
      | 5, 32 => pure (.sra rd rs1 rs2)
      | 6, 0 => pure (.or rd rs1 rs2)
      | 7, 0 => pure (.and rd rs1 rs2)
      | _, _ => throw .illegalEncoding
  | 15 =>
      if funct3 == 0 && rd == 0 && rs1 == 0 &&
          (bits / 2 ^ 28 == 0 ||
            (bits / 2 ^ 28 == 8 &&
              bitField bits 24 4 == 3 && bitField bits 20 4 == 3)) then
        pure .fence
      else
        throw .unsupportedInstruction
  | 115 =>
      if bits == 115 then pure .ecall
      else if bits == 1048691 then pure .ebreak
      else throw .unsupportedInstruction
  | _ => throw .illegalEncoding

theorem decode_fence_base :
    decode (Word32.ofNat 0x0000000f) = .ok .fence := by
  rfl

theorem decode_fence_tso :
    decode (Word32.ofNat 0x8330000f) = .ok .fence := by
  rfl

theorem decode_nonfence_funct3_unsupported :
    decode (Word32.ofNat 0x0000100f) = .error .unsupportedInstruction := by
  rfl

theorem decode_unsupported_system_instruction :
    decode (Word32.ofNat 0x00200073) = .error .unsupportedInstruction := by
  rfl

set_option maxRecDepth 100000 in
theorem decode_addi_x1_x0_one :
    decode (Word32.ofNat 0x00100093) =
      .ok (.addi (Fin.mk 1 (by decide)) (Fin.mk 0 (by decide)) 1) := by
  rfl

set_option maxRecDepth 100000 in
theorem decode_addi_x2_x0_two :
    decode (Word32.ofNat 0x00200113) =
      .ok (.addi (Fin.mk 2 (by decide)) (Fin.mk 0 (by decide)) 2) := by
  rfl

set_option maxRecDepth 100000 in
theorem decode_addi_x3_x1_three :
    decode (Word32.ofNat 0x00308193) =
      .ok (.addi (Fin.mk 3 (by decide)) (Fin.mk 1 (by decide)) 3) := by
  rfl

set_option maxRecDepth 100000 in
theorem decode_addi_x4_x1_four :
    decode (Word32.ofNat 0x00408213) =
      .ok (.addi (Fin.mk 4 (by decide)) (Fin.mk 1 (by decide)) 4) := by
  rfl

set_option maxRecDepth 100000 in
theorem decode_ecall_word :
    decode (Word32.ofNat 0x00000073) = .ok .ecall := by
  rfl

end ZkRV32I
