    0x0 | 00 61 73 6d | version 1 (Module)
        | 01 00 00 00
    0x8 | 01 a9 03    | type section
    0xb | 23          | 35 count
--- rec group 0 (explicit) ---
    0xc | 4e 0b       | 
    0xe | 5e 6d 01    | [type 0] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Array(ArrayType(FieldType { element_type: Val(Ref(eqref)), mutable: true })), shared: false } }
   0x11 | 5e 78 01    | [type 1] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Array(ArrayType(FieldType { element_type: I8, mutable: true })), shared: false } }
   0x14 | 50 00 5f 05 | [type 2] SubType { is_final: false, supertype_idx: None, composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }] }), shared: false } }
        | 63 05 01 7f
        | 01 7f 01 7f
        | 01 63 02 01
   0x24 | 50 01 02 5f | [type 3] SubType { is_final: false, supertype_idx: Some(CoreTypeIndex { kind: "module", index: 2 }), composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }, FieldType { element_type: Val(Ref((ref (module 0)))), mutable: true }] }), shared: false } }
        | 06 63 05 01
        | 7f 01 7f 01
        | 7f 01 63 02
        | 01 64 00 01
   0x38 | 50 01 03 5f | [type 4] SubType { is_final: false, supertype_idx: Some(CoreTypeIndex { kind: "module", index: 3 }), composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }, FieldType { element_type: Val(Ref((ref (module 0)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 1)))), mutable: false }] }), shared: false } }
        | 07 63 05 01
        | 7f 01 7f 01
        | 7f 01 63 02
        | 01 64 00 01
        | 63 01 00   
   0x4f | 50 01 03 5f | [type 5] SubType { is_final: false, supertype_idx: Some(CoreTypeIndex { kind: "module", index: 3 }), composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }, FieldType { element_type: Val(Ref((ref (module 0)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(Ref((ref (module 6)))), mutable: true }, FieldType { element_type: Val(Ref((ref (module 0)))), mutable: true }, FieldType { element_type: Val(Ref((ref (module 4)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }] }), shared: false } }
        | 0b 63 05 01
        | 7f 01 7f 01
        | 7f 01 63 02
        | 01 64 00 01
        | 63 05 01 64
        | 06 01 64 00
        | 01 64 04 01
        | 7f 01      
   0x71 | 50 01 03 5f | [type 6] SubType { is_final: false, supertype_idx: Some(CoreTypeIndex { kind: "module", index: 3 }), composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }, FieldType { element_type: Val(Ref((ref (module 0)))), mutable: true }, FieldType { element_type: Val(Ref((ref (module 0)))), mutable: false }, FieldType { element_type: Val(Ref((ref (module 0)))), mutable: false }, FieldType { element_type: Val(I32), mutable: true }] }), shared: false } }
        | 09 63 05 01
        | 7f 01 7f 01
        | 7f 01 63 02
        | 01 64 00 01
        | 64 00 00 64
        | 00 00 7f 01
   0x8d | 50 01 03 5f | [type 7] SubType { is_final: false, supertype_idx: Some(CoreTypeIndex { kind: "module", index: 3 }), composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }, FieldType { element_type: Val(Ref((ref (module 0)))), mutable: true }, FieldType { element_type: Val(I32), mutable: false }, FieldType { element_type: Val(Ref((ref null (module 1)))), mutable: false }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: false }, FieldType { element_type: Val(I32), mutable: true }] }), shared: false } }
        | 0c 63 05 01
        | 7f 01 7f 01
        | 7f 01 63 02
        | 01 64 00 01
        | 7f 00 63 01
        | 00 7f 01 7f
        | 01 7f 00 7f
        | 01         
   0xae | 50 01 03 5f | [type 8] SubType { is_final: false, supertype_idx: Some(CoreTypeIndex { kind: "module", index: 3 }), composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }, FieldType { element_type: Val(Ref((ref (module 0)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 8)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 7)))), mutable: true }, FieldType { element_type: Val(Ref(eqref)), mutable: true }, FieldType { element_type: Val(Ref((ref (module 0)))), mutable: true }, FieldType { element_type: Val(Ref((ref (module 0)))), mutable: true }, FieldType { element_type: Val(Ref((ref (module 0)))), mutable: true }] }), shared: false } }
        | 0e 63 05 01
        | 7f 01 7f 01
        | 7f 01 63 02
        | 01 64 00 01
        | 63 08 01 7f
        | 01 7f 01 63
        | 07 01 6d 01
        | 64 00 01 64
        | 00 01 64 00
        | 01         
   0xd7 | 5f 04 6d 01 | [type 9] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref(eqref)), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 7)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }] }), shared: false } }
        | 63 05 01 63
        | 07 01 7f 01
   0xe3 | 60 01 6d 01 | [type 10] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref)], results: [I32] }), shared: false } }
        | 7f         
--- rec group 1 (implicit) ---
   0xe8 | 60 01 7f 00 | [type 11] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [I32], results: [] }), shared: false } }
--- rec group 2 (implicit) ---
   0xec | 60 02 7f 7f | [type 12] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [I32, I32], results: [] }), shared: false } }
        | 00         
--- rec group 3 (implicit) ---
   0xf1 | 60 03 7f 7f | [type 13] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [I32, I32, I32], results: [] }), shared: false } }
        | 7f 00      
--- rec group 4 (implicit) ---
   0xf7 | 60 01 63 07 | [type 14] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref null (module 7)))], results: [Ref((ref null (module 1)))] }), shared: false } }
        | 01 63 01   
--- rec group 5 (implicit) ---
   0xfe | 60 01 7f 01 | [type 15] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [I32], results: [Ref((ref null (module 7)))] }), shared: false } }
        | 63 07      
--- rec group 6 (implicit) ---
  0x104 | 60 02 63 07 | [type 16] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref null (module 7))), I32], results: [] }), shared: false } }
        | 7f 00      
--- rec group 7 (implicit) ---
  0x10a | 60 02 6d 6d | [type 17] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref), Ref(eqref)], results: [] }), shared: false } }
        | 00         
--- rec group 8 (implicit) ---
  0x10f | 60 01 6d 01 | [type 18] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref)], results: [Ref(eqref)] }), shared: false } }
        | 6d         
--- rec group 9 (implicit) ---
  0x114 | 60 01 6d 01 | [type 19] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref)], results: [I32] }), shared: false } }
        | 7f         
--- rec group 10 (implicit) ---
  0x119 | 60 01 7f 01 | [type 20] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [I32], results: [Ref(eqref)] }), shared: false } }
        | 6d         
--- rec group 11 (implicit) ---
  0x11e | 60 02 6d 6d | [type 21] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref), Ref(eqref)], results: [Ref(eqref)] }), shared: false } }
        | 01 6d      
--- rec group 12 (implicit) ---
  0x124 | 60 03 6d 6d | [type 22] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref), Ref(eqref), Ref(eqref)], results: [] }), shared: false } }
        | 6d 00      
--- rec group 13 (implicit) ---
  0x12a | 60 03 6d 6d | [type 23] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref), Ref(eqref), Ref(eqref)], results: [Ref(eqref)] }), shared: false } }
        | 6d 01 6d   
--- rec group 14 (implicit) ---
  0x131 | 60 02 6d 7f | [type 24] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref), I32], results: [I32] }), shared: false } }
        | 01 7f      
--- rec group 15 (implicit) ---
  0x137 | 60 01 6d 00 | [type 25] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref)], results: [] }), shared: false } }
--- rec group 16 (implicit) ---
  0x13b | 60 00 01 6d | [type 26] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [], results: [Ref(eqref)] }), shared: false } }
--- rec group 17 (implicit) ---
  0x13f | 60 02 64 08 | [type 27] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref (module 8))), I32], results: [Ref(eqref)] }), shared: false } }
        | 7f 01 6d   
--- rec group 18 (implicit) ---
  0x146 | 60 02 6d 7f | [type 28] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref), I32], results: [Ref(eqref)] }), shared: false } }
        | 01 6d      
--- rec group 19 (implicit) ---
  0x14c | 60 01 63 01 | [type 29] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref null (module 1)))], results: [I32] }), shared: false } }
        | 01 7f      
--- rec group 20 (implicit) ---
  0x152 | 60 02 63 01 | [type 30] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref null (module 1))), I32], results: [I32] }), shared: false } }
        | 7f 01 7f   
--- rec group 21 (implicit) ---
  0x159 | 60 01 63 00 | [type 31] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref null (module 0)))], results: [I32] }), shared: false } }
        | 01 7f      
--- rec group 22 (implicit) ---
  0x15f | 60 02 63 00 | [type 32] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref null (module 0))), I32], results: [Ref(eqref)] }), shared: false } }
        | 7f 01 6d   
--- rec group 23 (implicit) ---
  0x166 | 60 00 01 7f | [type 33] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [], results: [I32] }), shared: false } }
--- rec group 24 (implicit) ---
  0x16a | 60 02 63 08 | [type 34] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref null (module 8))), Ref(eqref)], results: [] }), shared: false } }
        | 6d 00      
--- rec group 25 (implicit) ---
  0x170 | 60 01 63 08 | [type 35] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref null (module 8)))], results: [Ref(eqref)] }), shared: false } }
        | 01 6d      
--- rec group 26 (implicit) ---
  0x176 | 60 01 6d 01 | [type 36] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref)], results: [Ref((ref null (module 5)))] }), shared: false } }
        | 63 05      
--- rec group 27 (implicit) ---
  0x17c | 60 02 6d 6d | [type 37] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref), Ref(eqref)], results: [Ref((ref null (module 7)))] }), shared: false } }
        | 01 63 07   
--- rec group 28 (implicit) ---
  0x183 | 60 02 6d 63 | [type 38] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref), Ref((ref null (module 5)))], results: [Ref((ref null (module 7)))] }), shared: false } }
        | 05 01 63 07
--- rec group 29 (implicit) ---
  0x18b | 60 03 6d 63 | [type 39] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref), Ref((ref null (module 5))), Ref((ref (module 7)))], results: [] }), shared: false } }
        | 05 64 07 00
--- rec group 30 (implicit) ---
  0x193 | 60 03 6d 64 | [type 40] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref), Ref((ref (module 7))), Ref(eqref)], results: [Ref((ref null (module 8)))] }), shared: false } }
        | 07 6d 01 63
        | 08         
--- rec group 31 (implicit) ---
  0x19c | 60 01 7f 01 | [type 41] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [I32], results: [Ref((ref i31))] }), shared: false } }
        | 64 6c      
--- rec group 32 (implicit) ---
  0x1a2 | 60 01 64 07 | [type 42] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref (module 7)))], results: [I32] }), shared: false } }
        | 01 7f      
--- rec group 33 (implicit) ---
  0x1a8 | 60 02 63 08 | [type 43] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref null (module 8))), I32], results: [I32] }), shared: false } }
        | 7f 01 7f   
