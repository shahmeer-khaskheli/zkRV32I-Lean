namespace ZkRV32I.Circuit

-- The illustrative constraint field is the prime field F₂, represented by Bool.
abbrev FieldElem := Bool

def fieldZero : FieldElem := false

def fieldOne : FieldElem := true

def fieldAdd (a b : FieldElem) : FieldElem := a != b

def fieldMul (a b : FieldElem) : FieldElem := a && b

def fieldNeg (a : FieldElem) : FieldElem := a

def fieldInv (a : FieldElem) : FieldElem := a

theorem field_add_self (a : FieldElem) : fieldAdd a a = fieldZero := by
  cases a <;> rfl

theorem field_add_comm (a b : FieldElem) : fieldAdd a b = fieldAdd b a := by
  cases a <;> cases b <;> rfl

theorem field_add_assoc (a b c : FieldElem) :
    fieldAdd (fieldAdd a b) c = fieldAdd a (fieldAdd b c) := by
  cases a <;> cases b <;> cases c <;> rfl

theorem field_mul_comm (a b : FieldElem) : fieldMul a b = fieldMul b a := by
  cases a <;> cases b <;> rfl

theorem field_mul_assoc (a b c : FieldElem) :
    fieldMul (fieldMul a b) c = fieldMul a (fieldMul b c) := by
  cases a <;> cases b <;> cases c <;> rfl

theorem field_add_zero (a : FieldElem) : fieldAdd a fieldZero = a := by
  cases a <;> rfl

theorem field_mul_one (a : FieldElem) : fieldMul a fieldOne = a := by
  cases a <;> rfl

theorem field_mul_add (a b c : FieldElem) :
    fieldMul a (fieldAdd b c) =
      fieldAdd (fieldMul a b) (fieldMul a c) := by
  cases a <;> cases b <;> cases c <;> rfl

theorem field_mul_inv_of_nonzero (a : FieldElem) (h : a ≠ fieldZero) :
    fieldMul a (fieldInv a) = fieldOne := by
  cases a <;> simp_all [fieldMul, fieldInv, fieldZero, fieldOne]

end ZkRV32I.Circuit