--- rec group 34 (implicit) ---
  0x1af | 60 01 64 07 | [type 44] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref (module 7)))], results: [] }), shared: false } }
        | 00         
  0x1b4 | 02 37       | import section
  0x1b6 | 03          | 3 count
  0x1b7 | 03 65 6e 76 | import [func 0] Import { module: "env", name: "reportResult", ty: Func(11) }
        | 0c 72 65 70
        | 6f 72 74 52
        | 65 73 75 6c
        | 74 00 0b   
  0x1ca | 03 65 6e 76 | import [func 1] Import { module: "env", name: "compileMethod", ty: Func(12) }
        | 0d 63 6f 6d
        | 70 69 6c 65
        | 4d 65 74 68
        | 6f 64 00 0c
  0x1de | 03 65 6e 76 | import [func 2] Import { module: "env", name: "debugLog", ty: Func(13) }
        | 08 64 65 62
        | 75 67 4c 6f
        | 67 00 0d   
  0x1ed | 03 32       | func section
  0x1ef | 31          | 49 count
  0x1f0 | 0e          | [func 3] type 14
  0x1f1 | 0f          | [func 4] type 15
  0x1f2 | 10          | [func 5] type 16
  0x1f3 | 11          | [func 6] type 17
  0x1f4 | 12          | [func 7] type 18
  0x1f5 | 13          | [func 8] type 19
  0x1f6 | 14          | [func 9] type 20
  0x1f7 | 12          | [func 10] type 18
  0x1f8 | 15          | [func 11] type 21
  0x1f9 | 15          | [func 12] type 21
  0x1fa | 16          | [func 13] type 22
  0x1fb | 17          | [func 14] type 23
  0x1fc | 18          | [func 15] type 24
  0x1fd | 19          | [func 16] type 25
  0x1fe | 1a          | [func 17] type 26
  0x1ff | 12          | [func 18] type 18
  0x200 | 12          | [func 19] type 18
  0x201 | 1b          | [func 20] type 27
  0x202 | 1c          | [func 21] type 28
  0x203 | 12          | [func 22] type 18
  0x204 | 1c          | [func 23] type 28
  0x205 | 13          | [func 24] type 19
  0x206 | 1d          | [func 25] type 29
  0x207 | 1d          | [func 26] type 29
  0x208 | 1d          | [func 27] type 29
  0x209 | 1e          | [func 28] type 30
  0x20a | 1f          | [func 29] type 31
  0x20b | 20          | [func 30] type 32
  0x20c | 13          | [func 31] type 19
  0x20d | 13          | [func 32] type 19
  0x20e | 21          | [func 33] type 33
  0x20f | 22          | [func 34] type 34
  0x210 | 23          | [func 35] type 35
  0x211 | 23          | [func 36] type 35
  0x212 | 24          | [func 37] type 36
  0x213 | 25          | [func 38] type 37
  0x214 | 26          | [func 39] type 38
  0x215 | 27          | [func 40] type 39
  0x216 | 28          | [func 41] type 40
  0x217 | 29          | [func 42] type 41
  0x218 | 13          | [func 43] type 19
  0x219 | 2a          | [func 44] type 42
  0x21a | 2b          | [func 45] type 43
  0x21b | 2c          | [func 46] type 44
  0x21c | 23          | [func 47] type 35
  0x21d | 21          | [func 48] type 33
  0x21e | 21          | [func 49] type 33
  0x21f | 2b          | [func 50] type 43
  0x220 | 21          | [func 51] type 33
  0x221 | 04 04       | table section
  0x223 | 01          | 1 count
  0x224 | 70 00 64    | [table 0] Table { ty: TableType { element_type: funcref, table64: false, initial: 100, maximum: None, shared: false }, init: RefNull }
  0x227 | 05 03       | memory section
  0x229 | 01          | 1 count
  0x22a | 00 01       | [memory 0] MemoryType { memory64: false, shared: false, initial: 1, maximum: None, page_size_log2: None }
  0x22c | 06 7e       | global section
  0x22e | 16          | 22 count
  0x22f | 63 05 01    | [global 0] GlobalType { content_type: Ref((ref null (module 5))), mutable: true, shared: false }
  0x232 | d0 05       | ref_null hty:Concrete(Module(5))
  0x234 | 0b          | end
  0x235 | 63 05 01    | [global 1] GlobalType { content_type: Ref((ref null (module 5))), mutable: true, shared: false }
  0x238 | d0 05       | ref_null hty:Concrete(Module(5))
  0x23a | 0b          | end
  0x23b | 63 05 01    | [global 2] GlobalType { content_type: Ref((ref null (module 5))), mutable: true, shared: false }
  0x23e | d0 05       | ref_null hty:Concrete(Module(5))
  0x240 | 0b          | end
  0x241 | 63 05 01    | [global 3] GlobalType { content_type: Ref((ref null (module 5))), mutable: true, shared: false }
  0x244 | d0 05       | ref_null hty:Concrete(Module(5))
  0x246 | 0b          | end
  0x247 | 63 05 01    | [global 4] GlobalType { content_type: Ref((ref null (module 5))), mutable: true, shared: false }
  0x24a | d0 05       | ref_null hty:Concrete(Module(5))
  0x24c | 0b          | end
  0x24d | 63 05 01    | [global 5] GlobalType { content_type: Ref((ref null (module 5))), mutable: true, shared: false }
  0x250 | d0 05       | ref_null hty:Concrete(Module(5))
  0x252 | 0b          | end
  0x253 | 63 07 01    | [global 6] GlobalType { content_type: Ref((ref null (module 7))), mutable: true, shared: false }
  0x256 | d0 07       | ref_null hty:Concrete(Module(7))
  0x258 | 0b          | end
  0x259 | 6d 01       | [global 7] GlobalType { content_type: Ref(eqref), mutable: true, shared: false }
  0x25b | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x25d | 0b          | end
  0x25e | 6d 01       | [global 8] GlobalType { content_type: Ref(eqref), mutable: true, shared: false }
  0x260 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x262 | 0b          | end
  0x263 | 6d 01       | [global 9] GlobalType { content_type: Ref(eqref), mutable: true, shared: false }
  0x265 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x267 | 0b          | end
  0x268 | 6d 01       | [global 10] GlobalType { content_type: Ref(eqref), mutable: true, shared: false }
  0x26a | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x26c | 0b          | end
  0x26d | 63 08 01    | [global 11] GlobalType { content_type: Ref((ref null (module 8))), mutable: true, shared: false }
  0x270 | d0 08       | ref_null hty:Concrete(Module(8))
  0x272 | 0b          | end
  0x273 | 7f 01       | [global 12] GlobalType { content_type: I32, mutable: true, shared: false }
  0x275 | 41 e8 07    | i32_const value:1000
  0x278 | 0b          | end
  0x279 | 63 02 01    | [global 13] GlobalType { content_type: Ref((ref null (module 2))), mutable: true, shared: false }
  0x27c | d0 02       | ref_null hty:Concrete(Module(2))
  0x27e | 0b          | end
  0x27f | 63 02 01    | [global 14] GlobalType { content_type: Ref((ref null (module 2))), mutable: true, shared: false }
  0x282 | d0 02       | ref_null hty:Concrete(Module(2))
  0x284 | 0b          | end
  0x285 | 7f 01       | [global 15] GlobalType { content_type: I32, mutable: true, shared: false }
  0x287 | 41 00       | i32_const value:0
  0x289 | 0b          | end
  0x28a | 7f 01       | [global 16] GlobalType { content_type: I32, mutable: true, shared: false }
  0x28c | 41 e8 07    | i32_const value:1000
  0x28f | 0b          | end
  0x290 | 7f 01       | [global 17] GlobalType { content_type: I32, mutable: true, shared: false }
  0x292 | 41 01       | i32_const value:1
  0x294 | 0b          | end
  0x295 | 7f 01       | [global 18] GlobalType { content_type: I32, mutable: true, shared: false }
  0x297 | 41 00       | i32_const value:0
  0x299 | 0b          | end
  0x29a | 7f 01       | [global 19] GlobalType { content_type: I32, mutable: true, shared: false }
  0x29c | 41 80 02    | i32_const value:256
  0x29f | 0b          | end
  0x2a0 | 63 00 01    | [global 20] GlobalType { content_type: Ref((ref null (module 0))), mutable: true, shared: false }
  0x2a3 | d0 00       | ref_null hty:Concrete(Module(0))
  0x2a5 | 0b          | end
  0x2a6 | 7f 01       | [global 21] GlobalType { content_type: I32, mutable: true, shared: false }
  0x2a8 | 41 80 08    | i32_const value:1024
  0x2ab | 0b          | end
  0x2ac | 07 fa 03    | export section
  0x2af | 1b          | 27 count
  0x2b0 | 09 66 75 6e | export Export { name: "funcTable", kind: Table, index: 0 }
        | 63 54 61 62
        | 6c 65 01 00
  0x2bc | 06 6d 65 6d | export Export { name: "memory", kind: Memory, index: 0 }
        | 6f 72 79 02
        | 00         
  0x2c5 | 1a 67 65 74 | export Export { name: "getCompiledMethodBytecodes", kind: Func, index: 3 }
        | 43 6f 6d 70
        | 69 6c 65 64
        | 4d 65 74 68
        | 6f 64 42 79
        | 74 65 63 6f
        | 64 65 73 00
        | 03         
  0x2e2 | 15 67 65 74 | export Export { name: "getCompiledMethodById", kind: Func, index: 4 }
        | 43 6f 6d 70
        | 69 6c 65 64
        | 4d 65 74 68
        | 6f 64 42 79
        | 49 64 00 04
  0x2fa | 14 73 65 74 | export Export { name: "setCompiledFuncIndex", kind: Func, index: 5 }
        | 43 6f 6d 70
        | 69 6c 65 64
        | 46 75 6e 63
        | 49 6e 64 65
        | 78 00 05   
  0x311 | 0b 70 75 73 | export Export { name: "pushOnStack", kind: Func, index: 6 }
        | 68 4f 6e 53
        | 74 61 63 6b
        | 00 06      
  0x31f | 0c 70 6f 70 | export Export { name: "popFromStack", kind: Func, index: 7 }
        | 46 72 6f 6d
        | 53 74 61 63
        | 6b 00 07   
  0x32e | 13 65 78 74 | export Export { name: "extractIntegerValue", kind: Func, index: 8 }
        | 72 61 63 74
        | 49 6e 74 65
        | 67 65 72 56
        | 61 6c 75 65
        | 00 08      
  0x344 | 12 63 72 65 | export Export { name: "createSmallInteger", kind: Func, index: 9 }
        | 61 74 65 53
        | 6d 61 6c 6c
        | 49 6e 74 65
        | 67 65 72 00
        | 09         
  0x359 | 08 67 65 74 | export Export { name: "getClass", kind: Func, index: 10 }
        | 43 6c 61 73
        | 73 00 0a   
  0x364 | 0d 6c 6f 6f | export Export { name: "lookupInCache", kind: Func, index: 11 }
        | 6b 75 70 49
        | 6e 43 61 63
        | 68 65 00 0b
  0x374 | 0c 6c 6f 6f | export Export { name: "lookupMethod", kind: Func, index: 12 }
        | 6b 75 70 4d
        | 65 74 68 6f
        | 64 00 0c   
  0x383 | 0c 73 74 6f | export Export { name: "storeInCache", kind: Func, index: 13 }
        | 72 65 49 6e
        | 43 61 63 68
        | 65 00 0d   
  0x392 | 13 63 72 65 | export Export { name: "createMethodContext", kind: Func, index: 14 }
        | 61 74 65 4d
        | 65 74 68 6f
        | 64 43 6f 6e
        | 74 65 78 74
        | 00 0e      
  0x3a8 | 11 69 6e 74 | export Export { name: "interpretBytecode", kind: Func, index: 15 }
        | 65 72 70 72
        | 65 74 42 79
        | 74 65 63 6f
        | 64 65 00 0f
  0x3bc | 10 73 65 74 | export Export { name: "setActiveContext", kind: Func, index: 16 }
        | 41 63 74 69
        | 76 65 43 6f
        | 6e 74 65 78
        | 74 00 10   
  0x3cf | 10 67 65 74 | export Export { name: "getActiveContext", kind: Func, index: 17 }
        | 41 63 74 69
        | 76 65 43 6f
        | 6e 74 65 78
        | 74 00 11   
  0x3e2 | 12 67 65 74 | export Export { name: "getContextReceiver", kind: Func, index: 18 }
        | 43 6f 6e 74
        | 65 78 74 52
        | 65 63 65 69
        | 76 65 72 00
        | 12         
  0x3f7 | 16 67 65 74 | export Export { name: "getCompiledMethodSlots", kind: Func, index: 19 }
        | 43 6f 6d 70
        | 69 6c 65 64
        | 4d 65 74 68
        | 6f 64 53 6c
        | 6f 74 73 00
        | 13         
  0x410 | 11 67 65 74 | export Export { name: "getContextLiteral", kind: Func, index: 21 }
        | 43 6f 6e 74
        | 65 78 74 4c
        | 69 74 65 72
        | 61 6c 00 15
  0x424 | 10 67 65 74 | export Export { name: "getContextMethod", kind: Func, index: 22 }
        | 43 6f 6e 74
        | 65 78 74 4d
        | 65 74 68 6f
        | 64 00 16   
  0x437 | 15 67 65 74 | export Export { name: "getObjectArrayElement", kind: Func, index: 23 }
        | 4f 62 6a 65
        | 63 74 41 72
        | 72 61 79 45
        | 6c 65 6d 65
        | 6e 74 00 17
  0x44f | 14 67 65 74 | export Export { name: "getObjectArrayLength", kind: Func, index: 24 }
        | 4f 62 6a 65
        | 63 74 41 72
        | 72 61 79 4c
        | 65 6e 67 74
        | 68 00 18   
  0x466 | 15 63 6f 70 | export Export { name: "copyByteArrayToMemory", kind: Func, index: 25 }
        | 79 42 79 74
        | 65 41 72 72
        | 61 79 54 6f
        | 4d 65 6d 6f
        | 72 79 00 19
  0x47e | 0f 67 65 74 | export Export { name: "getByteArrayLen", kind: Func, index: 26 }
        | 42 79 74 65
        | 41 72 72 61
        | 79 4c 65 6e
        | 00 1a      
  0x490 | 0a 69 6e 69 | export Export { name: "initialize", kind: Func, index: 48 }
        | 74 69 61 6c
        | 69 7a 65 00
        | 30         
  0x49d | 09 69 6e 74 | export Export { name: "interpret", kind: Func, index: 51 }
        | 65 72 70 72
        | 65 74 00 33
  0x4a9 | 0a c4 17    | code section
  0x4ac | 31          | 49 count
============== func 3 ====================
  0x4ad | 08          | size of function
  0x4ae | 00          | 0 local blocks
  0x4af | 20 00       | local_get local_index:0
  0x4b1 | fb 02 07 07 | struct_get struct_type_index:7 field_index:7
  0x4b5 | 0b          | end
============== func 4 ====================
  0x4b6 | 41          | size of function
  0x4b7 | 03          | 3 local blocks
  0x4b8 | 01 7f       | 1 locals of type I32
  0x4ba | 01 63 02    | 1 locals of type Ref((ref null (module 2)))
  0x4bd | 01 7f       | 1 locals of type I32
  0x4bf | 20 00       | local_get local_index:0
  0x4c1 | 21 01       | local_set local_index:1
  0x4c3 | 23 0d       | global_get global_index:13
  0x4c5 | 21 02       | local_set local_index:2
  0x4c7 | 03 40       | loop blockty:Empty
  0x4c9 | 20 02       | local_get local_index:2
  0x4cb | d1          | ref_is_null
  0x4cc | 04 40       | if blockty:Empty
  0x4ce | d0 07       | ref_null hty:Concrete(Module(7))
  0x4d0 | 0f          | return
  0x4d1 | 0b          | end
  0x4d2 | 20 02       | local_get local_index:2
  0x4d4 | d4          | ref_as_non_null
  0x4d5 | fb 02 02 01 | struct_get struct_type_index:2 field_index:1
  0x4d9 | 21 03       | local_set local_index:3
  0x4db | 20 03       | local_get local_index:3
  0x4dd | 20 01       | local_get local_index:1
  0x4df | 46          | i32_eq
  0x4e0 | 04 40       | if blockty:Empty
  0x4e2 | 20 02       | local_get local_index:2
  0x4e4 | fb 16 07    | ref_cast_non_null hty:Concrete(Module(7))
  0x4e7 | 0f          | return
  0x4e8 | 0b          | end
  0x4e9 | 20 02       | local_get local_index:2
  0x4eb | d4          | ref_as_non_null
  0x4ec | fb 02 02 04 | struct_get struct_type_index:2 field_index:4
  0x4f0 | 21 02       | local_set local_index:2
  0x4f2 | 0c 00       | br relative_depth:0
  0x4f4 | 0b          | end
  0x4f5 | d0 07       | ref_null hty:Concrete(Module(7))
  0x4f7 | 0b          | end
============== func 5 ====================
  0x4f8 | 0a          | size of function
  0x4f9 | 00          | 0 local blocks
  0x4fa | 20 00       | local_get local_index:0
  0x4fc | 20 01       | local_get local_index:1
  0x4fe | fb 05 07 09 | struct_set struct_type_index:7 field_index:9
  0x502 | 0b          | end
============== func 6 ====================
  0x503 | 0b          | size of function
  0x504 | 00          | 0 local blocks
  0x505 | 20 00       | local_get local_index:0
  0x507 | fb 17 08    | ref_cast_nullable hty:Concrete(Module(8))
  0x50a | 20 01       | local_get local_index:1
  0x50c | 10 22       | call function_index:34
  0x50e | 0b          | end
============== func 7 ====================
  0x50f | 09          | size of function
  0x510 | 00          | 0 local blocks
  0x511 | 20 00       | local_get local_index:0
  0x513 | fb 17 08    | ref_cast_nullable hty:Concrete(Module(8))
  0x516 | 10 23       | call function_index:35
  0x518 | 0b          | end
============== func 8 ====================
  0x519 | 06          | size of function
  0x51a | 00          | 0 local blocks
  0x51b | 20 00       | local_get local_index:0
  0x51d | 10 2b       | call function_index:43
  0x51f | 0b          | end
============== func 9 ====================
  0x520 | 06          | size of function
  0x521 | 00          | 0 local blocks
  0x522 | 20 00       | local_get local_index:0
  0x524 | 10 2a       | call function_index:42
  0x526 | 0b          | end
============== func 10 ====================
  0x527 | 06          | size of function
  0x528 | 00          | 0 local blocks
  0x529 | 20 00       | local_get local_index:0
  0x52b | 10 25       | call function_index:37
  0x52d | 0b          | end
============== func 11 ====================
  0x52e | 0b          | size of function
  0x52f | 00          | 0 local blocks
  0x530 | 20 00       | local_get local_index:0
  0x532 | 20 01       | local_get local_index:1
  0x534 | fb 17 05    | ref_cast_nullable hty:Concrete(Module(5))
  0x537 | 10 27       | call function_index:39
  0x539 | 0b          | end
============== func 12 ====================
  0x53a | 08          | size of function
  0x53b | 00          | 0 local blocks
  0x53c | 20 00       | local_get local_index:0
  0x53e | 20 01       | local_get local_index:1
  0x540 | 10 26       | call function_index:38
  0x542 | 0b          | end
============== func 13 ====================
  0x543 | 1b          | size of function
  0x544 | 00          | 0 local blocks
  0x545 | 20 02       | local_get local_index:2
  0x547 | fb 17 07    | ref_cast_nullable hty:Concrete(Module(7))
  0x54a | d1          | ref_is_null
  0x54b | 04 40       | if blockty:Empty
  0x54d | 0f          | return
  0x54e | 0b          | end
  0x54f | 20 00       | local_get local_index:0
  0x551 | 20 01       | local_get local_index:1
  0x553 | fb 17 05    | ref_cast_nullable hty:Concrete(Module(5))
  0x556 | 20 02       | local_get local_index:2
  0x558 | fb 17 07    | ref_cast_nullable hty:Concrete(Module(7))
  0x55b | d4          | ref_as_non_null
  0x55c | 10 28       | call function_index:40
  0x55e | 0b          | end
============== func 14 ====================
  0x55f | 1a          | size of function
  0x560 | 00          | 0 local blocks
  0x561 | 20 01       | local_get local_index:1
  0x563 | fb 17 07    | ref_cast_nullable hty:Concrete(Module(7))
  0x566 | d1          | ref_is_null
  0x567 | 04 40       | if blockty:Empty
  0x569 | d0 08       | ref_null hty:Concrete(Module(8))
  0x56b | 0f          | return
  0x56c | 0b          | end
  0x56d | 20 00       | local_get local_index:0
  0x56f | 20 01       | local_get local_index:1
  0x571 | fb 17 07    | ref_cast_nullable hty:Concrete(Module(7))
  0x574 | d4          | ref_as_non_null
  0x575 | 20 02       | local_get local_index:2
  0x577 | 10 29       | call function_index:41
  0x579 | 0b          | end
============== func 15 ====================
  0x57a | 0b          | size of function
  0x57b | 00          | 0 local blocks
  0x57c | 20 00       | local_get local_index:0
  0x57e | fb 17 08    | ref_cast_nullable hty:Concrete(Module(8))
  0x581 | 20 01       | local_get local_index:1
  0x583 | 10 32       | call function_index:50
  0x585 | 0b          | end
============== func 16 ====================
  0x586 | 09          | size of function
  0x587 | 00          | 0 local blocks
  0x588 | 20 00       | local_get local_index:0
  0x58a | fb 17 08    | ref_cast_nullable hty:Concrete(Module(8))
  0x58d | 24 0b       | global_set global_index:11
  0x58f | 0b          | end
============== func 17 ====================
  0x590 | 04          | size of function
  0x591 | 00          | 0 local blocks
  0x592 | 23 0b       | global_get global_index:11
  0x594 | 0b          | end
============== func 18 ====================
  0x595 | 0b          | size of function
  0x596 | 00          | 0 local blocks
  0x597 | 20 00       | local_get local_index:0
  0x599 | fb 17 08    | ref_cast_nullable hty:Concrete(Module(8))
  0x59c | fb 02 08 0a | struct_get struct_type_index:8 field_index:10
  0x5a0 | 0b          | end
============== func 19 ====================
  0x5a1 | 0b          | size of function
  0x5a2 | 00          | 0 local blocks
  0x5a3 | 20 00       | local_get local_index:0
  0x5a5 | fb 16 07    | ref_cast_non_null hty:Concrete(Module(7))
  0x5a8 | fb 02 07 05 | struct_get struct_type_index:7 field_index:5
  0x5ac | 0b          | end
============== func 20 ====================
  0x5ad | 16          | size of function
  0x5ae | 00          | 0 local blocks
  0x5af | 20 00       | local_get local_index:0
  0x5b1 | fb 17 08    | ref_cast_nullable hty:Concrete(Module(8))
  0x5b4 | fb 02 08 09 | struct_get struct_type_index:8 field_index:9
  0x5b8 | fb 02 07 05 | struct_get struct_type_index:7 field_index:5
  0x5bc | fb 17 00    | ref_cast_nullable hty:Concrete(Module(0))
  0x5bf | 20 01       | local_get local_index:1
  0x5c1 | 10 1e       | call function_index:30
  0x5c3 | 0b          | end
============== func 21 ====================
  0x5c4 | 0b          | size of function
  0x5c5 | 00          | 0 local blocks
  0x5c6 | 20 00       | local_get local_index:0
  0x5c8 | fb 16 08    | ref_cast_non_null hty:Concrete(Module(8))
  0x5cb | 20 01       | local_get local_index:1
  0x5cd | 10 14       | call function_index:20
  0x5cf | 0b          | end
============== func 22 ====================
  0x5d0 | 0b          | size of function
  0x5d1 | 00          | 0 local blocks
  0x5d2 | 20 00       | local_get local_index:0
  0x5d4 | fb 17 08    | ref_cast_nullable hty:Concrete(Module(8))
  0x5d7 | fb 02 08 09 | struct_get struct_type_index:8 field_index:9
  0x5db | 0b          | end
============== func 23 ====================
  0x5dc | 0b          | size of function
  0x5dd | 00          | 0 local blocks
  0x5de | 20 00       | local_get local_index:0
  0x5e0 | fb 17 00    | ref_cast_nullable hty:Concrete(Module(0))
  0x5e3 | 20 01       | local_get local_index:1
  0x5e5 | 10 1e       | call function_index:30
  0x5e7 | 0b          | end
============== func 24 ====================
  0x5e8 | 09          | size of function
  0x5e9 | 00          | 0 local blocks
  0x5ea | 20 00       | local_get local_index:0
  0x5ec | fb 17 00    | ref_cast_nullable hty:Concrete(Module(0))
  0x5ef | 10 1d       | call function_index:29
  0x5f1 | 0b          | end
============== func 25 ====================
  0x5f2 | 41          | size of function
  0x5f3 | 01          | 1 local blocks
  0x5f4 | 02 7f       | 2 locals of type I32
  0x5f6 | 20 00       | local_get local_index:0
  0x5f8 | d1          | ref_is_null
  0x5f9 | 04 40       | if blockty:Empty
  0x5fb | 41 00       | i32_const value:0
  0x5fd | 0f          | return
  0x5fe | 0b          | end
  0x5ff | 20 00       | local_get local_index:0
  0x601 | d4          | ref_as_non_null
  0x602 | fb 0f       | array_len
  0x604 | 21 01       | local_set local_index:1
  0x606 | 41 00       | i32_const value:0
  0x608 | 21 02       | local_set local_index:2
  0x60a | 03 40       | loop blockty:Empty
  0x60c | 20 02       | local_get local_index:2
  0x60e | 20 01       | local_get local_index:1
  0x610 | 4f          | i32_ge_u
  0x611 | 04 40       | if blockty:Empty
  0x613 | 23 15       | global_get global_index:21
  0x615 | 0f          | return
  0x616 | 0b          | end
  0x617 | 23 15       | global_get global_index:21
  0x619 | 20 02       | local_get local_index:2
  0x61b | 6a          | i32_add
  0x61c | 20 00       | local_get local_index:0
  0x61e | d4          | ref_as_non_null
  0x61f | 20 02       | local_get local_index:2
  0x621 | fb 0d 01    | array_get_u array_type_index:1
  0x624 | 3a 00 00    | i32_store8 memarg:MemArg { align: 0, max_align: 0, offset: 0, memory: 0 }
  0x627 | 20 02       | local_get local_index:2
  0x629 | 41 01       | i32_const value:1
  0x62b | 6a          | i32_add
  0x62c | 21 02       | local_set local_index:2
  0x62e | 0c 00       | br relative_depth:0
  0x630 | 0b          | end
  0x631 | 41 00       | i32_const value:0
  0x633 | 0b          | end
============== func 26 ====================
  0x634 | 10          | size of function
  0x635 | 00          | 0 local blocks
  0x636 | 20 00       | local_get local_index:0
  0x638 | d1          | ref_is_null
  0x639 | 04 40       | if blockty:Empty
  0x63b | 41 00       | i32_const value:0
  0x63d | 0f          | return
  0x63e | 0b          | end
  0x63f | 20 00       | local_get local_index:0
  0x641 | d4          | ref_as_non_null
  0x642 | fb 0f       | array_len
  0x644 | 0b          | end
============== func 27 ====================
  0x645 | 10          | size of function
  0x646 | 00          | 0 local blocks
  0x647 | 20 00       | local_get local_index:0
  0x649 | d1          | ref_is_null
  0x64a | 04 40       | if blockty:Empty
  0x64c | 41 00       | i32_const value:0
  0x64e | 0f          | return
  0x64f | 0b          | end
  0x650 | 20 00       | local_get local_index:0
  0x652 | d4          | ref_as_non_null
  0x653 | fb 0f       | array_len
  0x655 | 0b          | end
============== func 28 ====================
  0x656 | 31          | size of function
  0x657 | 01          | 1 local blocks
  0x658 | 01 7f       | 1 locals of type I32
  0x65a | 20 00       | local_get local_index:0
  0x65c | d1          | ref_is_null
  0x65d | 04 40       | if blockty:Empty
  0x65f | 41 00       | i32_const value:0
  0x661 | 0f          | return
  0x662 | 0b          | end
  0x663 | 20 00       | local_get local_index:0
  0x665 | d4          | ref_as_non_null
  0x666 | fb 0f       | array_len
  0x668 | 21 02       | local_set local_index:2
  0x66a | 20 01       | local_get local_index:1
  0x66c | 41 00       | i32_const value:0
  0x66e | 48          | i32_lt_s
  0x66f | 04 40       | if blockty:Empty
  0x671 | 41 00       | i32_const value:0
  0x673 | 0f          | return
  0x674 | 0b          | end
  0x675 | 20 01       | local_get local_index:1
  0x677 | 20 02       | local_get local_index:2
  0x679 | 4f          | i32_ge_u
  0x67a | 04 40       | if blockty:Empty
  0x67c | 41 00       | i32_const value:0
  0x67e | 0f          | return
  0x67f | 0b          | end
  0x680 | 20 00       | local_get local_index:0
  0x682 | 20 01       | local_get local_index:1
  0x684 | fb 0d 01    | array_get_u array_type_index:1
  0x687 | 0b          | end
============== func 29 ====================
  0x688 | 10          | size of function
  0x689 | 00          | 0 local blocks
  0x68a | 20 00       | local_get local_index:0
  0x68c | d1          | ref_is_null
  0x68d | 04 40       | if blockty:Empty
  0x68f | 41 00       | i32_const value:0
  0x691 | 0f          | return
  0x692 | 0b          | end
  0x693 | 20 00       | local_get local_index:0
  0x695 | d4          | ref_as_non_null
  0x696 | fb 0f       | array_len
  0x698 | 0b          | end
============== func 30 ====================
  0x699 | 31          | size of function
  0x69a | 01          | 1 local blocks
  0x69b | 01 7f       | 1 locals of type I32
  0x69d | 20 00       | local_get local_index:0
  0x69f | d1          | ref_is_null
  0x6a0 | 04 40       | if blockty:Empty
  0x6a2 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x6a4 | 0f          | return
  0x6a5 | 0b          | end
  0x6a6 | 20 00       | local_get local_index:0
  0x6a8 | d4          | ref_as_non_null
  0x6a9 | fb 0f       | array_len
  0x6ab | 21 02       | local_set local_index:2
  0x6ad | 20 01       | local_get local_index:1
  0x6af | 41 00       | i32_const value:0
  0x6b1 | 48          | i32_lt_s
  0x6b2 | 04 40       | if blockty:Empty
  0x6b4 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x6b6 | 0f          | return
  0x6b7 | 0b          | end
  0x6b8 | 20 01       | local_get local_index:1
  0x6ba | 20 02       | local_get local_index:2
  0x6bc | 4f          | i32_ge_u
  0x6bd | 04 40       | if blockty:Empty
  0x6bf | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x6c1 | 0f          | return
  0x6c2 | 0b          | end
  0x6c3 | 20 00       | local_get local_index:0
  0x6c5 | 20 01       | local_get local_index:1
  0x6c7 | fb 0b 00    | array_get array_type_index:0
  0x6ca | 0b          | end
============== func 31 ====================
  0x6cb | 07          | size of function
  0x6cc | 00          | 0 local blocks
  0x6cd | 20 00       | local_get local_index:0
  0x6cf | fb 14 6c    | ref_test_non_null hty:Abstract { shared: false, ty: I31 }
  0x6d2 | 0b          | end
============== func 32 ====================
  0x6d3 | 09          | size of function
  0x6d4 | 00          | 0 local blocks
  0x6d5 | 20 00       | local_get local_index:0
  0x6d7 | fb 16 6c    | ref_cast_non_null hty:Abstract { shared: false, ty: I31 }
  0x6da | fb 1d       | i31_get_s
  0x6dc | 0b          | end
============== func 33 ====================
  0x6dd | 0b          | size of function
  0x6de | 00          | 0 local blocks
  0x6df | 23 0c       | global_get global_index:12
  0x6e1 | 41 01       | i32_const value:1
  0x6e3 | 6a          | i32_add
  0x6e4 | 24 0c       | global_set global_index:12
  0x6e6 | 23 0c       | global_get global_index:12
  0x6e8 | 0b          | end
============== func 34 ====================
  0x6e9 | 37          | size of function
  0x6ea | 02          | 2 local blocks
  0x6eb | 01 64 00    | 1 locals of type Ref((ref (module 0)))
  0x6ee | 01 7f       | 1 locals of type I32
  0x6f0 | 20 00       | local_get local_index:0
  0x6f2 | fb 02 08 0d | struct_get struct_type_index:8 field_index:13
  0x6f6 | 21 02       | local_set local_index:2
  0x6f8 | 20 00       | local_get local_index:0
  0x6fa | fb 02 08 08 | struct_get struct_type_index:8 field_index:8
  0x6fe | 21 03       | local_set local_index:3
  0x700 | 20 03       | local_get local_index:3
  0x702 | 20 02       | local_get local_index:2
  0x704 | fb 0f       | array_len
  0x706 | 4f          | i32_ge_u
  0x707 | 04 40       | if blockty:Empty
  0x709 | 0f          | return
  0x70a | 0b          | end
  0x70b | 20 02       | local_get local_index:2
  0x70d | 20 03       | local_get local_index:3
  0x70f | 20 01       | local_get local_index:1
  0x711 | fb 0e 00    | array_set array_type_index:0
  0x714 | 20 00       | local_get local_index:0
  0x716 | 20 03       | local_get local_index:3
  0x718 | 41 01       | i32_const value:1
  0x71a | 6a          | i32_add
  0x71b | fb 05 08 08 | struct_set struct_type_index:8 field_index:8
  0x71f | 0f          | return
  0x720 | 0b          | end
============== func 35 ====================
  0x721 | 38          | size of function
  0x722 | 02          | 2 local blocks
  0x723 | 01 64 00    | 1 locals of type Ref((ref (module 0)))
  0x726 | 01 7f       | 1 locals of type I32
  0x728 | 20 00       | local_get local_index:0
  0x72a | fb 02 08 0d | struct_get struct_type_index:8 field_index:13
  0x72e | 21 01       | local_set local_index:1
  0x730 | 20 00       | local_get local_index:0
  0x732 | fb 02 08 08 | struct_get struct_type_index:8 field_index:8
  0x736 | 21 02       | local_set local_index:2
  0x738 | 20 02       | local_get local_index:2
  0x73a | 41 00       | i32_const value:0
  0x73c | 4d          | i32_le_u
  0x73d | 04 40       | if blockty:Empty
  0x73f | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x741 | 0f          | return
  0x742 | 0b          | end
  0x743 | 20 00       | local_get local_index:0
  0x745 | 20 02       | local_get local_index:2
  0x747 | 41 01       | i32_const value:1
  0x749 | 6b          | i32_sub
  0x74a | fb 05 08 08 | struct_set struct_type_index:8 field_index:8
  0x74e | 20 01       | local_get local_index:1
  0x750 | 20 02       | local_get local_index:2
  0x752 | 41 01       | i32_const value:1
  0x754 | 6b          | i32_sub
  0x755 | fb 0b 00    | array_get array_type_index:0
  0x758 | 0f          | return
  0x759 | 0b          | end
============== func 36 ====================
  0x75a | 2d          | size of function
  0x75b | 02          | 2 local blocks
  0x75c | 01 64 00    | 1 locals of type Ref((ref (module 0)))
  0x75f | 01 7f       | 1 locals of type I32
  0x761 | 20 00       | local_get local_index:0
  0x763 | fb 02 08 0d | struct_get struct_type_index:8 field_index:13
  0x767 | 21 01       | local_set local_index:1
  0x769 | 20 00       | local_get local_index:0
  0x76b | fb 02 08 08 | struct_get struct_type_index:8 field_index:8
  0x76f | 21 02       | local_set local_index:2
  0x771 | 20 02       | local_get local_index:2
  0x773 | 41 00       | i32_const value:0
  0x775 | 4d          | i32_le_u
  0x776 | 04 40       | if blockty:Empty
  0x778 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x77a | 0f          | return
  0x77b | 0b          | end
  0x77c | 20 01       | local_get local_index:1
  0x77e | 20 02       | local_get local_index:2
  0x780 | 41 01       | i32_const value:1
  0x782 | 6b          | i32_sub
  0x783 | fb 0b 00    | array_get array_type_index:0
  0x786 | 0f          | return
  0x787 | 0b          | end
============== func 37 ====================
  0x788 | 17          | size of function
  0x789 | 00          | 0 local blocks
  0x78a | 20 00       | local_get local_index:0
  0x78c | fb 14 6c    | ref_test_non_null hty:Abstract { shared: false, ty: I31 }
  0x78f | 04 63 05    | if blockty:Type(Ref((ref null (module 5))))
  0x792 | 23 05       | global_get global_index:5
  0x794 | 05          | else
  0x795 | 20 00       | local_get local_index:0
  0x797 | fb 16 02    | ref_cast_non_null hty:Concrete(Module(2))
  0x79a | fb 02 02 00 | struct_get struct_type_index:2 field_index:0
  0x79e | 0b          | end
  0x79f | 0b          | end
============== func 38 ====================
  0x7a0 | b6 01       | size of function
  0x7a2 | 05          | 5 local blocks
  0x7a3 | 02 63 05    | 2 locals of type Ref((ref null (module 5)))
  0x7a6 | 01 63 06    | 1 locals of type Ref((ref null (module 6)))
  0x7a9 | 02 63 00    | 2 locals of type Ref((ref null (module 0)))
  0x7ac | 02 7f       | 2 locals of type I32
  0x7ae | 01 6d       | 1 locals of type Ref(eqref)
  0x7b0 | 20 00       | local_get local_index:0
  0x7b2 | 10 25       | call function_index:37
  0x7b4 | 21 03       | local_set local_index:3
  0x7b6 | 03 40       | loop blockty:Empty
  0x7b8 | 20 03       | local_get local_index:3
  0x7ba | d1          | ref_is_null
  0x7bb | 04 40       | if blockty:Empty
  0x7bd | d0 07       | ref_null hty:Concrete(Module(7))
  0x7bf | 0f          | return
  0x7c0 | 0b          | end
  0x7c1 | 20 03       | local_get local_index:3
  0x7c3 | d4          | ref_as_non_null
  0x7c4 | fb 02 05 07 | struct_get struct_type_index:5 field_index:7
  0x7c8 | 22 04       | local_tee local_index:4
  0x7ca | d1          | ref_is_null
  0x7cb | 04 40       | if blockty:Empty
  0x7cd | 20 03       | local_get local_index:3
  0x7cf | d4          | ref_as_non_null
  0x7d0 | fb 02 05 06 | struct_get struct_type_index:5 field_index:6
  0x7d4 | 21 03       | local_set local_index:3
  0x7d6 | 0c 01       | br relative_depth:1
  0x7d8 | 0b          | end
  0x7d9 | 20 04       | local_get local_index:4
  0x7db | d4          | ref_as_non_null
  0x7dc | fb 02 06 06 | struct_get struct_type_index:6 field_index:6
  0x7e0 | 22 05       | local_tee local_index:5
  0x7e2 | d1          | ref_is_null
  0x7e3 | 04 40       | if blockty:Empty
  0x7e5 | 20 03       | local_get local_index:3
  0x7e7 | d4          | ref_as_non_null
  0x7e8 | fb 02 05 06 | struct_get struct_type_index:5 field_index:6
  0x7ec | 21 03       | local_set local_index:3
  0x7ee | 0c 01       | br relative_depth:1
  0x7f0 | 0b          | end
  0x7f1 | 20 04       | local_get local_index:4
  0x7f3 | d4          | ref_as_non_null
  0x7f4 | fb 02 06 07 | struct_get struct_type_index:6 field_index:7
  0x7f8 | 22 06       | local_tee local_index:6
  0x7fa | d1          | ref_is_null
  0x7fb | 04 40       | if blockty:Empty
  0x7fd | 20 03       | local_get local_index:3
  0x7ff | d4          | ref_as_non_null
  0x800 | fb 02 05 06 | struct_get struct_type_index:5 field_index:6
  0x804 | 21 03       | local_set local_index:3
  0x806 | 0c 01       | br relative_depth:1
  0x808 | 0b          | end
  0x809 | 20 04       | local_get local_index:4
  0x80b | d4          | ref_as_non_null
  0x80c | fb 02 06 08 | struct_get struct_type_index:6 field_index:8
  0x810 | 21 07       | local_set local_index:7
  0x812 | 41 00       | i32_const value:0
  0x814 | 21 08       | local_set local_index:8
  0x816 | 03 40       | loop blockty:Empty
  0x818 | 20 08       | local_get local_index:8
  0x81a | 20 07       | local_get local_index:7
  0x81c | 4f          | i32_ge_u
  0x81d | 04 40       | if blockty:Empty
  0x81f | 20 03       | local_get local_index:3
  0x821 | d4          | ref_as_non_null
  0x822 | fb 02 05 06 | struct_get struct_type_index:5 field_index:6
  0x826 | 21 03       | local_set local_index:3
  0x828 | 0c 02       | br relative_depth:2
  0x82a | 0b          | end
  0x82b | 20 05       | local_get local_index:5
  0x82d | d4          | ref_as_non_null
  0x82e | 20 08       | local_get local_index:8
  0x830 | fb 0b 00    | array_get array_type_index:0
  0x833 | 21 09       | local_set local_index:9
  0x835 | 20 09       | local_get local_index:9
  0x837 | 20 01       | local_get local_index:1
  0x839 | d3          | ref_eq
  0x83a | 04 40       | if blockty:Empty
  0x83c | 20 06       | local_get local_index:6
  0x83e | d4          | ref_as_non_null
  0x83f | 20 08       | local_get local_index:8
  0x841 | fb 0b 00    | array_get array_type_index:0
  0x844 | fb 16 07    | ref_cast_non_null hty:Concrete(Module(7))
  0x847 | 0f          | return
  0x848 | 0b          | end
  0x849 | 20 08       | local_get local_index:8
  0x84b | 41 01       | i32_const value:1
  0x84d | 6a          | i32_add
  0x84e | 21 08       | local_set local_index:8
  0x850 | 0c 00       | br relative_depth:0
  0x852 | 0b          | end
  0x853 | 0b          | end
  0x854 | d0 07       | ref_null hty:Concrete(Module(7))
  0x856 | 0f          | return
  0x857 | 0b          | end
============== func 39 ====================
  0x858 | 9a 01       | size of function
  0x85a | 04          | 4 local blocks
  0x85b | 01 63 00    | 1 locals of type Ref((ref null (module 0)))
  0x85e | 03 7f       | 3 locals of type I32
  0x860 | 01 63 09    | 1 locals of type Ref((ref null (module 9)))
  0x863 | 01 7f       | 1 locals of type I32
  0x865 | 23 14       | global_get global_index:20
  0x867 | 22 02       | local_tee local_index:2
  0x869 | d1          | ref_is_null
  0x86a | 04 40       | if blockty:Empty
  0x86c | d0 07       | ref_null hty:Concrete(Module(7))
  0x86e | 0f          | return
  0x86f | 0b          | end
  0x870 | 20 00       | local_get local_index:0
  0x872 | fb 16 02    | ref_cast_non_null hty:Concrete(Module(2))
  0x875 | fb 02 02 01 | struct_get struct_type_index:2 field_index:1
  0x879 | 20 01       | local_get local_index:1
  0x87b | d4          | ref_as_non_null
  0x87c | fb 02 05 01 | struct_get struct_type_index:5 field_index:1
  0x880 | 6a          | i32_add
  0x881 | 23 13       | global_get global_index:19
  0x883 | 70          | i32_rem_u
  0x884 | 21 05       | local_set local_index:5
  0x886 | 41 08       | i32_const value:8
  0x888 | 21 07       | local_set local_index:7
  0x88a | 03 40       | loop blockty:Empty
  0x88c | 20 07       | local_get local_index:7
  0x88e | 41 00       | i32_const value:0
  0x890 | 4c          | i32_le_s
  0x891 | 04 40       | if blockty:Empty
  0x893 | d0 07       | ref_null hty:Concrete(Module(7))
  0x895 | 0f          | return
  0x896 | 0b          | end
  0x897 | 20 02       | local_get local_index:2
  0x899 | d4          | ref_as_non_null
  0x89a | 20 05       | local_get local_index:5
  0x89c | fb 0b 00    | array_get array_type_index:0
  0x89f | fb 17 09    | ref_cast_nullable hty:Concrete(Module(9))
  0x8a2 | 22 06       | local_tee local_index:6
  0x8a4 | d1          | ref_is_null
  0x8a5 | 04 40       | if blockty:Empty
  0x8a7 | d0 07       | ref_null hty:Concrete(Module(7))
  0x8a9 | 0f          | return
  0x8aa | 0b          | end
  0x8ab | 20 06       | local_get local_index:6
  0x8ad | fb 16 09    | ref_cast_non_null hty:Concrete(Module(9))
  0x8b0 | 22 06       | local_tee local_index:6
  0x8b2 | fb 02 09 00 | struct_get struct_type_index:9 field_index:0
  0x8b6 | 20 00       | local_get local_index:0
  0x8b8 | d3          | ref_eq
  0x8b9 | 20 06       | local_get local_index:6
  0x8bb | fb 02 09 01 | struct_get struct_type_index:9 field_index:1
  0x8bf | 20 01       | local_get local_index:1
  0x8c1 | d3          | ref_eq
  0x8c2 | 71          | i32_and
  0x8c3 | 04 40       | if blockty:Empty
  0x8c5 | 20 06       | local_get local_index:6
  0x8c7 | 20 06       | local_get local_index:6
  0x8c9 | fb 02 09 03 | struct_get struct_type_index:9 field_index:3
  0x8cd | 41 01       | i32_const value:1
  0x8cf | 6a          | i32_add
  0x8d0 | fb 05 09 03 | struct_set struct_type_index:9 field_index:3
  0x8d4 | 20 06       | local_get local_index:6
  0x8d6 | fb 02 09 02 | struct_get struct_type_index:9 field_index:2
  0x8da | 0f          | return
  0x8db | 0b          | end
  0x8dc | 20 05       | local_get local_index:5
  0x8de | 41 01       | i32_const value:1
  0x8e0 | 6a          | i32_add
  0x8e1 | 23 13       | global_get global_index:19
  0x8e3 | 70          | i32_rem_u
  0x8e4 | 21 05       | local_set local_index:5
  0x8e6 | 20 07       | local_get local_index:7
  0x8e8 | 41 01       | i32_const value:1
  0x8ea | 6b          | i32_sub
  0x8eb | 21 07       | local_set local_index:7
  0x8ed | 0c 00       | br relative_depth:0
  0x8ef | 0b          | end
  0x8f0 | d0 07       | ref_null hty:Concrete(Module(7))
  0x8f2 | 0f          | return
  0x8f3 | 0b          | end
============== func 40 ====================
  0x8f4 | 40          | size of function
  0x8f5 | 03          | 3 local blocks
  0x8f6 | 01 63 00    | 1 locals of type Ref((ref null (module 0)))
  0x8f9 | 01 7f       | 1 locals of type I32
  0x8fb | 01 64 09    | 1 locals of type Ref((ref (module 9)))
  0x8fe | 23 14       | global_get global_index:20
  0x900 | 22 03       | local_tee local_index:3
  0x902 | d1          | ref_is_null
  0x903 | 04 40       | if blockty:Empty
  0x905 | 0f          | return
  0x906 | 0b          | end
  0x907 | 20 00       | local_get local_index:0
  0x909 | fb 16 02    | ref_cast_non_null hty:Concrete(Module(2))
  0x90c | fb 02 02 01 | struct_get struct_type_index:2 field_index:1
  0x910 | 20 01       | local_get local_index:1
  0x912 | d4          | ref_as_non_null
  0x913 | fb 02 05 01 | struct_get struct_type_index:5 field_index:1
  0x917 | 6a          | i32_add
  0x918 | 23 13       | global_get global_index:19
  0x91a | 70          | i32_rem_u
  0x91b | 21 04       | local_set local_index:4
  0x91d | 20 00       | local_get local_index:0
  0x91f | 20 01       | local_get local_index:1
  0x921 | 20 02       | local_get local_index:2
  0x923 | 41 01       | i32_const value:1
  0x925 | fb 00 09    | struct_new struct_type_index:9
  0x928 | 21 05       | local_set local_index:5
  0x92a | 20 03       | local_get local_index:3
  0x92c | d4          | ref_as_non_null
  0x92d | 20 04       | local_get local_index:4
  0x92f | 20 05       | local_get local_index:5
  0x931 | fb 0e 00    | array_set array_type_index:0
  0x934 | 0b          | end
============== func 41 ====================
  0x935 | 48          | size of function
  0x936 | 01          | 1 local blocks
  0x937 | 04 64 00    | 4 locals of type Ref((ref (module 0)))
  0x93a | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x93c | 41 14       | i32_const value:20
  0x93e | fb 06 00    | array_new array_type_index:0
  0x941 | 21 03       | local_set local_index:3
  0x943 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x945 | 41 00       | i32_const value:0
  0x947 | fb 06 00    | array_new array_type_index:0
  0x94a | 21 04       | local_set local_index:4
  0x94c | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x94e | 41 00       | i32_const value:0
  0x950 | fb 06 00    | array_new array_type_index:0
  0x953 | 21 05       | local_set local_index:5
  0x955 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x957 | 41 00       | i32_const value:0
  0x959 | fb 06 00    | array_new array_type_index:0
  0x95c | 21 06       | local_set local_index:6
  0x95e | 23 00       | global_get global_index:0
  0x960 | 10 21       | call function_index:33
  0x962 | 41 0e       | i32_const value:14
  0x964 | 41 0e       | i32_const value:14
  0x966 | d0 02       | ref_null hty:Concrete(Module(2))
  0x968 | 20 04       | local_get local_index:4
  0x96a | 23 0b       | global_get global_index:11
  0x96c | 41 00       | i32_const value:0
  0x96e | 41 00       | i32_const value:0
  0x970 | 20 01       | local_get local_index:1
  0x972 | 20 00       | local_get local_index:0
  0x974 | 20 05       | local_get local_index:5
  0x976 | 20 06       | local_get local_index:6
  0x978 | 20 03       | local_get local_index:3
  0x97a | fb 00 08    | struct_new struct_type_index:8
  0x97d | 0b          | end
============== func 42 ====================
  0x97e | 06          | size of function
  0x97f | 00          | 0 local blocks
  0x980 | 20 00       | local_get local_index:0
  0x982 | fb 1c       | ref_i31
  0x984 | 0b          | end
============== func 43 ====================
  0x985 | 14          | size of function
  0x986 | 00          | 0 local blocks
  0x987 | 20 00       | local_get local_index:0
  0x989 | fb 14 6c    | ref_test_non_null hty:Abstract { shared: false, ty: I31 }
  0x98c | 04 7f       | if blockty:Type(I32)
  0x98e | 20 00       | local_get local_index:0
  0x990 | fb 16 6c    | ref_cast_non_null hty:Abstract { shared: false, ty: I31 }
  0x993 | fb 1d       | i31_get_s
  0x995 | 05          | else
  0x996 | 41 00       | i32_const value:0
  0x998 | 0b          | end
  0x999 | 0b          | end
============== func 44 ====================
  0x99a | 0b          | size of function
  0x99b | 00          | 0 local blocks
  0x99c | 20 00       | local_get local_index:0
  0x99e | fb 02 07 09 | struct_get struct_type_index:7 field_index:9
  0x9a2 | 41 00       | i32_const value:0
  0x9a4 | 4b          | i32_gt_u
  0x9a5 | 0b          | end
============== func 45 ====================
  0x9a6 | 09          | size of function
  0x9a7 | 00          | 0 local blocks
  0x9a8 | 20 00       | local_get local_index:0
  0x9aa | 20 01       | local_get local_index:1
  0x9ac | 11 13 00    | call_indirect type_index:19 table_index:0
  0x9af | 0b          | end
============== func 46 ====================
  0x9b0 | 25          | size of function
  0x9b1 | 02          | 2 local blocks
  0x9b2 | 01 63 01    | 1 locals of type Ref((ref null (module 1)))
  0x9b5 | 03 7f       | 3 locals of type I32
  0x9b7 | 20 00       | local_get local_index:0
  0x9b9 | fb 02 07 07 | struct_get struct_type_index:7 field_index:7
  0x9bd | 22 01       | local_tee local_index:1
  0x9bf | d1          | ref_is_null
  0x9c0 | 04 40       | if blockty:Empty
  0x9c2 | 0f          | return
  0x9c3 | 0b          | end
  0x9c4 | 20 01       | local_get local_index:1
  0x9c6 | d4          | ref_as_non_null
  0x9c7 | fb 0f       | array_len
  0x9c9 | 21 02       | local_set local_index:2
  0x9cb | 20 00       | local_get local_index:0
  0x9cd | fb 02 07 01 | struct_get struct_type_index:7 field_index:1
  0x9d1 | 20 02       | local_get local_index:2
  0x9d3 | 10 01       | call function_index:1
  0x9d5 | 0b          | end
============== func 47 ====================
  0x9d6 | 45          | size of function
  0x9d7 | 02          | 2 local blocks
  0x9d8 | 01 63 08    | 1 locals of type Ref((ref null (module 8)))
  0x9db | 01 6d       | 1 locals of type Ref(eqref)
  0x9dd | 20 00       | local_get local_index:0
  0x9df | 10 24       | call function_index:36
  0x9e1 | 21 02       | local_set local_index:2
  0x9e3 | 20 00       | local_get local_index:0
  0x9e5 | fb 02 08 06 | struct_get struct_type_index:8 field_index:6
  0x9e9 | 22 01       | local_tee local_index:1
  0x9eb | d1          | ref_is_null
  0x9ec | 45          | i32_eqz
  0x9ed | 04 40       | if blockty:Empty
  0x9ef | 20 01       | local_get local_index:1
  0x9f1 | d4          | ref_as_non_null
  0x9f2 | 20 02       | local_get local_index:2
  0x9f4 | d4          | ref_as_non_null
  0x9f5 | 10 22       | call function_index:34
  0x9f7 | 20 01       | local_get local_index:1
  0x9f9 | d4          | ref_as_non_null
  0x9fa | 20 01       | local_get local_index:1
  0x9fc | d4          | ref_as_non_null
  0x9fd | fb 02 08 07 | struct_get struct_type_index:8 field_index:7
  0xa01 | 41 01       | i32_const value:1
  0xa03 | 6a          | i32_add
  0xa04 | fb 05 08 07 | struct_set struct_type_index:8 field_index:7
  0xa08 | 0b          | end
  0xa09 | 20 01       | local_get local_index:1
  0xa0b | d1          | ref_is_null
  0xa0c | 04 40       | if blockty:Empty
  0xa0e | d0 08       | ref_null hty:Concrete(Module(8))
  0xa10 | 24 0b       | global_set global_index:11
  0xa12 | 05          | else
  0xa13 | 20 01       | local_get local_index:1
  0xa15 | d4          | ref_as_non_null
  0xa16 | 24 0b       | global_set global_index:11
  0xa18 | 0b          | end
  0xa19 | 20 02       | local_get local_index:2
  0xa1b | 0b          | end
============== func 48 ====================
  0xa1c | 04          | size of function
  0xa1d | 00          | 0 local blocks
  0xa1e | 10 31       | call function_index:49
  0xa20 | 0b          | end
============== func 49 ====================
  0xa21 | bc 06       | size of function
  0xa23 | 09          | 9 local blocks
  0xa24 | 02 63 07    | 2 locals of type Ref((ref null (module 7)))
  0xa27 | 02 63 01    | 2 locals of type Ref((ref null (module 1)))
  0xa2a | 01 63 04    | 1 locals of type Ref((ref null (module 4)))
  0xa2d | 01 63 06    | 1 locals of type Ref((ref null (module 6)))
  0xa30 | 01 63 02    | 1 locals of type Ref((ref null (module 2)))
  0xa33 | 03 64 00    | 3 locals of type Ref((ref (module 0)))
  0xa36 | 01 64 06    | 1 locals of type Ref((ref (module 6)))
  0xa39 | 01 64 04    | 1 locals of type Ref((ref (module 4)))
  0xa3c | 02 64 00    | 2 locals of type Ref((ref (module 0)))
  0xa3f | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xa41 | 23 13       | global_get global_index:19
  0xa43 | fb 06 00    | array_new array_type_index:0
  0xa46 | d4          | ref_as_non_null
  0xa47 | 24 14       | global_set global_index:20
  0xa49 | 23 00       | global_get global_index:0
  0xa4b | 10 21       | call function_index:33
  0xa4d | 41 02       | i32_const value:2
  0xa4f | 41 09       | i32_const value:9
  0xa51 | d0 02       | ref_null hty:Concrete(Module(2))
  0xa53 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xa55 | 41 00       | i32_const value:0
  0xa57 | fb 06 00    | array_new array_type_index:0
  0xa5a | d4          | ref_as_non_null
  0xa5b | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xa5d | 41 00       | i32_const value:0
  0xa5f | fb 06 00    | array_new array_type_index:0
  0xa62 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xa64 | 41 00       | i32_const value:0
  0xa66 | fb 06 00    | array_new array_type_index:0
  0xa69 | 41 00       | i32_const value:0
  0xa6b | fb 00 06    | struct_new struct_type_index:6
  0xa6e | 21 0a       | local_set local_index:10
  0xa70 | 23 00       | global_get global_index:0
  0xa72 | 10 21       | call function_index:33
  0xa74 | 41 08       | i32_const value:8
  0xa76 | 41 07       | i32_const value:7
  0xa78 | d0 02       | ref_null hty:Concrete(Module(2))
  0xa7a | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xa7c | 41 00       | i32_const value:0
  0xa7e | fb 06 00    | array_new array_type_index:0
  0xa81 | d4          | ref_as_non_null
  0xa82 | d0 01       | ref_null hty:Concrete(Module(1))
  0xa84 | fb 00 04    | struct_new struct_type_index:4
  0xa87 | 21 0b       | local_set local_index:11
  0xa89 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xa8b | 41 00       | i32_const value:0
  0xa8d | fb 06 00    | array_new array_type_index:0
  0xa90 | d4          | ref_as_non_null
  0xa91 | 21 0c       | local_set local_index:12
  0xa93 | d0 05       | ref_null hty:Concrete(Module(5))
  0xa95 | 10 21       | call function_index:33
  0xa97 | 41 01       | i32_const value:1
  0xa99 | 41 0b       | i32_const value:11
  0xa9b | d0 02       | ref_null hty:Concrete(Module(2))
  0xa9d | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xa9f | 41 00       | i32_const value:0
  0xaa1 | fb 06 00    | array_new array_type_index:0
  0xaa4 | d4          | ref_as_non_null
  0xaa5 | d0 05       | ref_null hty:Concrete(Module(5))
  0xaa7 | 20 0a       | local_get local_index:10
  0xaa9 | 20 0c       | local_get local_index:12
  0xaab | 20 0b       | local_get local_index:11
  0xaad | 41 00       | i32_const value:0
  0xaaf | fb 00 05    | struct_new struct_type_index:5
  0xab2 | 21 06       | local_set local_index:6
  0xab4 | 20 06       | local_get local_index:6
  0xab6 | fb 17 05    | ref_cast_nullable hty:Concrete(Module(5))
  0xab9 | 24 01       | global_set global_index:1
  0xabb | 23 01       | global_get global_index:1
  0xabd | 20 06       | local_get local_index:6
  0xabf | fb 17 05    | ref_cast_nullable hty:Concrete(Module(5))
  0xac2 | fb 05 05 00 | struct_set struct_type_index:5 field_index:0
  0xac6 | 20 06       | local_get local_index:6
  0xac8 | 24 0d       | global_set global_index:13
  0xaca | 20 06       | local_get local_index:6
  0xacc | 24 0e       | global_set global_index:14
  0xace | 23 01       | global_get global_index:1
  0xad0 | 10 21       | call function_index:33
  0xad2 | 41 01       | i32_const value:1
  0xad4 | 41 0b       | i32_const value:11
  0xad6 | d0 02       | ref_null hty:Concrete(Module(2))
  0xad8 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xada | 41 00       | i32_const value:0
  0xadc | fb 06 00    | array_new array_type_index:0
  0xadf | d4          | ref_as_non_null
  0xae0 | d0 05       | ref_null hty:Concrete(Module(5))
  0xae2 | 20 0a       | local_get local_index:10
  0xae4 | 20 0c       | local_get local_index:12
  0xae6 | 20 0b       | local_get local_index:11
  0xae8 | 41 00       | i32_const value:0
  0xaea | fb 00 05    | struct_new struct_type_index:5
  0xaed | 21 06       | local_set local_index:6
  0xaef | 23 0e       | global_get global_index:14
  0xaf1 | d4          | ref_as_non_null
  0xaf2 | 20 06       | local_get local_index:6
  0xaf4 | fb 05 02 04 | struct_set struct_type_index:2 field_index:4
  0xaf8 | 20 06       | local_get local_index:6
  0xafa | 24 0e       | global_set global_index:14
  0xafc | 20 06       | local_get local_index:6
  0xafe | fb 17 05    | ref_cast_nullable hty:Concrete(Module(5))
  0xb01 | 24 00       | global_set global_index:0
  0xb03 | 23 01       | global_get global_index:1
  0xb05 | 10 21       | call function_index:33
  0xb07 | 41 01       | i32_const value:1
  0xb09 | 41 0b       | i32_const value:11
  0xb0b | d0 02       | ref_null hty:Concrete(Module(2))
  0xb0d | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xb0f | 41 00       | i32_const value:0
  0xb11 | fb 06 00    | array_new array_type_index:0
  0xb14 | d4          | ref_as_non_null
  0xb15 | 23 00       | global_get global_index:0
  0xb17 | fb 17 05    | ref_cast_nullable hty:Concrete(Module(5))
  0xb1a | 20 0a       | local_get local_index:10
  0xb1c | 20 0c       | local_get local_index:12
  0xb1e | 20 0b       | local_get local_index:11
  0xb20 | 41 00       | i32_const value:0
  0xb22 | fb 00 05    | struct_new struct_type_index:5
  0xb25 | 21 06       | local_set local_index:6
  0xb27 | 23 0e       | global_get global_index:14
  0xb29 | d4          | ref_as_non_null
  0xb2a | 20 06       | local_get local_index:6
  0xb2c | fb 05 02 04 | struct_set struct_type_index:2 field_index:4
  0xb30 | 20 06       | local_get local_index:6
  0xb32 | 24 0e       | global_set global_index:14
  0xb34 | 20 06       | local_get local_index:6
  0xb36 | fb 17 05    | ref_cast_nullable hty:Concrete(Module(5))
  0xb39 | 24 05       | global_set global_index:5
  0xb3b | 23 00       | global_get global_index:0
  0xb3d | 10 21       | call function_index:33
  0xb3f | 41 02       | i32_const value:2
  0xb41 | 41 09       | i32_const value:9
  0xb43 | d0 02       | ref_null hty:Concrete(Module(2))
  0xb45 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xb47 | 41 00       | i32_const value:0
  0xb49 | fb 06 00    | array_new array_type_index:0
  0xb4c | d4          | ref_as_non_null
  0xb4d | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xb4f | 41 01       | i32_const value:1
  0xb51 | fb 06 00    | array_new array_type_index:0
  0xb54 | d4          | ref_as_non_null
  0xb55 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xb57 | 41 01       | i32_const value:1
  0xb59 | fb 06 00    | array_new array_type_index:0
  0xb5c | d4          | ref_as_non_null
  0xb5d | 41 00       | i32_const value:0
  0xb5f | fb 00 06    | struct_new struct_type_index:6
  0xb62 | 21 06       | local_set local_index:6
  0xb64 | 23 0e       | global_get global_index:14
  0xb66 | d4          | ref_as_non_null
  0xb67 | 20 06       | local_get local_index:6
  0xb69 | fb 05 02 04 | struct_set struct_type_index:2 field_index:4
  0xb6d | 20 06       | local_get local_index:6
  0xb6f | 24 0e       | global_set global_index:14
  0xb71 | 20 06       | local_get local_index:6
  0xb73 | fb 17 06    | ref_cast_nullable hty:Concrete(Module(6))
  0xb76 | 21 05       | local_set local_index:5
  0xb78 | 41 f0 00    | i32_const value:112
  0xb7b | 41 d0 01    | i32_const value:208
  0xb7e | 41 fc 00    | i32_const value:124
  0xb81 | fb 08 01 03 | array_new_fixed array_type_index:1 array_size:3
  0xb85 | 21 02       | local_set local_index:2
  0xb87 | 41 f0 00    | i32_const value:112
  0xb8a | 41 21       | i32_const value:33
  0xb8c | 41 b0 01    | i32_const value:176
  0xb8f | 41 22       | i32_const value:34
  0xb91 | 41 b8 01    | i32_const value:184
  0xb94 | 41 22       | i32_const value:34
  0xb96 | 41 b0 01    | i32_const value:176
  0xb99 | 41 23       | i32_const value:35
  0xb9b | 41 b8 01    | i32_const value:184
  0xb9e | 41 23       | i32_const value:35
  0xba0 | 41 b0 01    | i32_const value:176
  0xba3 | 41 22       | i32_const value:34
  0xba5 | 41 b8 01    | i32_const value:184
  0xba8 | 41 21       | i32_const value:33
  0xbaa | 41 b0 01    | i32_const value:176
  0xbad | 41 22       | i32_const value:34
  0xbaf | 41 b8 01    | i32_const value:184
  0xbb2 | 41 22       | i32_const value:34
  0xbb4 | 41 b0 01    | i32_const value:176
  0xbb7 | 41 23       | i32_const value:35
  0xbb9 | 41 b8 01    | i32_const value:184
  0xbbc | 41 23       | i32_const value:35
  0xbbe | 41 b0 01    | i32_const value:176
  0xbc1 | 41 22       | i32_const value:34
  0xbc3 | 41 b8 01    | i32_const value:184
  0xbc6 | 41 21       | i32_const value:33
  0xbc8 | 41 b0 01    | i32_const value:176
  0xbcb | 41 22       | i32_const value:34
  0xbcd | 41 b8 01    | i32_const value:184
  0xbd0 | 41 22       | i32_const value:34
  0xbd2 | 41 b0 01    | i32_const value:176
  0xbd5 | 41 23       | i32_const value:35
  0xbd7 | 41 b8 01    | i32_const value:184
  0xbda | 41 23       | i32_const value:35
  0xbdc | 41 b0 01    | i32_const value:176
  0xbdf | 41 22       | i32_const value:34
  0xbe1 | 41 b8 01    | i32_const value:184
  0xbe4 | 41 21       | i32_const value:33
  0xbe6 | 41 b0 01    | i32_const value:176
  0xbe9 | 41 22       | i32_const value:34
  0xbeb | 41 b8 01    | i32_const value:184
  0xbee | 41 22       | i32_const value:34
  0xbf0 | 41 b0 01    | i32_const value:176
  0xbf3 | 41 23       | i32_const value:35
  0xbf5 | 41 b8 01    | i32_const value:184
  0xbf8 | 41 23       | i32_const value:35
  0xbfa | 41 b0 01    | i32_const value:176
  0xbfd | 41 22       | i32_const value:34
  0xbff | 41 b8 01    | i32_const value:184
  0xc02 | 41 21       | i32_const value:33
  0xc04 | 41 b0 01    | i32_const value:176
  0xc07 | 41 22       | i32_const value:34
  0xc09 | 41 b8 01    | i32_const value:184
  0xc0c | 41 22       | i32_const value:34
  0xc0e | 41 b0 01    | i32_const value:176
  0xc11 | 41 23       | i32_const value:35
  0xc13 | 41 b8 01    | i32_const value:184
  0xc16 | 41 23       | i32_const value:35
  0xc18 | 41 b0 01    | i32_const value:176
  0xc1b | 41 22       | i32_const value:34
  0xc1d | 41 b8 01    | i32_const value:184
  0xc20 | 41 fc 00    | i32_const value:124
  0xc23 | fb 08 01 3e | array_new_fixed array_type_index:1 array_size:62
  0xc27 | 21 03       | local_set local_index:3
  0xc29 | 23 00       | global_get global_index:0
  0xc2b | 10 21       | call function_index:33
  0xc2d | 41 08       | i32_const value:8
  0xc2f | 41 07       | i32_const value:7
  0xc31 | d0 02       | ref_null hty:Concrete(Module(2))
  0xc33 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xc35 | 41 00       | i32_const value:0
  0xc37 | fb 06 00    | array_new array_type_index:0
  0xc3a | d4          | ref_as_non_null
  0xc3b | 41 f7 00    | i32_const value:119
  0xc3e | 41 ef 00    | i32_const value:111
  0xc41 | 41 f2 00    | i32_const value:114
  0xc44 | 41 eb 00    | i32_const value:107
  0xc47 | 41 ec 00    | i32_const value:108
  0xc4a | 41 ef 00    | i32_const value:111
  0xc4d | 41 e1 00    | i32_const value:97
  0xc50 | 41 e4 00    | i32_const value:100
  0xc53 | fb 08 01 08 | array_new_fixed array_type_index:1 array_size:8
  0xc57 | fb 00 04    | struct_new struct_type_index:4
  0xc5a | 21 04       | local_set local_index:4
  0xc5c | 23 0e       | global_get global_index:14
  0xc5e | d4          | ref_as_non_null
  0xc5f | 20 04       | local_get local_index:4
  0xc61 | d4          | ref_as_non_null
  0xc62 | fb 05 02 04 | struct_set struct_type_index:2 field_index:4
  0xc66 | 20 04       | local_get local_index:4
  0xc68 | d4          | ref_as_non_null
  0xc69 | 24 0e       | global_set global_index:14
  0xc6b | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xc6d | 41 01       | i32_const value:1
  0xc6f | fb 06 00    | array_new array_type_index:0
  0xc72 | 21 07       | local_set local_index:7
  0xc74 | 20 07       | local_get local_index:7
  0xc76 | 41 00       | i32_const value:0
  0xc78 | 20 04       | local_get local_index:4
  0xc7a | d4          | ref_as_non_null
  0xc7b | fb 0e 00    | array_set array_type_index:0
  0xc7e | 23 00       | global_get global_index:0
  0xc80 | 10 21       | call function_index:33
  0xc82 | 41 06       | i32_const value:6
  0xc84 | 41 0e       | i32_const value:14
  0xc86 | d0 02       | ref_null hty:Concrete(Module(2))
  0xc88 | 20 07       | local_get local_index:7
  0xc8a | 41 00       | i32_const value:0
  0xc8c | 20 02       | local_get local_index:2
  0xc8e | 41 00       | i32_const value:0
  0xc90 | 41 00       | i32_const value:0
  0xc92 | 41 e8 07    | i32_const value:1000
  0xc95 | 41 00       | i32_const value:0
  0xc97 | fb 00 07    | struct_new struct_type_index:7
  0xc9a | 21 06       | local_set local_index:6
  0xc9c | 20 06       | local_get local_index:6
  0xc9e | fb 17 07    | ref_cast_nullable hty:Concrete(Module(7))
  0xca1 | 21 01       | local_set local_index:1
  0xca3 | 23 0e       | global_get global_index:14
  0xca5 | d4          | ref_as_non_null
  0xca6 | 20 06       | local_get local_index:6
  0xca8 | fb 05 02 04 | struct_set struct_type_index:2 field_index:4
  0xcac | 20 06       | local_get local_index:6
  0xcae | 24 0e       | global_set global_index:14
  0xcb0 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xcb2 | 41 04       | i32_const value:4
  0xcb4 | fb 06 00    | array_new array_type_index:0
  0xcb7 | d4          | ref_as_non_null
  0xcb8 | 21 0d       | local_set local_index:13
  0xcba | 20 0d       | local_get local_index:13
  0xcbc | 41 00       | i32_const value:0
  0xcbe | 41 00       | i32_const value:0
  0xcc0 | 10 2a       | call function_index:42
  0xcc2 | d4          | ref_as_non_null
  0xcc3 | fb 0e 00    | array_set array_type_index:0
  0xcc6 | 20 0d       | local_get local_index:13
  0xcc8 | 41 01       | i32_const value:1
  0xcca | 41 01       | i32_const value:1
  0xccc | 10 2a       | call function_index:42
  0xcce | d4          | ref_as_non_null
  0xccf | fb 0e 00    | array_set array_type_index:0
  0xcd2 | 20 0d       | local_get local_index:13
  0xcd4 | 41 02       | i32_const value:2
  0xcd6 | 41 02       | i32_const value:2
  0xcd8 | 10 2a       | call function_index:42
  0xcda | d4          | ref_as_non_null
  0xcdb | fb 0e 00    | array_set array_type_index:0
  0xcde | 20 0d       | local_get local_index:13
  0xce0 | 41 03       | i32_const value:3
  0xce2 | 41 03       | i32_const value:3
  0xce4 | 10 2a       | call function_index:42
  0xce6 | d4          | ref_as_non_null
  0xce7 | fb 0e 00    | array_set array_type_index:0
  0xcea | 23 00       | global_get global_index:0
  0xcec | 10 21       | call function_index:33
  0xcee | 41 06       | i32_const value:6
  0xcf0 | 41 0e       | i32_const value:14
  0xcf2 | d0 02       | ref_null hty:Concrete(Module(2))
  0xcf4 | 20 0d       | local_get local_index:13
  0xcf6 | 41 00       | i32_const value:0
  0xcf8 | 20 03       | local_get local_index:3
  0xcfa | 41 00       | i32_const value:0
  0xcfc | 41 00       | i32_const value:0
  0xcfe | 41 e8 07    | i32_const value:1000
  0xd01 | 41 00       | i32_const value:0
  0xd03 | fb 00 07    | struct_new struct_type_index:7
  0xd06 | 21 06       | local_set local_index:6
  0xd08 | 20 06       | local_get local_index:6
  0xd0a | fb 17 07    | ref_cast_nullable hty:Concrete(Module(7))
  0xd0d | 21 00       | local_set local_index:0
  0xd0f | 23 0e       | global_get global_index:14
  0xd11 | d4          | ref_as_non_null
  0xd12 | 20 06       | local_get local_index:6
  0xd14 | fb 05 02 04 | struct_set struct_type_index:2 field_index:4
  0xd18 | 20 06       | local_get local_index:6
  0xd1a | 24 0e       | global_set global_index:14
  0xd1c | 23 05       | global_get global_index:5
  0xd1e | d4          | ref_as_non_null
  0xd1f | 20 05       | local_get local_index:5
  0xd21 | d4          | ref_as_non_null
  0xd22 | fb 05 05 07 | struct_set struct_type_index:5 field_index:7
  0xd26 | 20 05       | local_get local_index:5
  0xd28 | d4          | ref_as_non_null
  0xd29 | fb 02 06 06 | struct_get struct_type_index:6 field_index:6
  0xd2d | d4          | ref_as_non_null
  0xd2e | 41 00       | i32_const value:0
  0xd30 | 20 04       | local_get local_index:4
  0xd32 | d4          | ref_as_non_null
  0xd33 | fb 0e 00    | array_set array_type_index:0
  0xd36 | 20 05       | local_get local_index:5
  0xd38 | d4          | ref_as_non_null
  0xd39 | fb 02 06 07 | struct_get struct_type_index:6 field_index:7
  0xd3d | d4          | ref_as_non_null
  0xd3e | 41 00       | i32_const value:0
  0xd40 | 20 00       | local_get local_index:0
  0xd42 | d4          | ref_as_non_null
  0xd43 | fb 0e 00    | array_set array_type_index:0
  0xd46 | 20 05       | local_get local_index:5
  0xd48 | d4          | ref_as_non_null
  0xd49 | 41 01       | i32_const value:1
  0xd4b | fb 05 06 08 | struct_set struct_type_index:6 field_index:8
  0xd4f | 20 00       | local_get local_index:0
  0xd51 | d4          | ref_as_non_null
  0xd52 | 41 01       | i32_const value:1
  0xd54 | fb 05 07 0b | struct_set struct_type_index:7 field_index:11
  0xd58 | 20 01       | local_get local_index:1
  0xd5a | 24 06       | global_set global_index:6
  0xd5c | 41 01       | i32_const value:1
  0xd5e | 0b          | end
============== func 50 ====================
  0xd5f | 9e 03       | size of function
  0xd61 | 08          | 8 local blocks
  0xd62 | 03 6d       | 3 locals of type Ref(eqref)
  0xd64 | 03 7f       | 3 locals of type I32
  0xd66 | 01 63 08    | 1 locals of type Ref((ref null (module 8)))
  0xd69 | 01 6d       | 1 locals of type Ref(eqref)
  0xd6b | 01 63 07    | 1 locals of type Ref((ref null (module 7)))
  0xd6e | 01 63 05    | 1 locals of type Ref((ref null (module 5)))
  0xd71 | 01 7f       | 1 locals of type I32
  0xd73 | 01 63 00    | 1 locals of type Ref((ref null (module 0)))
  0xd76 | 20 01       | local_get local_index:1
  0xd78 | 41 20       | i32_const value:32
  0xd7a | 4f          | i32_ge_u
  0xd7b | 20 01       | local_get local_index:1
  0xd7d | 41 2f       | i32_const value:47
  0xd7f | 4d          | i32_le_u
  0xd80 | 71          | i32_and
  0xd81 | 04 40       | if blockty:Empty
  0xd83 | 20 01       | local_get local_index:1
  0xd85 | 41 20       | i32_const value:32
  0xd87 | 6b          | i32_sub
  0xd88 | 21 0c       | local_set local_index:12
  0xd8a | 20 00       | local_get local_index:0
  0xd8c | fb 02 08 09 | struct_get struct_type_index:8 field_index:9
  0xd90 | d4          | ref_as_non_null
  0xd91 | fb 02 07 05 | struct_get struct_type_index:7 field_index:5
  0xd95 | d4          | ref_as_non_null
  0xd96 | 22 0d       | local_tee local_index:13
  0xd98 | 20 0c       | local_get local_index:12
  0xd9a | 20 0d       | local_get local_index:13
  0xd9c | fb 0f       | array_len
  0xd9e | 4f          | i32_ge_u
  0xd9f | 04 40       | if blockty:Empty
  0xda1 | 20 00       | local_get local_index:0
  0xda3 | 41 00       | i32_const value:0
  0xda5 | 10 2a       | call function_index:42
  0xda7 | d4          | ref_as_non_null
  0xda8 | 10 22       | call function_index:34
  0xdaa | 05          | else
  0xdab | 20 00       | local_get local_index:0
  0xdad | 20 0d       | local_get local_index:13
  0xdaf | 20 0c       | local_get local_index:12
  0xdb1 | fb 0b 00    | array_get array_type_index:0
  0xdb4 | d4          | ref_as_non_null
  0xdb5 | 10 22       | call function_index:34
  0xdb7 | 0b          | end
  0xdb8 | 41 00       | i32_const value:0
  0xdba | 0f          | return
  0xdbb | 0b          | end
  0xdbc | 20 01       | local_get local_index:1
  0xdbe | 41 f0 00    | i32_const value:112
  0xdc1 | 46          | i32_eq
  0xdc2 | 04 40       | if blockty:Empty
  0xdc4 | 20 00       | local_get local_index:0
  0xdc6 | 20 00       | local_get local_index:0
  0xdc8 | fb 02 08 0a | struct_get struct_type_index:8 field_index:10
  0xdcc | d4          | ref_as_non_null
  0xdcd | 10 22       | call function_index:34
  0xdcf | 41 00       | i32_const value:0
  0xdd1 | 0f          | return
  0xdd2 | 0b          | end
  0xdd3 | 20 01       | local_get local_index:1
  0xdd5 | 41 b8 01    | i32_const value:184
  0xdd8 | 46          | i32_eq
  0xdd9 | 04 40       | if blockty:Empty
  0xddb | 20 00       | local_get local_index:0
  0xddd | 10 23       | call function_index:35
  0xddf | 22 04       | local_tee local_index:4
  0xde1 | d1          | ref_is_null
  0xde2 | 04 40       | if blockty:Empty
  0xde4 | 41 00       | i32_const value:0
  0xde6 | 0f          | return
  0xde7 | 0b          | end
  0xde8 | 20 00       | local_get local_index:0
  0xdea | 10 23       | call function_index:35
  0xdec | 22 03       | local_tee local_index:3
  0xdee | d1          | ref_is_null
  0xdef | 04 40       | if blockty:Empty
  0xdf1 | 20 00       | local_get local_index:0
  0xdf3 | 20 04       | local_get local_index:4
  0xdf5 | d4          | ref_as_non_null
  0xdf6 | 10 22       | call function_index:34
  0xdf8 | 41 00       | i32_const value:0
  0xdfa | 0f          | return
  0xdfb | 0b          | end
  0xdfc | 20 03       | local_get local_index:3
  0xdfe | 10 2b       | call function_index:43
  0xe00 | 21 05       | local_set local_index:5
  0xe02 | 20 04       | local_get local_index:4
  0xe04 | 10 2b       | call function_index:43
  0xe06 | 21 06       | local_set local_index:6
  0xe08 | 20 05       | local_get local_index:5
  0xe0a | 20 06       | local_get local_index:6
  0xe0c | 6c          | i32_mul
  0xe0d | 21 07       | local_set local_index:7
  0xe0f | 20 00       | local_get local_index:0
  0xe11 | 20 07       | local_get local_index:7
  0xe13 | 10 2a       | call function_index:42
  0xe15 | d4          | ref_as_non_null
  0xe16 | 10 22       | call function_index:34
  0xe18 | 41 00       | i32_const value:0
  0xe1a | 0f          | return
  0xe1b | 0b          | end
  0xe1c | 20 01       | local_get local_index:1
  0xe1e | 41 b0 01    | i32_const value:176
  0xe21 | 46          | i32_eq
  0xe22 | 04 40       | if blockty:Empty
  0xe24 | 20 00       | local_get local_index:0
  0xe26 | 10 23       | call function_index:35
  0xe28 | 22 04       | local_tee local_index:4
  0xe2a | d1          | ref_is_null
  0xe2b | 04 40       | if blockty:Empty
  0xe2d | 41 00       | i32_const value:0
  0xe2f | 0f          | return
  0xe30 | 0b          | end
  0xe31 | 20 00       | local_get local_index:0
  0xe33 | 10 23       | call function_index:35
  0xe35 | 22 03       | local_tee local_index:3
  0xe37 | d1          | ref_is_null
  0xe38 | 04 40       | if blockty:Empty
  0xe3a | 20 00       | local_get local_index:0
  0xe3c | 20 04       | local_get local_index:4
  0xe3e | d4          | ref_as_non_null
  0xe3f | 10 22       | call function_index:34
  0xe41 | 41 00       | i32_const value:0
  0xe43 | 0f          | return
  0xe44 | 0b          | end
  0xe45 | 20 03       | local_get local_index:3
  0xe47 | 10 2b       | call function_index:43
  0xe49 | 21 05       | local_set local_index:5
  0xe4b | 20 04       | local_get local_index:4
  0xe4d | 10 2b       | call function_index:43
  0xe4f | 21 06       | local_set local_index:6
  0xe51 | 20 05       | local_get local_index:5
  0xe53 | 20 06       | local_get local_index:6
  0xe55 | 6a          | i32_add
  0xe56 | 21 07       | local_set local_index:7
  0xe58 | 20 00       | local_get local_index:0
  0xe5a | 20 07       | local_get local_index:7
  0xe5c | 10 2a       | call function_index:42
  0xe5e | d4          | ref_as_non_null
  0xe5f | 10 22       | call function_index:34
  0xe61 | 41 00       | i32_const value:0
  0xe63 | 0f          | return
  0xe64 | 0b          | end
  0xe65 | 20 01       | local_get local_index:1
  0xe67 | 41 fc 00    | i32_const value:124
  0xe6a | 46          | i32_eq
  0xe6b | 04 40       | if blockty:Empty
  0xe6d | 41 01       | i32_const value:1
  0xe6f | 0f          | return
  0xe70 | 0b          | end
  0xe71 | 20 01       | local_get local_index:1
  0xe73 | 41 d0 01    | i32_const value:208
  0xe76 | 46          | i32_eq
  0xe77 | 04 40       | if blockty:Empty
  0xe79 | 20 00       | local_get local_index:0
  0xe7b | 10 23       | call function_index:35
  0xe7d | 22 02       | local_tee local_index:2
  0xe7f | d1          | ref_is_null
  0xe80 | 04 40       | if blockty:Empty
  0xe82 | 41 00       | i32_const value:0
  0xe84 | 0f          | return
  0xe85 | 0b          | end
  0xe86 | 20 01       | local_get local_index:1
  0xe88 | 41 0f       | i32_const value:15
  0xe8a | 71          | i32_and
  0xe8b | 21 0c       | local_set local_index:12
  0xe8d | 20 00       | local_get local_index:0
  0xe8f | fb 02 08 09 | struct_get struct_type_index:8 field_index:9
  0xe93 | d4          | ref_as_non_null
  0xe94 | fb 02 07 05 | struct_get struct_type_index:7 field_index:5
  0xe98 | d4          | ref_as_non_null
  0xe99 | 22 0d       | local_tee local_index:13
  0xe9b | 20 0c       | local_get local_index:12
  0xe9d | 20 0d       | local_get local_index:13
  0xe9f | fb 0f       | array_len
  0xea1 | 4f          | i32_ge_u
  0xea2 | 04 40       | if blockty:Empty
  0xea4 | 20 00       | local_get local_index:0
  0xea6 | 20 02       | local_get local_index:2
  0xea8 | d4          | ref_as_non_null
  0xea9 | 10 22       | call function_index:34
  0xeab | 41 00       | i32_const value:0
  0xead | 0f          | return
  0xeae | 0b          | end
  0xeaf | 20 0d       | local_get local_index:13
  0xeb1 | 20 0c       | local_get local_index:12
  0xeb3 | fb 0b 00    | array_get array_type_index:0
  0xeb6 | 21 09       | local_set local_index:9
  0xeb8 | 20 02       | local_get local_index:2
  0xeba | 10 25       | call function_index:37
  0xebc | 21 0b       | local_set local_index:11
  0xebe | 20 09       | local_get local_index:9
  0xec0 | 20 0b       | local_get local_index:11
  0xec2 | 10 27       | call function_index:39
  0xec4 | 22 0a       | local_tee local_index:10
  0xec6 | d1          | ref_is_null
  0xec7 | 04 40       | if blockty:Empty
  0xec9 | 20 02       | local_get local_index:2
  0xecb | 20 09       | local_get local_index:9
  0xecd | 10 26       | call function_index:38
  0xecf | 22 0a       | local_tee local_index:10
  0xed1 | d1          | ref_is_null
  0xed2 | 04 40       | if blockty:Empty
  0xed4 | 20 00       | local_get local_index:0
  0xed6 | 20 02       | local_get local_index:2
  0xed8 | d4          | ref_as_non_null
  0xed9 | 10 22       | call function_index:34
  0xedb | 41 00       | i32_const value:0
  0xedd | 0f          | return
  0xede | 0b          | end
  0xedf | 20 09       | local_get local_index:9
  0xee1 | 20 0b       | local_get local_index:11
  0xee3 | 20 0a       | local_get local_index:10
  0xee5 | d4          | ref_as_non_null
  0xee6 | 10 28       | call function_index:40
  0xee8 | 0b          | end
  0xee9 | 20 02       | local_get local_index:2
  0xeeb | 20 0a       | local_get local_index:10
  0xeed | d4          | ref_as_non_null
  0xeee | 20 09       | local_get local_index:9
  0xef0 | 10 29       | call function_index:41
  0xef2 | 21 08       | local_set local_index:8
  0xef4 | 20 08       | local_get local_index:8
  0xef6 | 24 0b       | global_set global_index:11
  0xef8 | 41 00       | i32_const value:0
  0xefa | 0f          | return
  0xefb | 0b          | end
  0xefc | 41 00       | i32_const value:0
  0xefe | 0b          | end
============== func 51 ====================
  0xeff | ef 02       | size of function
  0xf01 | 08          | 8 local blocks
  0xf02 | 01 63 08    | 1 locals of type Ref((ref null (module 8)))
  0xf05 | 01 63 07    | 1 locals of type Ref((ref null (module 7)))
  0xf08 | 02 7f       | 2 locals of type I32
  0xf0a | 04 64 00    | 4 locals of type Ref((ref (module 0)))
  0xf0d | 02 6d       | 2 locals of type Ref(eqref)
  0xf0f | 01 7f       | 1 locals of type I32
  0xf11 | 01 63 01    | 1 locals of type Ref((ref null (module 1)))
  0xf14 | 01 7f       | 1 locals of type I32
  0xf16 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xf18 | 41 14       | i32_const value:20
  0xf1a | fb 06 00    | array_new array_type_index:0
  0xf1d | 21 04       | local_set local_index:4
  0xf1f | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xf21 | 41 00       | i32_const value:0
  0xf23 | fb 06 00    | array_new array_type_index:0
  0xf26 | 21 05       | local_set local_index:5
  0xf28 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xf2a | 41 00       | i32_const value:0
  0xf2c | fb 06 00    | array_new array_type_index:0
  0xf2f | 21 06       | local_set local_index:6
  0xf31 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0xf33 | 41 00       | i32_const value:0
  0xf35 | fb 06 00    | array_new array_type_index:0
  0xf38 | 21 07       | local_set local_index:7
  0xf3a | 41 e4 00    | i32_const value:100
  0xf3d | fb 1c       | ref_i31
  0xf3f | 21 08       | local_set local_index:8
  0xf41 | 23 00       | global_get global_index:0
  0xf43 | 41 d1 0f    | i32_const value:2001
  0xf46 | 41 0e       | i32_const value:14
  0xf48 | 41 0e       | i32_const value:14
  0xf4a | d0 02       | ref_null hty:Concrete(Module(2))
  0xf4c | 20 05       | local_get local_index:5
  0xf4e | d0 08       | ref_null hty:Concrete(Module(8))
  0xf50 | 41 00       | i32_const value:0
  0xf52 | 41 00       | i32_const value:0
  0xf54 | 23 06       | global_get global_index:6
  0xf56 | 20 08       | local_get local_index:8
  0xf58 | 20 06       | local_get local_index:6
  0xf5a | 20 07       | local_get local_index:7
  0xf5c | 20 04       | local_get local_index:4
  0xf5e | fb 00 08    | struct_new struct_type_index:8
  0xf61 | 24 0b       | global_set global_index:11
  0xf63 | 02 40       | block blockty:Empty
  0xf65 | 03 40       | loop blockty:Empty
  0xf67 | 23 0b       | global_get global_index:11
  0xf69 | 22 00       | local_tee local_index:0
  0xf6b | d1          | ref_is_null
  0xf6c | 04 40       | if blockty:Empty
  0xf6e | 0c 02       | br relative_depth:2
  0xf70 | 0b          | end
  0xf71 | 20 00       | local_get local_index:0
  0xf73 | d4          | ref_as_non_null
  0xf74 | fb 02 08 09 | struct_get struct_type_index:8 field_index:9
  0xf78 | 22 01       | local_tee local_index:1
  0xf7a | d1          | ref_is_null
  0xf7b | 04 40       | if blockty:Empty
  0xf7d | 0c 01       | br relative_depth:1
  0xf7f | 0b          | end
  0xf80 | 20 01       | local_get local_index:1
  0xf82 | d4          | ref_as_non_null
  0xf83 | 21 01       | local_set local_index:1
  0xf85 | 20 01       | local_get local_index:1
  0xf87 | fb 02 07 08 | struct_get struct_type_index:7 field_index:8
  0xf8b | 41 01       | i32_const value:1
  0xf8d | 6a          | i32_add
  0xf8e | 21 0a       | local_set local_index:10
  0xf90 | 20 01       | local_get local_index:1
  0xf92 | 20 0a       | local_get local_index:10
  0xf94 | fb 05 07 08 | struct_set struct_type_index:7 field_index:8
  0xf98 | 20 0a       | local_get local_index:10
  0xf9a | 23 10       | global_get global_index:16
  0xf9c | 46          | i32_eq
  0xf9d | 23 11       | global_get global_index:17
  0xf9f | 71          | i32_and
  0xfa0 | 04 40       | if blockty:Empty
  0xfa2 | 20 01       | local_get local_index:1
  0xfa4 | fb 02 07 0b | struct_get struct_type_index:7 field_index:11
  0xfa8 | 41 01       | i32_const value:1
  0xfaa | 46          | i32_eq
  0xfab | 04 40       | if blockty:Empty
  0xfad | 20 01       | local_get local_index:1
  0xfaf | d4          | ref_as_non_null
  0xfb0 | 10 2c       | call function_index:44
  0xfb2 | 45          | i32_eqz
  0xfb3 | 04 40       | if blockty:Empty
  0xfb5 | 20 01       | local_get local_index:1
  0xfb7 | d4          | ref_as_non_null
  0xfb8 | 10 2e       | call function_index:46
  0xfba | 0b          | end
  0xfbb | 0b          | end
  0xfbc | 0b          | end
  0xfbd | 20 01       | local_get local_index:1
  0xfbf | d4          | ref_as_non_null
  0xfc0 | 10 2c       | call function_index:44
  0xfc2 | 04 40       | if blockty:Empty
  0xfc4 | 20 01       | local_get local_index:1
  0xfc6 | fb 02 07 09 | struct_get struct_type_index:7 field_index:9
  0xfca | 21 0c       | local_set local_index:12
  0xfcc | 20 00       | local_get local_index:0
  0xfce | d4          | ref_as_non_null
  0xfcf | 20 0c       | local_get local_index:12
  0xfd1 | 10 2d       | call function_index:45
  0xfd3 | 1a          | drop
  0xfd4 | 20 00       | local_get local_index:0
  0xfd6 | d4          | ref_as_non_null
  0xfd7 | 10 2f       | call function_index:47
  0xfd9 | 21 09       | local_set local_index:9
  0xfdb | 0c 01       | br relative_depth:1
  0xfdd | 05          | else
  0xfde | 20 01       | local_get local_index:1
  0xfe0 | fb 02 07 07 | struct_get struct_type_index:7 field_index:7
  0xfe4 | 22 0b       | local_tee local_index:11
  0xfe6 | d1          | ref_is_null
  0xfe7 | 04 40       | if blockty:Empty
  0xfe9 | 0c 02       | br relative_depth:2
  0xfeb | 0b          | end
  0xfec | 03 40       | loop blockty:Empty
  0xfee | 23 0b       | global_get global_index:11
  0xff0 | 22 00       | local_tee local_index:0
  0xff2 | d1          | ref_is_null
  0xff3 | 45          | i32_eqz
  0xff4 | 04 40       | if blockty:Empty
  0xff6 | 20 00       | local_get local_index:0
  0xff8 | d4          | ref_as_non_null
  0xff9 | fb 02 08 07 | struct_get struct_type_index:8 field_index:7
  0xffd | 21 03       | local_set local_index:3
  0xfff | 20 00       | local_get local_index:0
 0x1001 | d4          | ref_as_non_null
 0x1002 | fb 02 08 09 | struct_get struct_type_index:8 field_index:9
 0x1006 | 22 01       | local_tee local_index:1
 0x1008 | fb 02 07 07 | struct_get struct_type_index:7 field_index:7
 0x100c | 22 0b       | local_tee local_index:11
 0x100e | d4          | ref_as_non_null
 0x100f | fb 0f       | array_len
 0x1011 | 20 03       | local_get local_index:3
 0x1013 | 4d          | i32_le_u
 0x1014 | 04 40       | if blockty:Empty
 0x1016 | 20 00       | local_get local_index:0
 0x1018 | d4          | ref_as_non_null
 0x1019 | 10 2f       | call function_index:47
 0x101b | 21 09       | local_set local_index:9
 0x101d | 0c 02       | br relative_depth:2
 0x101f | 0b          | end
 0x1020 | 20 0b       | local_get local_index:11
 0x1022 | d4          | ref_as_non_null
 0x1023 | 20 03       | local_get local_index:3
 0x1025 | fb 0d 01    | array_get_u array_type_index:1
 0x1028 | 21 02       | local_set local_index:2
 0x102a | 20 00       | local_get local_index:0
 0x102c | d4          | ref_as_non_null
 0x102d | 20 02       | local_get local_index:2
 0x102f | 10 32       | call function_index:50
 0x1031 | 04 40       | if blockty:Empty
 0x1033 | 20 00       | local_get local_index:0
 0x1035 | d4          | ref_as_non_null
 0x1036 | 10 2f       | call function_index:47
 0x1038 | 21 09       | local_set local_index:9
 0x103a | 0c 02       | br relative_depth:2
 0x103c | 0b          | end
 0x103d | 23 0b       | global_get global_index:11
 0x103f | 20 00       | local_get local_index:0
 0x1041 | d3          | ref_eq
 0x1042 | 04 40       | if blockty:Empty
 0x1044 | 20 00       | local_get local_index:0
 0x1046 | d4          | ref_as_non_null
 0x1047 | 20 03       | local_get local_index:3
 0x1049 | 41 01       | i32_const value:1
 0x104b | 6a          | i32_add
 0x104c | fb 05 08 07 | struct_set struct_type_index:8 field_index:7
 0x1050 | 05          | else
 0x1051 | 23 0b       | global_get global_index:11
 0x1053 | d4          | ref_as_non_null
 0x1054 | fb 02 08 07 | struct_get struct_type_index:8 field_index:7
 0x1058 | 45          | i32_eqz
 0x1059 | 04 40       | if blockty:Empty
 0x105b | 0c 05       | br relative_depth:5
 0x105d | 0b          | end
 0x105e | 0b          | end
 0x105f | 0c 01       | br relative_depth:1
 0x1061 | 0b          | end
 0x1062 | 0b          | end
 0x1063 | 0b          | end
 0x1064 | 20 09       | local_get local_index:9
 0x1066 | 10 2b       | call function_index:43
 0x1068 | 10 00       | call function_index:0
 0x106a | 0b          | end
 0x106b | 0b          | end
 0x106c | 41 01       | i32_const value:1
 0x106e | 0f          | return
 0x106f | 0b          | end
 0x1070 | 00 93 13    | custom section
 0x1073 | 04 6e 61 6d | name: "name"
        | 65         
 0x1078 | 01 f0 03    | function name section
 0x107b | 1d          | 29 count
 0x107c | 00 0c 72 65 | Naming { index: 0, name: "reportResult" }
        | 70 6f 72 74
        | 52 65 73 75
        | 6c 74      
 0x108a | 01 0d 63 6f | Naming { index: 1, name: "compileMethod" }
        | 6d 70 69 6c
        | 65 4d 65 74
        | 68 6f 64   
 0x1099 | 02 08 64 65 | Naming { index: 2, name: "debugLog" }
        | 62 75 67 4c
        | 6f 67      
 0x10a3 | 14 10 63 6f | Naming { index: 20, name: "contextLiteralAt" }
        | 6e 74 65 78
        | 74 4c 69 74
        | 65 72 61 6c
        | 41 74      
 0x10b5 | 1b 0e 61 72 | Naming { index: 27, name: "array_len_byte" }
        | 72 61 79 5f
        | 6c 65 6e 5f
        | 62 79 74 65
 0x10c5 | 1c 0e 61 72 | Naming { index: 28, name: "array_get_byte" }
        | 72 61 79 5f
        | 67 65 74 5f
        | 62 79 74 65
 0x10d5 | 1d 10 61 72 | Naming { index: 29, name: "array_len_object" }
        | 72 61 79 5f
        | 6c 65 6e 5f
        | 6f 62 6a 65
        | 63 74      
 0x10e7 | 1e 10 61 72 | Naming { index: 30, name: "array_get_object" }
        | 72 61 79 5f
        | 67 65 74 5f
        | 6f 62 6a 65
        | 63 74      
 0x10f9 | 1f 10 69 73 | Naming { index: 31, name: "is_small_integer" }
        | 5f 73 6d 61
        | 6c 6c 5f 69
        | 6e 74 65 67
        | 65 72      
 0x110b | 20 17 67 65 | Naming { index: 32, name: "get_small_integer_value" }
        | 74 5f 73 6d
        | 61 6c 6c 5f
        | 69 6e 74 65
        | 67 65 72 5f
        | 76 61 6c 75
        | 65         
 0x1124 | 21 10 6e 65 | Naming { index: 33, name: "nextIdentityHash" }
        | 78 74 49 64
        | 65 6e 74 69
        | 74 79 48 61
        | 73 68      
 0x1136 | 22 0b 70 75 | Naming { index: 34, name: "pushOnStack" }
        | 73 68 4f 6e
        | 53 74 61 63
        | 6b         
 0x1143 | 23 0c 70 6f | Naming { index: 35, name: "popFromStack" }
        | 70 46 72 6f
        | 6d 53 74 61
        | 63 6b      
 0x1151 | 24 0a 74 6f | Naming { index: 36, name: "topOfStack" }
        | 70 4f 66 53
        | 74 61 63 6b
 0x115d | 25 08 67 65 | Naming { index: 37, name: "getClass" }
        | 74 43 6c 61
        | 73 73      
 0x1167 | 26 0c 6c 6f | Naming { index: 38, name: "lookupMethod" }
        | 6f 6b 75 70
        | 4d 65 74 68
        | 6f 64      
 0x1175 | 27 0d 6c 6f | Naming { index: 39, name: "lookupInCache" }
        | 6f 6b 75 70
        | 49 6e 43 61
        | 63 68 65   
 0x1184 | 28 0c 73 74 | Naming { index: 40, name: "storeInCache" }
        | 6f 72 65 49
        | 6e 43 61 63
        | 68 65      
 0x1192 | 29 13 63 72 | Naming { index: 41, name: "createMethodContext" }
        | 65 61 74 65
        | 4d 65 74 68
        | 6f 64 43 6f
        | 6e 74 65 78
        | 74         
 0x11a7 | 2a 12 63 72 | Naming { index: 42, name: "createSmallInteger" }
        | 65 61 74 65
        | 53 6d 61 6c
        | 6c 49 6e 74
        | 65 67 65 72
 0x11bb | 2b 13 65 78 | Naming { index: 43, name: "extractIntegerValue" }
        | 74 72 61 63
        | 74 49 6e 74
        | 65 67 65 72
        | 56 61 6c 75
        | 65         
 0x11d0 | 2c 13 68 61 | Naming { index: 44, name: "hasCompiledFunction" }
        | 73 43 6f 6d
        | 70 69 6c 65
        | 64 46 75 6e
        | 63 74 69 6f
        | 6e         
 0x11e5 | 2d 17 65 78 | Naming { index: 45, name: "executeCompiledFunction" }
        | 65 63 75 74
        | 65 43 6f 6d
        | 70 69 6c 65
        | 64 46 75 6e
        | 63 74 69 6f
        | 6e         
 0x11fe | 2e 15 74 72 | Naming { index: 46, name: "triggerJITCompilation" }
        | 69 67 67 65
        | 72 4a 49 54
        | 43 6f 6d 70
        | 69 6c 61 74
        | 69 6f 6e   
 0x1215 | 2f 12 68 61 | Naming { index: 47, name: "handleMethodReturn" }
        | 6e 64 6c 65
        | 4d 65 74 68
        | 6f 64 52 65
        | 74 75 72 6e
 0x1229 | 30 0a 69 6e | Naming { index: 48, name: "initialize" }
        | 69 74 69 61
        | 6c 69 7a 65
 0x1235 | 31 16 63 72 | Naming { index: 49, name: "createMinimalBootstrap" }
        | 65 61 74 65
        | 4d 69 6e 69
        | 6d 61 6c 42
        | 6f 6f 74 73
        | 74 72 61 70
 0x124d | 32 11 69 6e | Naming { index: 50, name: "interpretBytecode" }
        | 74 65 72 70
        | 72 65 74 42
        | 79 74 65 63
        | 6f 64 65   
 0x1260 | 33 09 69 6e | Naming { index: 51, name: "interpret" }
        | 74 65 72 70
        | 72 65 74   
 0x126b | 02 d0 0a    | local section
 0x126e | 2b          | 43 count
 0x126f | 04          | function 4 local name section
 0x1270 | 03          | 3 count
 0x1271 | 01 0a 74 61 | Naming { index: 1, name: "targetHash" }
        | 72 67 65 74
        | 48 61 73 68
 0x127d | 02 0d 63 75 | Naming { index: 2, name: "currentObject" }
        | 72 72 65 6e
        | 74 4f 62 6a
        | 65 63 74   
 0x128c | 03 0b 63 75 | Naming { index: 3, name: "currentHash" }
        | 72 72 65 6e
        | 74 48 61 73
        | 68         
 0x1299 | 06          | function 6 local name section
 0x129a | 02          | 2 count
 0x129b | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x12a4 | 01 05 76 61 | Naming { index: 1, name: "value" }
        | 6c 75 65   
 0x12ab | 07          | function 7 local name section
 0x12ac | 01          | 1 count
 0x12ad | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x12b6 | 08          | function 8 local name section
 0x12b7 | 01          | 1 count
 0x12b8 | 00 03 6f 62 | Naming { index: 0, name: "obj" }
        | 6a         
 0x12bd | 09          | function 9 local name section
 0x12be | 01          | 1 count
 0x12bf | 00 05 76 61 | Naming { index: 0, name: "value" }
        | 6c 75 65   
 0x12c6 | 0a          | function 10 local name section
 0x12c7 | 01          | 1 count
 0x12c8 | 00 03 6f 62 | Naming { index: 0, name: "obj" }
        | 6a         
 0x12cd | 0b          | function 11 local name section
 0x12ce | 02          | 2 count
 0x12cf | 00 08 73 65 | Naming { index: 0, name: "selector" }
        | 6c 65 63 74
        | 6f 72      
 0x12d9 | 01 0d 72 65 | Naming { index: 1, name: "receiverClass" }
        | 63 65 69 76
        | 65 72 43 6c
        | 61 73 73   
 0x12e8 | 0c          | function 12 local name section
 0x12e9 | 02          | 2 count
 0x12ea | 00 08 72 65 | Naming { index: 0, name: "receiver" }
        | 63 65 69 76
        | 65 72      
 0x12f4 | 01 08 73 65 | Naming { index: 1, name: "selector" }
        | 6c 65 63 74
        | 6f 72      
 0x12fe | 0d          | function 13 local name section
 0x12ff | 03          | 3 count
 0x1300 | 00 08 73 65 | Naming { index: 0, name: "selector" }
        | 6c 65 63 74
        | 6f 72      
 0x130a | 01 0d 72 65 | Naming { index: 1, name: "receiverClass" }
        | 63 65 69 76
        | 65 72 43 6c
        | 61 73 73   
 0x1319 | 02 06 6d 65 | Naming { index: 2, name: "method" }
        | 74 68 6f 64
 0x1321 | 0e          | function 14 local name section
 0x1322 | 03          | 3 count
 0x1323 | 00 08 72 65 | Naming { index: 0, name: "receiver" }
        | 63 65 69 76
        | 65 72      
 0x132d | 01 06 6d 65 | Naming { index: 1, name: "method" }
        | 74 68 6f 64
 0x1335 | 02 08 73 65 | Naming { index: 2, name: "selector" }
        | 6c 65 63 74
        | 6f 72      
 0x133f | 0f          | function 15 local name section
 0x1340 | 02          | 2 count
 0x1341 | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x134a | 01 08 62 79 | Naming { index: 1, name: "bytecode" }
        | 74 65 63 6f
        | 64 65      
 0x1354 | 10          | function 16 local name section
 0x1355 | 01          | 1 count
 0x1356 | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x135f | 12          | function 18 local name section
 0x1360 | 01          | 1 count
 0x1361 | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x136a | 13          | function 19 local name section
 0x136b | 01          | 1 count
 0x136c | 00 06 6d 65 | Naming { index: 0, name: "method" }
        | 74 68 6f 64
 0x1374 | 14          | function 20 local name section
 0x1375 | 02          | 2 count
 0x1376 | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x137f | 01 05 69 6e | Naming { index: 1, name: "index" }
        | 64 65 78   
 0x1386 | 15          | function 21 local name section
 0x1387 | 02          | 2 count
 0x1388 | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x1391 | 01 05 69 6e | Naming { index: 1, name: "index" }
        | 64 65 78   
 0x1398 | 16          | function 22 local name section
 0x1399 | 01          | 1 count
 0x139a | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x13a3 | 17          | function 23 local name section
 0x13a4 | 02          | 2 count
 0x13a5 | 00 05 61 72 | Naming { index: 0, name: "array" }
        | 72 61 79   
 0x13ac | 01 05 69 6e | Naming { index: 1, name: "index" }
        | 64 65 78   
 0x13b3 | 18          | function 24 local name section
 0x13b4 | 01          | 1 count
 0x13b5 | 00 05 61 72 | Naming { index: 0, name: "array" }
        | 72 61 79   
 0x13bc | 19          | function 25 local name section
 0x13bd | 02          | 2 count
 0x13be | 01 03 6c 65 | Naming { index: 1, name: "len" }
        | 6e         
 0x13c3 | 02 01 69    | Naming { index: 2, name: "i" }
 0x13c6 | 1b          | function 27 local name section
 0x13c7 | 01          | 1 count
 0x13c8 | 00 05 61 72 | Naming { index: 0, name: "array" }
        | 72 61 79   
 0x13cf | 1c          | function 28 local name section
 0x13d0 | 03          | 3 count
 0x13d1 | 00 05 61 72 | Naming { index: 0, name: "array" }
        | 72 61 79   
 0x13d8 | 01 05 69 6e | Naming { index: 1, name: "index" }
        | 64 65 78   
 0x13df | 02 06 6c 65 | Naming { index: 2, name: "length" }
        | 6e 67 74 68
 0x13e7 | 1d          | function 29 local name section
 0x13e8 | 01          | 1 count
 0x13e9 | 00 05 61 72 | Naming { index: 0, name: "array" }
        | 72 61 79   
 0x13f0 | 1e          | function 30 local name section
 0x13f1 | 03          | 3 count
 0x13f2 | 00 05 61 72 | Naming { index: 0, name: "array" }
        | 72 61 79   
 0x13f9 | 01 05 69 6e | Naming { index: 1, name: "index" }
        | 64 65 78   
 0x1400 | 02 06 6c 65 | Naming { index: 2, name: "length" }
        | 6e 67 74 68
 0x1408 | 1f          | function 31 local name section
 0x1409 | 01          | 1 count
 0x140a | 00 03 6f 62 | Naming { index: 0, name: "obj" }
        | 6a         
 0x140f | 20          | function 32 local name section
 0x1410 | 01          | 1 count
 0x1411 | 00 03 6f 62 | Naming { index: 0, name: "obj" }
        | 6a         
 0x1416 | 22          | function 34 local name section
 0x1417 | 04          | 4 count
 0x1418 | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x1421 | 01 05 76 61 | Naming { index: 1, name: "value" }
        | 6c 75 65   
 0x1428 | 02 05 73 74 | Naming { index: 2, name: "stack" }
        | 61 63 6b   
 0x142f | 03 02 73 70 | Naming { index: 3, name: "sp" }
 0x1433 | 23          | function 35 local name section
 0x1434 | 03          | 3 count
 0x1435 | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x143e | 01 05 73 74 | Naming { index: 1, name: "stack" }
        | 61 63 6b   
 0x1445 | 02 02 73 70 | Naming { index: 2, name: "sp" }
 0x1449 | 24          | function 36 local name section
 0x144a | 03          | 3 count
 0x144b | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x1454 | 01 05 73 74 | Naming { index: 1, name: "stack" }
        | 61 63 6b   
 0x145b | 02 02 73 70 | Naming { index: 2, name: "sp" }
 0x145f | 25          | function 37 local name section
 0x1460 | 01          | 1 count
 0x1461 | 00 03 6f 62 | Naming { index: 0, name: "obj" }
        | 6a         
 0x1466 | 26          | function 38 local name section
 0x1467 | 0a          | 10 count
 0x1468 | 00 08 72 65 | Naming { index: 0, name: "receiver" }
        | 63 65 69 76
        | 65 72      
 0x1472 | 01 08 73 65 | Naming { index: 1, name: "selector" }
        | 6c 65 63 74
        | 6f 72      
 0x147c | 02 05 63 6c | Naming { index: 2, name: "class" }
        | 61 73 73   
 0x1483 | 03 0c 63 75 | Naming { index: 3, name: "currentClass" }
        | 72 72 65 6e
        | 74 43 6c 61
        | 73 73      
 0x1491 | 04 0a 6d 65 | Naming { index: 4, name: "methodDict" }
        | 74 68 6f 64
        | 44 69 63 74
 0x149d | 05 04 6b 65 | Naming { index: 5, name: "keys" }
        | 79 73      
 0x14a3 | 06 06 76 61 | Naming { index: 6, name: "values" }
        | 6c 75 65 73
 0x14ab | 07 05 63 6f | Naming { index: 7, name: "count" }
        | 75 6e 74   
 0x14b2 | 08 01 69    | Naming { index: 8, name: "i" }
 0x14b5 | 09 03 6b 65 | Naming { index: 9, name: "key" }
        | 79         
 0x14ba | 27          | function 39 local name section
 0x14bb | 08          | 8 count
 0x14bc | 00 08 73 65 | Naming { index: 0, name: "selector" }
        | 6c 65 63 74
        | 6f 72      
 0x14c6 | 01 0d 72 65 | Naming { index: 1, name: "receiverClass" }
        | 63 65 69 76
        | 65 72 43 6c
        | 61 73 73   
 0x14d5 | 02 05 63 61 | Naming { index: 2, name: "cache" }
        | 63 68 65   
 0x14dc | 03 09 63 61 | Naming { index: 3, name: "cacheSize" }
        | 63 68 65 53
        | 69 7a 65   
 0x14e7 | 04 04 68 61 | Naming { index: 4, name: "hash" }
        | 73 68      
 0x14ed | 05 05 69 6e | Naming { index: 5, name: "index" }
        | 64 65 78   
 0x14f4 | 06 05 65 6e | Naming { index: 6, name: "entry" }
        | 74 72 79   
 0x14fb | 07 0a 70 72 | Naming { index: 7, name: "probeLimit" }
        | 6f 62 65 4c
        | 69 6d 69 74
 0x1507 | 28          | function 40 local name section
 0x1508 | 06          | 6 count
 0x1509 | 00 08 73 65 | Naming { index: 0, name: "selector" }
        | 6c 65 63 74
        | 6f 72      
 0x1513 | 01 0d 72 65 | Naming { index: 1, name: "receiverClass" }
        | 63 65 69 76
        | 65 72 43 6c
        | 61 73 73   
 0x1522 | 02 06 6d 65 | Naming { index: 2, name: "method" }
        | 74 68 6f 64
 0x152a | 03 05 63 61 | Naming { index: 3, name: "cache" }
        | 63 68 65   
 0x1531 | 04 05 69 6e | Naming { index: 4, name: "index" }
        | 64 65 78   
 0x1538 | 05 05 65 6e | Naming { index: 5, name: "entry" }
        | 74 72 79   
 0x153f | 29          | function 41 local name section
 0x1540 | 07          | 7 count
 0x1541 | 00 08 72 65 | Naming { index: 0, name: "receiver" }
        | 63 65 69 76
        | 65 72      
 0x154b | 01 06 6d 65 | Naming { index: 1, name: "method" }
        | 74 68 6f 64
 0x1553 | 02 08 73 65 | Naming { index: 2, name: "selector" }
        | 6c 65 63 74
        | 6f 72      
 0x155d | 03 05 73 74 | Naming { index: 3, name: "stack" }
        | 61 63 6b   
 0x1564 | 04 05 73 6c | Naming { index: 4, name: "slots" }
        | 6f 74 73   
 0x156b | 05 04 61 72 | Naming { index: 5, name: "args" }
        | 67 73      
 0x1571 | 06 05 74 65 | Naming { index: 6, name: "temps" }
        | 6d 70 73   
 0x1578 | 2a          | function 42 local name section
 0x1579 | 01          | 1 count
 0x157a | 00 05 76 61 | Naming { index: 0, name: "value" }
        | 6c 75 65   
 0x1581 | 2b          | function 43 local name section
 0x1582 | 01          | 1 count
 0x1583 | 00 03 6f 62 | Naming { index: 0, name: "obj" }
        | 6a         
 0x1588 | 2c          | function 44 local name section
 0x1589 | 01          | 1 count
 0x158a | 00 06 6d 65 | Naming { index: 0, name: "method" }
        | 74 68 6f 64
 0x1592 | 2d          | function 45 local name section
 0x1593 | 02          | 2 count
 0x1594 | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x159d | 01 09 66 75 | Naming { index: 1, name: "funcIndex" }
        | 6e 63 49 6e
        | 64 65 78   
 0x15a8 | 2e          | function 46 local name section
 0x15a9 | 05          | 5 count
 0x15aa | 00 06 6d 65 | Naming { index: 0, name: "method" }
        | 74 68 6f 64
 0x15b2 | 01 09 62 79 | Naming { index: 1, name: "bytecodes" }
        | 74 65 63 6f
        | 64 65 73   
 0x15bd | 02 0b 62 79 | Naming { index: 2, name: "bytecodeLen" }
        | 74 65 63 6f
        | 64 65 4c 65
        | 6e         
 0x15ca | 03 11 63 6f | Naming { index: 3, name: "compiledFuncIndex" }
        | 6d 70 69 6c
        | 65 64 46 75
        | 6e 63 49 6e
        | 64 65 78   
 0x15dd | 04 0c 6d 65 | Naming { index: 4, name: "memoryOffset" }
        | 6d 6f 72 79
        | 4f 66 66 73
        | 65 74      
 0x15eb | 2f          | function 47 local name section
 0x15ec | 03          | 3 count
 0x15ed | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x15f6 | 01 06 73 65 | Naming { index: 1, name: "sender" }
        | 6e 64 65 72
 0x15fe | 02 06 72 65 | Naming { index: 2, name: "result" }
        | 73 75 6c 74
 0x1606 | 31          | function 49 local name section
 0x1607 | 0e          | 14 count
 0x1608 | 00 0e 77 6f | Naming { index: 0, name: "workloadMethod" }
        | 72 6b 6c 6f
        | 61 64 4d 65
        | 74 68 6f 64
 0x1618 | 01 0a 6d 61 | Naming { index: 1, name: "mainMethod" }
        | 69 6e 4d 65
        | 74 68 6f 64
 0x1624 | 02 0d 6d 61 | Naming { index: 2, name: "mainBytecodes" }
        | 69 6e 42 79
        | 74 65 63 6f
        | 64 65 73   
 0x1633 | 03 11 77 6f | Naming { index: 3, name: "workloadBytecodes" }
        | 72 6b 6c 6f
        | 61 64 42 79
        | 74 65 63 6f
        | 64 65 73   
 0x1646 | 04 10 77 6f | Naming { index: 4, name: "workloadSelector" }
        | 72 6b 6c 6f
        | 61 64 53 65
        | 6c 65 63 74
        | 6f 72      
 0x1658 | 05 0a 6d 65 | Naming { index: 5, name: "methodDict" }
        | 74 68 6f 64
        | 44 69 63 74
 0x1664 | 06 09 6e 65 | Naming { index: 6, name: "newObject" }
        | 77 4f 62 6a
        | 65 63 74   
 0x166f | 07 05 73 6c | Naming { index: 7, name: "slots" }
        | 6f 74 73   
 0x1676 | 08 04 6b 65 | Naming { index: 8, name: "keys" }
        | 79 73      
 0x167c | 09 06 76 61 | Naming { index: 9, name: "values" }
        | 6c 75 65 73
 0x1684 | 0a 09 65 6d | Naming { index: 10, name: "emptyDict" }
        | 70 74 79 44
        | 69 63 74   
 0x168f | 0b 0b 65 6d | Naming { index: 11, name: "emptySymbol" }
        | 70 74 79 53
        | 79 6d 62 6f
        | 6c         
 0x169c | 0c 11 65 6d | Naming { index: 12, name: "emptyInstVarNames" }
        | 70 74 79 49
        | 6e 73 74 56
        | 61 72 4e 61
        | 6d 65 73   
 0x16af | 0d 0d 77 6f | Naming { index: 13, name: "workloadSlots" }
        | 72 6b 6c 6f
        | 61 64 53 6c
        | 6f 74 73   
 0x16be | 32          | function 50 local name section
 0x16bf | 0e          | 14 count
 0x16c0 | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x16c9 | 01 08 62 79 | Naming { index: 1, name: "bytecode" }
        | 74 65 63 6f
        | 64 65      
 0x16d3 | 02 08 72 65 | Naming { index: 2, name: "receiver" }
        | 63 65 69 76
        | 65 72      
 0x16dd | 03 06 76 61 | Naming { index: 3, name: "value1" }
        | 6c 75 65 31
 0x16e5 | 04 06 76 61 | Naming { index: 4, name: "value2" }
        | 6c 75 65 32
 0x16ed | 05 04 69 6e | Naming { index: 5, name: "int1" }
        | 74 31      
 0x16f3 | 06 04 69 6e | Naming { index: 6, name: "int2" }
        | 74 32      
 0x16f9 | 07 06 72 65 | Naming { index: 7, name: "result" }
        | 73 75 6c 74
 0x1701 | 08 0a 6e 65 | Naming { index: 8, name: "newContext" }
        | 77 43 6f 6e
        | 74 65 78 74
 0x170d | 09 08 73 65 | Naming { index: 9, name: "selector" }
        | 6c 65 63 74
        | 6f 72      
 0x1717 | 0a 06 6d 65 | Naming { index: 10, name: "method" }
        | 74 68 6f 64
 0x171f | 0b 0d 72 65 | Naming { index: 11, name: "receiverClass" }
        | 63 65 69 76
        | 65 72 43 6c
        | 61 73 73   
 0x172e | 0c 0d 73 65 | Naming { index: 12, name: "selectorIndex" }
        | 6c 65 63 74
        | 6f 72 49 6e
        | 64 65 78   
 0x173d | 0d 05 73 6c | Naming { index: 13, name: "slots" }
        | 6f 74 73   
 0x1744 | 33          | function 51 local name section
 0x1745 | 0d          | 13 count
 0x1746 | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
 0x174f | 01 06 6d 65 | Naming { index: 1, name: "method" }
        | 74 68 6f 64
 0x1757 | 02 08 62 79 | Naming { index: 2, name: "bytecode" }
        | 74 65 63 6f
        | 64 65      
 0x1761 | 03 02 70 63 | Naming { index: 3, name: "pc" }
 0x1765 | 04 05 73 74 | Naming { index: 4, name: "stack" }
        | 61 63 6b   
 0x176c | 05 05 73 6c | Naming { index: 5, name: "slots" }
        | 6f 74 73   
 0x1773 | 06 04 61 72 | Naming { index: 6, name: "args" }
        | 67 73      
 0x1779 | 07 05 74 65 | Naming { index: 7, name: "temps" }
        | 6d 70 73   
 0x1780 | 08 08 72 65 | Naming { index: 8, name: "receiver" }
        | 63 65 69 76
        | 65 72      
 0x178a | 09 0b 72 65 | Naming { index: 9, name: "resultValue" }
        | 73 75 6c 74
        | 56 61 6c 75
        | 65         
 0x1797 | 0a 0f 69 6e | Naming { index: 10, name: "invocationCount" }
        | 76 6f 63 61
        | 74 69 6f 6e
        | 43 6f 75 6e
        | 74         
 0x17a8 | 0b 09 62 79 | Naming { index: 11, name: "bytecodes" }
        | 74 65 63 6f
        | 64 65 73   
 0x17b3 | 0c 09 66 75 | Naming { index: 12, name: "funcIndex" }
        | 6e 63 49 6e
        | 64 65 78   
 0x17be | 03 73       | label section
 0x17c0 | 05          | 5 count
 0x17c1 | 04          | function 4 label name section
 0x17c2 | 01          | 1 count
 0x17c3 | 00 0b 73 65 | Naming { index: 0, name: "search_loop" }
        | 61 72 63 68
        | 5f 6c 6f 6f
        | 70         
 0x17d0 | 19          | function 25 label name section
 0x17d1 | 01          | 1 count
 0x17d2 | 01 04 63 6f | Naming { index: 1, name: "copy" }
        | 70 79      
 0x17d8 | 26          | function 38 label name section
 0x17d9 | 02          | 2 count
 0x17da | 00 0e 68 69 | Naming { index: 0, name: "hierarchy_loop" }
        | 65 72 61 72
        | 63 68 79 5f
        | 6c 6f 6f 70
 0x17ea | 05 0b 73 65 | Naming { index: 5, name: "search_loop" }
        | 61 72 63 68
        | 5f 6c 6f 6f
        | 70         
 0x17f7 | 27          | function 39 label name section
 0x17f8 | 01          | 1 count
 0x17f9 | 01 0a 70 72 | Naming { index: 1, name: "probe_loop" }
        | 6f 62 65 5f
        | 6c 6f 6f 70
 0x1805 | 33          | function 51 label name section
 0x1806 | 03          | 3 count
 0x1807 | 00 08 66 69 | Naming { index: 0, name: "finished" }
        | 6e 69 73 68
        | 65 64      
 0x1811 | 01 0e 65 78 | Naming { index: 1, name: "execution_loop" }
        | 65 63 75 74
        | 69 6f 6e 5f
        | 6c 6f 6f 70
 0x1821 | 09 10 69 6e | Naming { index: 9, name: "interpreter_loop" }
        | 74 65 72 70
        | 72 65 74 65
        | 72 5f 6c 6f
        | 6f 70      
 0x1833 | 04 84 01    | type name section
 0x1836 | 0b          | 11 count
 0x1837 | 00 0b 4f 62 | Naming { index: 0, name: "ObjectArray" }
        | 6a 65 63 74
        | 41 72 72 61
        | 79         
 0x1844 | 01 09 42 79 | Naming { index: 1, name: "ByteArray" }
        | 74 65 41 72
        | 72 61 79   
 0x184f | 02 0c 53 71 | Naming { index: 2, name: "SqueakObject" }
        | 75 65 61 6b
        | 4f 62 6a 65
        | 63 74      
 0x185d | 03 0e 56 61 | Naming { index: 3, name: "VariableObject" }
        | 72 69 61 62
        | 6c 65 4f 62
        | 6a 65 63 74
 0x186d | 04 06 53 79 | Naming { index: 4, name: "Symbol" }
        | 6d 62 6f 6c
 0x1875 | 05 05 43 6c | Naming { index: 5, name: "Class" }
        | 61 73 73   
 0x187c | 06 0a 44 69 | Naming { index: 6, name: "Dictionary" }
        | 63 74 69 6f
        | 6e 61 72 79
 0x1888 | 07 0e 43 6f | Naming { index: 7, name: "CompiledMethod" }
        | 6d 70 69 6c
        | 65 64 4d 65
        | 74 68 6f 64
 0x1898 | 08 07 43 6f | Naming { index: 8, name: "Context" }
        | 6e 74 65 78
        | 74         
 0x18a1 | 09 08 50 49 | Naming { index: 9, name: "PICEntry" }
        | 43 45 6e 74
        | 72 79      
 0x18ab | 0a 0d 6a 69 | Naming { index: 10, name: "jit_func_type" }
        | 74 5f 66 75
        | 6e 63 5f 74
        | 79 70 65   
 0x18ba | 05 0c       | table name section
 0x18bc | 01          | 1 count
 0x18bd | 00 09 66 75 | Naming { index: 0, name: "funcTable" }
        | 6e 63 54 61
        | 62 6c 65   
 0x18c8 | 07 bb 02    | global name section
 0x18cb | 16          | 22 count
 0x18cc | 00 0b 6f 62 | Naming { index: 0, name: "objectClass" }
        | 6a 65 63 74
        | 43 6c 61 73
        | 73         
 0x18d9 | 01 0a 63 6c | Naming { index: 1, name: "classClass" }
        | 61 73 73 43
        | 6c 61 73 73
 0x18e5 | 02 0b 6d 65 | Naming { index: 2, name: "methodClass" }
        | 74 68 6f 64
        | 43 6c 61 73
        | 73         
 0x18f2 | 03 0c 63 6f | Naming { index: 3, name: "contextClass" }
        | 6e 74 65 78
        | 74 43 6c 61
        | 73 73      
 0x1900 | 04 0b 73 79 | Naming { index: 4, name: "symbolClass" }
        | 6d 62 6f 6c
        | 43 6c 61 73
        | 73         
 0x190d | 05 11 73 6d | Naming { index: 5, name: "smallIntegerClass" }
        | 61 6c 6c 49
        | 6e 74 65 67
        | 65 72 43 6c
        | 61 73 73   
 0x1920 | 06 0a 6d 61 | Naming { index: 6, name: "mainMethod" }
        | 69 6e 4d 65
        | 74 68 6f 64
 0x192c | 07 09 6e 69 | Naming { index: 7, name: "nilObject" }
        | 6c 4f 62 6a
        | 65 63 74   
 0x1937 | 08 0a 74 72 | Naming { index: 8, name: "trueObject" }
        | 75 65 4f 62
        | 6a 65 63 74
 0x1943 | 09 0b 66 61 | Naming { index: 9, name: "falseObject" }
        | 6c 73 65 4f
        | 62 6a 65 63
        | 74         
 0x1950 | 0a 10 77 6f | Naming { index: 10, name: "workloadSelector" }
        | 72 6b 6c 6f
        | 61 64 53 65
        | 6c 65 63 74
        | 6f 72      
 0x1962 | 0b 0d 61 63 | Naming { index: 11, name: "activeContext" }
        | 74 69 76 65
        | 43 6f 6e 74
        | 65 78 74   
 0x1971 | 0c 10 6e 65 | Naming { index: 12, name: "nextIdentityHash" }
        | 78 74 49 64
        | 65 6e 74 69
        | 74 79 48 61
        | 73 68      
 0x1983 | 0d 0b 66 69 | Naming { index: 13, name: "firstObject" }
        | 72 73 74 4f
        | 62 6a 65 63
        | 74         
 0x1990 | 0e 0a 6c 61 | Naming { index: 14, name: "lastObject" }
        | 73 74 4f 62
        | 6a 65 63 74
 0x199c | 0f 0b 6f 62 | Naming { index: 15, name: "objectCount" }
        | 6a 65 63 74
        | 43 6f 75 6e
        | 74         
 0x19a9 | 10 0c 6a 69 | Naming { index: 16, name: "jitThreshold" }
        | 74 54 68 72
        | 65 73 68 6f
        | 6c 64      
 0x19b7 | 11 0a 6a 69 | Naming { index: 17, name: "jitEnabled" }
        | 74 45 6e 61
        | 62 6c 65 64
 0x19c3 | 12 11 74 6f | Naming { index: 18, name: "totalCompilations" }
        | 74 61 6c 43
        | 6f 6d 70 69
        | 6c 61 74 69
        | 6f 6e 73   
 0x19d6 | 13 0f 6d 65 | Naming { index: 19, name: "methodCacheSize" }
        | 74 68 6f 64
        | 43 61 63 68
        | 65 53 69 7a
        | 65         
 0x19e7 | 14 0b 6d 65 | Naming { index: 20, name: "methodCache" }
        | 74 68 6f 64
        | 43 61 63 68
        | 65         
 0x19f4 | 15 10 62 79 | Naming { index: 21, name: "byteArrayCopyPtr" }
        | 74 65 41 72
        | 72 61 79 43
        | 6f 70 79 50
        | 74 72      
