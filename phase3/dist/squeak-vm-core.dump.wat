    0x0 | 00 61 73 6d | version 1 (Module)
        | 01 00 00 00
    0x8 | 01 da 02    | type section
    0xb | 16          | 22 count
--- rec group 0 (explicit) ---
    0xc | 4e 0a       | 
    0xe | 5e 6d 01    | [type 0] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Array(ArrayType(FieldType { element_type: Val(Ref(eqref)), mutable: true })), shared: false } }
   0x11 | 5e 78 01    | [type 1] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Array(ArrayType(FieldType { element_type: I8, mutable: true })), shared: false } }
   0x14 | 50 00 5f 05 | [type 2] SubType { is_final: false, supertype_idx: None, composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }] }), shared: false } }
        | 63 05 01 7f
        | 01 7f 01 7f
        | 01 63 02 01
   0x24 | 50 01 02 5f | [type 3] SubType { is_final: false, supertype_idx: Some(CoreTypeIndex { kind: "module", index: 2 }), composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 0)))), mutable: true }] }), shared: false } }
        | 06 63 05 01
        | 7f 01 7f 01
        | 7f 01 63 02
        | 01 63 00 01
   0x38 | 50 01 03 5f | [type 4] SubType { is_final: false, supertype_idx: Some(CoreTypeIndex { kind: "module", index: 3 }), composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 0)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 1)))), mutable: false }] }), shared: false } }
        | 07 63 05 01
        | 7f 01 7f 01
        | 7f 01 63 02
        | 01 63 00 01
        | 63 01 00   
   0x4f | 50 01 03 5f | [type 5] SubType { is_final: false, supertype_idx: Some(CoreTypeIndex { kind: "module", index: 3 }), composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 0)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 6)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 4)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }] }), shared: false } }
        | 0b 63 05 01
        | 7f 01 7f 01
        | 7f 01 63 02
        | 01 63 00 01
        | 63 05 01 63
        | 06 01 63 02
        | 01 63 04 01
        | 7f 01      
   0x71 | 50 01 03 5f | [type 6] SubType { is_final: false, supertype_idx: Some(CoreTypeIndex { kind: "module", index: 3 }), composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 0)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 0)))), mutable: false }, FieldType { element_type: Val(Ref((ref null (module 0)))), mutable: false }, FieldType { element_type: Val(I32), mutable: true }] }), shared: false } }
        | 09 63 05 01
        | 7f 01 7f 01
        | 7f 01 63 02
        | 01 63 00 01
        | 63 00 00 63
        | 00 00 7f 01
   0x8d | 50 01 03 5f | [type 7] SubType { is_final: false, supertype_idx: Some(CoreTypeIndex { kind: "module", index: 3 }), composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 0)))), mutable: true }, FieldType { element_type: Val(I32), mutable: false }, FieldType { element_type: Val(Ref((ref null (module 1)))), mutable: false }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: false }] }), shared: false } }
        | 0b 63 05 01
        | 7f 01 7f 01
        | 7f 01 63 02
        | 01 63 00 01
        | 7f 00 63 01
        | 00 7f 01 7f
        | 01 7f 00   
   0xac | 50 01 03 5f | [type 8] SubType { is_final: false, supertype_idx: Some(CoreTypeIndex { kind: "module", index: 3 }), composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 2)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 0)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 8)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(I32), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 7)))), mutable: true }, FieldType { element_type: Val(Ref(eqref)), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 0)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 0)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 0)))), mutable: true }] }), shared: false } }
        | 0e 63 05 01
        | 7f 01 7f 01
        | 7f 01 63 02
        | 01 63 00 01
        | 63 08 01 7f
        | 01 7f 01 63
        | 07 01 6d 01
        | 63 00 01 63
        | 00 01 63 00
        | 01         
   0xd5 | 5f 04 6d 01 | [type 9] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Struct(StructType { fields: [FieldType { element_type: Val(Ref(eqref)), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 5)))), mutable: true }, FieldType { element_type: Val(Ref((ref null (module 7)))), mutable: true }, FieldType { element_type: Val(I32), mutable: true }] }), shared: false } }
        | 63 05 01 63
        | 07 01 7f 01
--- rec group 1 (implicit) ---
   0xe1 | 60 01 7f 00 | [type 10] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [I32], results: [] }), shared: false } }
--- rec group 2 (implicit) ---
   0xe5 | 60 03 7f 7f | [type 11] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [I32, I32, I32], results: [I32] }), shared: false } }
        | 7f 01 7f   
--- rec group 3 (implicit) ---
   0xec | 60 03 7f 7f | [type 12] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [I32, I32, I32], results: [] }), shared: false } }
        | 7f 00      
--- rec group 4 (implicit) ---
   0xf2 | 60 01 64 01 | [type 13] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref (module 1)))], results: [I32] }), shared: false } }
        | 01 7f      
--- rec group 5 (implicit) ---
   0xf8 | 60 02 64 01 | [type 14] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref (module 1))), I32], results: [I32] }), shared: false } }
        | 7f 01 7f   
--- rec group 6 (implicit) ---
   0xff | 60 01 64 00 | [type 15] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref (module 0)))], results: [I32] }), shared: false } }
        | 01 7f      
--- rec group 7 (implicit) ---
  0x105 | 60 02 64 00 | [type 16] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref (module 0))), I32], results: [Ref(eqref)] }), shared: false } }
        | 7f 01 6d   
--- rec group 8 (implicit) ---
  0x10c | 60 01 6d 01 | [type 17] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref)], results: [I32] }), shared: false } }
        | 7f         
--- rec group 9 (implicit) ---
  0x111 | 60 00 01 7f | [type 18] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [], results: [I32] }), shared: false } }
--- rec group 10 (implicit) ---
  0x115 | 60 02 64 08 | [type 19] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref (module 8))), Ref(eqref)], results: [] }), shared: false } }
        | 6d 00      
--- rec group 11 (implicit) ---
  0x11b | 60 01 64 08 | [type 20] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref (module 8)))], results: [Ref(eqref)] }), shared: false } }
        | 01 6d      
--- rec group 12 (implicit) ---
  0x121 | 60 01 6d 01 | [type 21] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref)], results: [Ref((ref null (module 5)))] }), shared: false } }
        | 63 05      
--- rec group 13 (implicit) ---
  0x127 | 60 02 6d 6d | [type 22] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref), Ref(eqref)], results: [Ref((ref null (module 7)))] }), shared: false } }
        | 01 63 07   
--- rec group 14 (implicit) ---
  0x12e | 60 02 6d 63 | [type 23] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref), Ref((ref null (module 5)))], results: [Ref((ref null (module 7)))] }), shared: false } }
        | 05 01 63 07
--- rec group 15 (implicit) ---
  0x136 | 60 03 6d 63 | [type 24] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref), Ref((ref null (module 5))), Ref((ref (module 7)))], results: [] }), shared: false } }
        | 05 64 07 00
--- rec group 16 (implicit) ---
  0x13e | 60 03 6d 64 | [type 25] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref(eqref), Ref((ref (module 7))), Ref(eqref)], results: [Ref((ref (module 8)))] }), shared: false } }
        | 07 6d 01 64
        | 08         
--- rec group 17 (implicit) ---
  0x147 | 60 01 7f 01 | [type 26] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [I32], results: [Ref((ref i31))] }), shared: false } }
        | 64 6c      
--- rec group 18 (implicit) ---
  0x14d | 60 01 64 07 | [type 27] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref (module 7)))], results: [I32] }), shared: false } }
        | 01 7f      
--- rec group 19 (implicit) ---
  0x153 | 60 02 64 08 | [type 28] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref (module 8))), I32], results: [I32] }), shared: false } }
        | 7f 01 7f   
--- rec group 20 (implicit) ---
  0x15a | 60 01 64 08 | [type 29] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref (module 8)))], results: [I32] }), shared: false } }
        | 01 7f      
--- rec group 21 (implicit) ---
  0x160 | 60 01 64 07 | [type 30] SubType { is_final: true, supertype_idx: None, composite_type: CompositeType { inner: Func(FuncType { params: [Ref((ref (module 7)))], results: [] }), shared: false } }
        | 00         
  0x165 | 02 37       | import section
  0x167 | 03          | 3 count
  0x168 | 03 65 6e 76 | import [func 0] Import { module: "env", name: "reportResult", ty: Func(10) }
        | 0c 72 65 70
        | 6f 72 74 52
        | 65 73 75 6c
        | 74 00 0a   
  0x17b | 03 65 6e 76 | import [func 1] Import { module: "env", name: "compileMethod", ty: Func(11) }
        | 0d 63 6f 6d
        | 70 69 6c 65
        | 4d 65 74 68
        | 6f 64 00 0b
  0x18f | 03 65 6e 76 | import [func 2] Import { module: "env", name: "debugLog", ty: Func(12) }
        | 08 64 65 62
        | 75 67 4c 6f
        | 67 00 0c   
  0x19e | 03 1a       | func section
  0x1a0 | 19          | 25 count
  0x1a1 | 0d          | [func 3] type 13
  0x1a2 | 0e          | [func 4] type 14
  0x1a3 | 0f          | [func 5] type 15
  0x1a4 | 10          | [func 6] type 16
  0x1a5 | 11          | [func 7] type 17
  0x1a6 | 11          | [func 8] type 17
  0x1a7 | 12          | [func 9] type 18
  0x1a8 | 13          | [func 10] type 19
  0x1a9 | 14          | [func 11] type 20
  0x1aa | 14          | [func 12] type 20
  0x1ab | 15          | [func 13] type 21
  0x1ac | 16          | [func 14] type 22
  0x1ad | 17          | [func 15] type 23
  0x1ae | 18          | [func 16] type 24
  0x1af | 19          | [func 17] type 25
  0x1b0 | 1a          | [func 18] type 26
  0x1b1 | 11          | [func 19] type 17
  0x1b2 | 1b          | [func 20] type 27
  0x1b3 | 1c          | [func 21] type 28
  0x1b4 | 1e          | [func 22] type 30
  0x1b5 | 14          | [func 23] type 20
  0x1b6 | 12          | [func 24] type 18
  0x1b7 | 12          | [func 25] type 18
  0x1b8 | 1c          | [func 26] type 28
  0x1b9 | 12          | [func 27] type 18
  0x1ba | 04 04       | table section
  0x1bc | 01          | 1 count
  0x1bd | 70 00 64    | [table 0] Table { ty: TableType { element_type: funcref, table64: false, initial: 100, maximum: None, shared: false }, init: RefNull }
  0x1c0 | 06 7c       | global section
  0x1c2 | 16          | 22 count
  0x1c3 | 63 05 01    | [global 0] GlobalType { content_type: Ref((ref null (module 5))), mutable: true, shared: false }
  0x1c6 | d0 05       | ref_null hty:Concrete(Module(5))
  0x1c8 | 0b          | end
  0x1c9 | 63 05 01    | [global 1] GlobalType { content_type: Ref((ref null (module 5))), mutable: true, shared: false }
  0x1cc | d0 05       | ref_null hty:Concrete(Module(5))
  0x1ce | 0b          | end
  0x1cf | 63 05 01    | [global 2] GlobalType { content_type: Ref((ref null (module 5))), mutable: true, shared: false }
  0x1d2 | d0 05       | ref_null hty:Concrete(Module(5))
  0x1d4 | 0b          | end
  0x1d5 | 63 05 01    | [global 3] GlobalType { content_type: Ref((ref null (module 5))), mutable: true, shared: false }
  0x1d8 | d0 05       | ref_null hty:Concrete(Module(5))
  0x1da | 0b          | end
  0x1db | 63 05 01    | [global 4] GlobalType { content_type: Ref((ref null (module 5))), mutable: true, shared: false }
  0x1de | d0 05       | ref_null hty:Concrete(Module(5))
  0x1e0 | 0b          | end
  0x1e1 | 63 05 01    | [global 5] GlobalType { content_type: Ref((ref null (module 5))), mutable: true, shared: false }
  0x1e4 | d0 05       | ref_null hty:Concrete(Module(5))
  0x1e6 | 0b          | end
  0x1e7 | 6d 01       | [global 6] GlobalType { content_type: Ref(eqref), mutable: true, shared: false }
  0x1e9 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x1eb | 0b          | end
  0x1ec | 6d 01       | [global 7] GlobalType { content_type: Ref(eqref), mutable: true, shared: false }
  0x1ee | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x1f0 | 0b          | end
  0x1f1 | 6d 01       | [global 8] GlobalType { content_type: Ref(eqref), mutable: true, shared: false }
  0x1f3 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x1f5 | 0b          | end
  0x1f6 | 6d 01       | [global 9] GlobalType { content_type: Ref(eqref), mutable: true, shared: false }
  0x1f8 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x1fa | 0b          | end
  0x1fb | 63 08 01    | [global 10] GlobalType { content_type: Ref((ref null (module 8))), mutable: true, shared: false }
  0x1fe | d0 08       | ref_null hty:Concrete(Module(8))
  0x200 | 0b          | end
  0x201 | 7f 01       | [global 11] GlobalType { content_type: I32, mutable: true, shared: false }
  0x203 | 41 e8 07    | i32_const value:1000
  0x206 | 0b          | end
  0x207 | 63 02 01    | [global 12] GlobalType { content_type: Ref((ref null (module 2))), mutable: true, shared: false }
  0x20a | d0 02       | ref_null hty:Concrete(Module(2))
  0x20c | 0b          | end
  0x20d | 63 02 01    | [global 13] GlobalType { content_type: Ref((ref null (module 2))), mutable: true, shared: false }
  0x210 | d0 02       | ref_null hty:Concrete(Module(2))
  0x212 | 0b          | end
  0x213 | 7f 01       | [global 14] GlobalType { content_type: I32, mutable: true, shared: false }
  0x215 | 41 00       | i32_const value:0
  0x217 | 0b          | end
  0x218 | 7f 01       | [global 15] GlobalType { content_type: I32, mutable: true, shared: false }
  0x21a | 41 0a       | i32_const value:10
  0x21c | 0b          | end
  0x21d | 7f 01       | [global 16] GlobalType { content_type: I32, mutable: true, shared: false }
  0x21f | 41 01       | i32_const value:1
  0x221 | 0b          | end
  0x222 | 7f 01       | [global 17] GlobalType { content_type: I32, mutable: true, shared: false }
  0x224 | 41 00       | i32_const value:0
  0x226 | 0b          | end
  0x227 | 7f 01       | [global 18] GlobalType { content_type: I32, mutable: true, shared: false }
  0x229 | 41 80 02    | i32_const value:256
  0x22c | 0b          | end
  0x22d | 63 00 01    | [global 19] GlobalType { content_type: Ref((ref null (module 0))), mutable: true, shared: false }
  0x230 | d0 00       | ref_null hty:Concrete(Module(0))
  0x232 | 0b          | end
  0x233 | 63 00 01    | [global 20] GlobalType { content_type: Ref((ref null (module 0))), mutable: true, shared: false }
  0x236 | d0 00       | ref_null hty:Concrete(Module(0))
  0x238 | 0b          | end
  0x239 | 7f 01       | [global 21] GlobalType { content_type: I32, mutable: true, shared: false }
  0x23b | 41 01       | i32_const value:1
  0x23d | 0b          | end
  0x23e | 07 1a       | export section
  0x240 | 02          | 2 count
  0x241 | 0a 69 6e 69 | export Export { name: "initialize", kind: Func, index: 24 }
        | 74 69 61 6c
        | 69 7a 65 00
        | 18         
  0x24e | 09 69 6e 74 | export Export { name: "interpret", kind: Func, index: 27 }
        | 65 72 70 72
        | 65 74 00 1b
  0x25a | 0a ce 0e    | code section
  0x25d | 19          | 25 count
============== func 3 ====================
  0x25e | 06          | size of function
  0x25f | 00          | 0 local blocks
  0x260 | 20 00       | local_get local_index:0
  0x262 | fb 0f       | array_len
  0x264 | 0b          | end
============== func 4 ====================
  0x265 | 09          | size of function
  0x266 | 00          | 0 local blocks
  0x267 | 20 00       | local_get local_index:0
  0x269 | 20 01       | local_get local_index:1
  0x26b | fb 0d 01    | array_get_u array_type_index:1
  0x26e | 0b          | end
============== func 5 ====================
  0x26f | 06          | size of function
  0x270 | 00          | 0 local blocks
  0x271 | 20 00       | local_get local_index:0
  0x273 | fb 0f       | array_len
  0x275 | 0b          | end
============== func 6 ====================
  0x276 | 09          | size of function
  0x277 | 00          | 0 local blocks
  0x278 | 20 00       | local_get local_index:0
  0x27a | 20 01       | local_get local_index:1
  0x27c | fb 0b 00    | array_get array_type_index:0
  0x27f | 0b          | end
============== func 7 ====================
  0x280 | 07          | size of function
  0x281 | 00          | 0 local blocks
  0x282 | 20 00       | local_get local_index:0
  0x284 | fb 14 6c    | ref_test_non_null hty:Abstract { shared: false, ty: I31 }
  0x287 | 0b          | end
============== func 8 ====================
  0x288 | 09          | size of function
  0x289 | 00          | 0 local blocks
  0x28a | 20 00       | local_get local_index:0
  0x28c | fb 16 6c    | ref_cast_non_null hty:Abstract { shared: false, ty: I31 }
  0x28f | fb 1d       | i31_get_s
  0x291 | 0b          | end
============== func 9 ====================
  0x292 | 0b          | size of function
  0x293 | 00          | 0 local blocks
  0x294 | 23 0b       | global_get global_index:11
  0x296 | 41 01       | i32_const value:1
  0x298 | 6a          | i32_add
  0x299 | 24 0b       | global_set global_index:11
  0x29b | 23 0b       | global_get global_index:11
  0x29d | 0b          | end
============== func 10 ====================
  0x29e | 3d          | size of function
  0x29f | 02          | 2 local blocks
  0x2a0 | 01 63 00    | 1 locals of type Ref((ref null (module 0)))
  0x2a3 | 01 7f       | 1 locals of type I32
  0x2a5 | 20 00       | local_get local_index:0
  0x2a7 | fb 02 08 0d | struct_get struct_type_index:8 field_index:13
  0x2ab | 22 02       | local_tee local_index:2
  0x2ad | d1          | ref_is_null
  0x2ae | 04 40       | if blockty:Empty
  0x2b0 | 0f          | return
  0x2b1 | 0b          | end
  0x2b2 | 20 00       | local_get local_index:0
  0x2b4 | fb 02 08 08 | struct_get struct_type_index:8 field_index:8
  0x2b8 | 22 03       | local_tee local_index:3
  0x2ba | 20 03       | local_get local_index:3
  0x2bc | 20 02       | local_get local_index:2
  0x2be | d4          | ref_as_non_null
  0x2bf | fb 0f       | array_len
  0x2c1 | 4f          | i32_ge_u
  0x2c2 | 04 40       | if blockty:Empty
  0x2c4 | 0f          | return
  0x2c5 | 0b          | end
  0x2c6 | 20 02       | local_get local_index:2
  0x2c8 | d4          | ref_as_non_null
  0x2c9 | 20 03       | local_get local_index:3
  0x2cb | 20 01       | local_get local_index:1
  0x2cd | fb 0e 00    | array_set array_type_index:0
  0x2d0 | 20 00       | local_get local_index:0
  0x2d2 | 20 03       | local_get local_index:3
  0x2d4 | 41 01       | i32_const value:1
  0x2d6 | 6a          | i32_add
  0x2d7 | fb 05 08 08 | struct_set struct_type_index:8 field_index:8
  0x2db | 0b          | end
============== func 11 ====================
  0x2dc | 40          | size of function
  0x2dd | 02          | 2 local blocks
  0x2de | 01 63 00    | 1 locals of type Ref((ref null (module 0)))
  0x2e1 | 01 7f       | 1 locals of type I32
  0x2e3 | 20 00       | local_get local_index:0
  0x2e5 | fb 02 08 0d | struct_get struct_type_index:8 field_index:13
  0x2e9 | 22 01       | local_tee local_index:1
  0x2eb | d1          | ref_is_null
  0x2ec | 04 40       | if blockty:Empty
  0x2ee | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x2f0 | 0f          | return
  0x2f1 | 0b          | end
  0x2f2 | 20 00       | local_get local_index:0
  0x2f4 | fb 02 08 08 | struct_get struct_type_index:8 field_index:8
  0x2f8 | 22 02       | local_tee local_index:2
  0x2fa | 20 02       | local_get local_index:2
  0x2fc | 41 00       | i32_const value:0
  0x2fe | 4d          | i32_le_u
  0x2ff | 04 40       | if blockty:Empty
  0x301 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x303 | 0f          | return
  0x304 | 0b          | end
  0x305 | 20 02       | local_get local_index:2
  0x307 | 41 01       | i32_const value:1
  0x309 | 6b          | i32_sub
  0x30a | 22 02       | local_tee local_index:2
  0x30c | 20 00       | local_get local_index:0
  0x30e | 20 02       | local_get local_index:2
  0x310 | fb 05 08 08 | struct_set struct_type_index:8 field_index:8
  0x314 | 20 01       | local_get local_index:1
  0x316 | d4          | ref_as_non_null
  0x317 | 20 02       | local_get local_index:2
  0x319 | fb 0b 00    | array_get array_type_index:0
  0x31c | 0b          | end
============== func 12 ====================
  0x31d | 34          | size of function
  0x31e | 02          | 2 local blocks
  0x31f | 01 63 00    | 1 locals of type Ref((ref null (module 0)))
  0x322 | 01 7f       | 1 locals of type I32
  0x324 | 20 00       | local_get local_index:0
  0x326 | fb 02 08 0d | struct_get struct_type_index:8 field_index:13
  0x32a | 22 01       | local_tee local_index:1
  0x32c | d1          | ref_is_null
  0x32d | 04 40       | if blockty:Empty
  0x32f | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x331 | 0f          | return
  0x332 | 0b          | end
  0x333 | 20 00       | local_get local_index:0
  0x335 | fb 02 08 08 | struct_get struct_type_index:8 field_index:8
  0x339 | 22 02       | local_tee local_index:2
  0x33b | 20 02       | local_get local_index:2
  0x33d | 41 00       | i32_const value:0
  0x33f | 4d          | i32_le_u
  0x340 | 04 40       | if blockty:Empty
  0x342 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x344 | 0f          | return
  0x345 | 0b          | end
  0x346 | 20 01       | local_get local_index:1
  0x348 | d4          | ref_as_non_null
  0x349 | 20 02       | local_get local_index:2
  0x34b | 41 01       | i32_const value:1
  0x34d | 6b          | i32_sub
  0x34e | fb 0b 00    | array_get array_type_index:0
  0x351 | 0b          | end
============== func 13 ====================
  0x352 | 17          | size of function
  0x353 | 00          | 0 local blocks
  0x354 | 20 00       | local_get local_index:0
  0x356 | fb 14 6c    | ref_test_non_null hty:Abstract { shared: false, ty: I31 }
  0x359 | 04 63 05    | if blockty:Type(Ref((ref null (module 5))))
  0x35c | 23 05       | global_get global_index:5
  0x35e | 05          | else
  0x35f | 20 00       | local_get local_index:0
  0x361 | fb 16 02    | ref_cast_non_null hty:Concrete(Module(2))
  0x364 | fb 02 02 00 | struct_get struct_type_index:2 field_index:0
  0x368 | 0b          | end
  0x369 | 0b          | end
============== func 14 ====================
  0x36a | b5 01       | size of function
  0x36c | 05          | 5 local blocks
  0x36d | 02 63 05    | 2 locals of type Ref((ref null (module 5)))
  0x370 | 01 63 06    | 1 locals of type Ref((ref null (module 6)))
  0x373 | 02 63 00    | 2 locals of type Ref((ref null (module 0)))
  0x376 | 02 7f       | 2 locals of type I32
  0x378 | 01 6d       | 1 locals of type Ref(eqref)
  0x37a | 20 00       | local_get local_index:0
  0x37c | 10 0d       | call function_index:13
  0x37e | 21 03       | local_set local_index:3
  0x380 | 03 40       | loop blockty:Empty
  0x382 | 20 03       | local_get local_index:3
  0x384 | d1          | ref_is_null
  0x385 | 04 40       | if blockty:Empty
  0x387 | d0 07       | ref_null hty:Concrete(Module(7))
  0x389 | 0f          | return
  0x38a | 0b          | end
  0x38b | 20 03       | local_get local_index:3
  0x38d | d4          | ref_as_non_null
  0x38e | fb 02 05 07 | struct_get struct_type_index:5 field_index:7
  0x392 | 22 04       | local_tee local_index:4
  0x394 | d1          | ref_is_null
  0x395 | 04 40       | if blockty:Empty
  0x397 | 20 03       | local_get local_index:3
  0x399 | d4          | ref_as_non_null
  0x39a | fb 02 05 06 | struct_get struct_type_index:5 field_index:6
  0x39e | 21 03       | local_set local_index:3
  0x3a0 | 0c 01       | br relative_depth:1
  0x3a2 | 0b          | end
  0x3a3 | 20 04       | local_get local_index:4
  0x3a5 | d4          | ref_as_non_null
  0x3a6 | fb 02 06 06 | struct_get struct_type_index:6 field_index:6
  0x3aa | 22 05       | local_tee local_index:5
  0x3ac | d1          | ref_is_null
  0x3ad | 04 40       | if blockty:Empty
  0x3af | 20 03       | local_get local_index:3
  0x3b1 | d4          | ref_as_non_null
  0x3b2 | fb 02 05 06 | struct_get struct_type_index:5 field_index:6
  0x3b6 | 21 03       | local_set local_index:3
  0x3b8 | 0c 01       | br relative_depth:1
  0x3ba | 0b          | end
  0x3bb | 20 04       | local_get local_index:4
  0x3bd | d4          | ref_as_non_null
  0x3be | fb 02 06 07 | struct_get struct_type_index:6 field_index:7
  0x3c2 | 22 06       | local_tee local_index:6
  0x3c4 | d1          | ref_is_null
  0x3c5 | 04 40       | if blockty:Empty
  0x3c7 | 20 03       | local_get local_index:3
  0x3c9 | d4          | ref_as_non_null
  0x3ca | fb 02 05 06 | struct_get struct_type_index:5 field_index:6
  0x3ce | 21 03       | local_set local_index:3
  0x3d0 | 0c 01       | br relative_depth:1
  0x3d2 | 0b          | end
  0x3d3 | 20 04       | local_get local_index:4
  0x3d5 | d4          | ref_as_non_null
  0x3d6 | fb 02 06 08 | struct_get struct_type_index:6 field_index:8
  0x3da | 21 07       | local_set local_index:7
  0x3dc | 41 00       | i32_const value:0
  0x3de | 21 08       | local_set local_index:8
  0x3e0 | 03 40       | loop blockty:Empty
  0x3e2 | 20 08       | local_get local_index:8
  0x3e4 | 20 07       | local_get local_index:7
  0x3e6 | 4f          | i32_ge_u
  0x3e7 | 04 40       | if blockty:Empty
  0x3e9 | 20 03       | local_get local_index:3
  0x3eb | d4          | ref_as_non_null
  0x3ec | fb 02 05 06 | struct_get struct_type_index:5 field_index:6
  0x3f0 | 21 03       | local_set local_index:3
  0x3f2 | 0c 02       | br relative_depth:2
  0x3f4 | 0b          | end
  0x3f5 | 20 05       | local_get local_index:5
  0x3f7 | d4          | ref_as_non_null
  0x3f8 | 20 08       | local_get local_index:8
  0x3fa | fb 0b 00    | array_get array_type_index:0
  0x3fd | 21 09       | local_set local_index:9
  0x3ff | 20 09       | local_get local_index:9
  0x401 | 20 01       | local_get local_index:1
  0x403 | d3          | ref_eq
  0x404 | 04 40       | if blockty:Empty
  0x406 | 20 06       | local_get local_index:6
  0x408 | d4          | ref_as_non_null
  0x409 | 20 08       | local_get local_index:8
  0x40b | fb 0b 00    | array_get array_type_index:0
  0x40e | fb 16 07    | ref_cast_non_null hty:Concrete(Module(7))
  0x411 | 0f          | return
  0x412 | 0b          | end
  0x413 | 20 08       | local_get local_index:8
  0x415 | 41 01       | i32_const value:1
  0x417 | 6a          | i32_add
  0x418 | 21 08       | local_set local_index:8
  0x41a | 0c 00       | br relative_depth:0
  0x41c | 0b          | end
  0x41d | 0b          | end
  0x41e | d0 07       | ref_null hty:Concrete(Module(7))
  0x420 | 0b          | end
============== func 15 ====================
  0x421 | 96 01       | size of function
  0x423 | 04          | 4 local blocks
  0x424 | 01 63 00    | 1 locals of type Ref((ref null (module 0)))
  0x427 | 03 7f       | 3 locals of type I32
  0x429 | 01 63 09    | 1 locals of type Ref((ref null (module 9)))
  0x42c | 01 7f       | 1 locals of type I32
  0x42e | 23 13       | global_get global_index:19
  0x430 | 22 02       | local_tee local_index:2
  0x432 | d1          | ref_is_null
  0x433 | 04 40       | if blockty:Empty
  0x435 | d0 07       | ref_null hty:Concrete(Module(7))
  0x437 | 0f          | return
  0x438 | 0b          | end
  0x439 | 20 00       | local_get local_index:0
  0x43b | fb 16 02    | ref_cast_non_null hty:Concrete(Module(2))
  0x43e | fb 02 02 01 | struct_get struct_type_index:2 field_index:1
  0x442 | 20 01       | local_get local_index:1
  0x444 | d4          | ref_as_non_null
  0x445 | fb 02 05 01 | struct_get struct_type_index:5 field_index:1
  0x449 | 6a          | i32_add
  0x44a | 23 12       | global_get global_index:18
  0x44c | 70          | i32_rem_u
  0x44d | 21 05       | local_set local_index:5
  0x44f | 41 08       | i32_const value:8
  0x451 | 21 07       | local_set local_index:7
  0x453 | 03 40       | loop blockty:Empty
  0x455 | 20 07       | local_get local_index:7
  0x457 | 41 00       | i32_const value:0
  0x459 | 4c          | i32_le_s
  0x45a | 04 40       | if blockty:Empty
  0x45c | d0 07       | ref_null hty:Concrete(Module(7))
  0x45e | 0f          | return
  0x45f | 0b          | end
  0x460 | 20 02       | local_get local_index:2
  0x462 | d4          | ref_as_non_null
  0x463 | 20 05       | local_get local_index:5
  0x465 | fb 0b 00    | array_get array_type_index:0
  0x468 | 22 06       | local_tee local_index:6
  0x46a | d1          | ref_is_null
  0x46b | 04 40       | if blockty:Empty
  0x46d | d0 07       | ref_null hty:Concrete(Module(7))
  0x46f | 0f          | return
  0x470 | 0b          | end
  0x471 | 20 06       | local_get local_index:6
  0x473 | fb 16 09    | ref_cast_non_null hty:Concrete(Module(9))
  0x476 | 22 06       | local_tee local_index:6
  0x478 | fb 02 09 00 | struct_get struct_type_index:9 field_index:0
  0x47c | 20 00       | local_get local_index:0
  0x47e | d3          | ref_eq
  0x47f | 20 06       | local_get local_index:6
  0x481 | fb 02 09 01 | struct_get struct_type_index:9 field_index:1
  0x485 | 20 01       | local_get local_index:1
  0x487 | d3          | ref_eq
  0x488 | 71          | i32_and
  0x489 | 04 40       | if blockty:Empty
  0x48b | 20 06       | local_get local_index:6
  0x48d | 20 06       | local_get local_index:6
  0x48f | fb 02 09 03 | struct_get struct_type_index:9 field_index:3
  0x493 | 41 01       | i32_const value:1
  0x495 | 6a          | i32_add
  0x496 | fb 05 09 03 | struct_set struct_type_index:9 field_index:3
  0x49a | 20 06       | local_get local_index:6
  0x49c | fb 02 09 02 | struct_get struct_type_index:9 field_index:2
  0x4a0 | 0f          | return
  0x4a1 | 0b          | end
  0x4a2 | 20 05       | local_get local_index:5
  0x4a4 | 41 01       | i32_const value:1
  0x4a6 | 6a          | i32_add
  0x4a7 | 23 12       | global_get global_index:18
  0x4a9 | 70          | i32_rem_u
  0x4aa | 21 05       | local_set local_index:5
  0x4ac | 20 07       | local_get local_index:7
  0x4ae | 41 01       | i32_const value:1
  0x4b0 | 6b          | i32_sub
  0x4b1 | 21 07       | local_set local_index:7
  0x4b3 | 0c 00       | br relative_depth:0
  0x4b5 | 0b          | end
  0x4b6 | d0 07       | ref_null hty:Concrete(Module(7))
  0x4b8 | 0b          | end
============== func 16 ====================
  0x4b9 | 40          | size of function
  0x4ba | 03          | 3 local blocks
  0x4bb | 01 63 00    | 1 locals of type Ref((ref null (module 0)))
  0x4be | 01 7f       | 1 locals of type I32
  0x4c0 | 01 64 09    | 1 locals of type Ref((ref (module 9)))
  0x4c3 | 23 13       | global_get global_index:19
  0x4c5 | 22 03       | local_tee local_index:3
  0x4c7 | d1          | ref_is_null
  0x4c8 | 04 40       | if blockty:Empty
  0x4ca | 0f          | return
  0x4cb | 0b          | end
  0x4cc | 20 00       | local_get local_index:0
  0x4ce | fb 16 02    | ref_cast_non_null hty:Concrete(Module(2))
  0x4d1 | fb 02 02 01 | struct_get struct_type_index:2 field_index:1
  0x4d5 | 20 01       | local_get local_index:1
  0x4d7 | d4          | ref_as_non_null
  0x4d8 | fb 02 05 01 | struct_get struct_type_index:5 field_index:1
  0x4dc | 6a          | i32_add
  0x4dd | 23 12       | global_get global_index:18
  0x4df | 70          | i32_rem_u
  0x4e0 | 21 04       | local_set local_index:4
  0x4e2 | 20 00       | local_get local_index:0
  0x4e4 | 20 01       | local_get local_index:1
  0x4e6 | 20 02       | local_get local_index:2
  0x4e8 | 41 01       | i32_const value:1
  0x4ea | fb 00 09    | struct_new struct_type_index:9
  0x4ed | 21 05       | local_set local_index:5
  0x4ef | 20 03       | local_get local_index:3
  0x4f1 | d4          | ref_as_non_null
  0x4f2 | 20 04       | local_get local_index:4
  0x4f4 | 20 05       | local_get local_index:5
  0x4f6 | fb 0e 00    | array_set array_type_index:0
  0x4f9 | 0b          | end
============== func 17 ====================
  0x4fa | 32          | size of function
  0x4fb | 01          | 1 local blocks
  0x4fc | 01 64 00    | 1 locals of type Ref((ref (module 0)))
  0x4ff | 41 14       | i32_const value:20
  0x501 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x503 | fb 06 00    | array_new array_type_index:0
  0x506 | 21 03       | local_set local_index:3
  0x508 | 23 00       | global_get global_index:0
  0x50a | 10 09       | call function_index:9
  0x50c | 41 0e       | i32_const value:14
  0x50e | 41 0e       | i32_const value:14
  0x510 | d0 02       | ref_null hty:Concrete(Module(2))
  0x512 | 41 08       | i32_const value:8
  0x514 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x516 | fb 06 00    | array_new array_type_index:0
  0x519 | 23 0a       | global_get global_index:10
  0x51b | 41 00       | i32_const value:0
  0x51d | 41 00       | i32_const value:0
  0x51f | 20 01       | local_get local_index:1
  0x521 | 20 00       | local_get local_index:0
  0x523 | d0 00       | ref_null hty:Concrete(Module(0))
  0x525 | d0 00       | ref_null hty:Concrete(Module(0))
  0x527 | 20 03       | local_get local_index:3
  0x529 | fb 00 08    | struct_new struct_type_index:8
  0x52c | 0b          | end
============== func 18 ====================
  0x52d | 06          | size of function
  0x52e | 00          | 0 local blocks
  0x52f | 20 00       | local_get local_index:0
  0x531 | fb 1c       | ref_i31
  0x533 | 0b          | end
============== func 19 ====================
  0x534 | 14          | size of function
  0x535 | 00          | 0 local blocks
  0x536 | 20 00       | local_get local_index:0
  0x538 | fb 14 6c    | ref_test_non_null hty:Abstract { shared: false, ty: I31 }
  0x53b | 04 7f       | if blockty:Type(I32)
  0x53d | 20 00       | local_get local_index:0
  0x53f | fb 16 6c    | ref_cast_non_null hty:Abstract { shared: false, ty: I31 }
  0x542 | fb 1d       | i31_get_s
  0x544 | 05          | else
  0x545 | 41 00       | i32_const value:0
  0x547 | 0b          | end
  0x548 | 0b          | end
============== func 20 ====================
  0x549 | 0b          | size of function
  0x54a | 00          | 0 local blocks
  0x54b | 20 00       | local_get local_index:0
  0x54d | fb 02 07 09 | struct_get struct_type_index:7 field_index:9
  0x551 | 41 00       | i32_const value:0
  0x553 | 47          | i32_ne
  0x554 | 0b          | end
============== func 21 ====================
  0x555 | 09          | size of function
  0x556 | 00          | 0 local blocks
  0x557 | 20 00       | local_get local_index:0
  0x559 | 20 01       | local_get local_index:1
  0x55b | 11 1d 00    | call_indirect type_index:29 table_index:0
  0x55e | 0b          | end
============== func 22 ====================
  0x55f | 44          | size of function
  0x560 | 02          | 2 local blocks
  0x561 | 01 63 01    | 1 locals of type Ref((ref null (module 1)))
  0x564 | 02 7f       | 2 locals of type I32
  0x566 | 20 00       | local_get local_index:0
  0x568 | fb 02 07 07 | struct_get struct_type_index:7 field_index:7
  0x56c | 22 01       | local_tee local_index:1
  0x56e | d1          | ref_is_null
  0x56f | 04 40       | if blockty:Empty
  0x571 | 0f          | return
  0x572 | 0b          | end
  0x573 | 20 01       | local_get local_index:1
  0x575 | d4          | ref_as_non_null
  0x576 | fb 0f       | array_len
  0x578 | 21 02       | local_set local_index:2
  0x57a | 20 00       | local_get local_index:0
  0x57c | fb 16 02    | ref_cast_non_null hty:Concrete(Module(2))
  0x57f | fb 02 02 01 | struct_get struct_type_index:2 field_index:1
  0x583 | 41 80 20    | i32_const value:4096
  0x586 | 20 02       | local_get local_index:2
  0x588 | 10 01       | call function_index:1
  0x58a | 21 03       | local_set local_index:3
  0x58c | 20 03       | local_get local_index:3
  0x58e | 41 00       | i32_const value:0
  0x590 | 47          | i32_ne
  0x591 | 04 40       | if blockty:Empty
  0x593 | 20 00       | local_get local_index:0
  0x595 | 20 03       | local_get local_index:3
  0x597 | fb 05 07 09 | struct_set struct_type_index:7 field_index:9
  0x59b | 23 11       | global_get global_index:17
  0x59d | 41 01       | i32_const value:1
  0x59f | 6a          | i32_add
  0x5a0 | 24 11       | global_set global_index:17
  0x5a2 | 0b          | end
  0x5a3 | 0b          | end
============== func 23 ====================
  0x5a4 | 2b          | size of function
  0x5a5 | 02          | 2 local blocks
  0x5a6 | 01 63 08    | 1 locals of type Ref((ref null (module 8)))
  0x5a9 | 01 6d       | 1 locals of type Ref(eqref)
  0x5ab | 20 00       | local_get local_index:0
  0x5ad | 10 0c       | call function_index:12
  0x5af | 21 02       | local_set local_index:2
  0x5b1 | 20 00       | local_get local_index:0
  0x5b3 | fb 02 08 06 | struct_get struct_type_index:8 field_index:6
  0x5b7 | 22 01       | local_tee local_index:1
  0x5b9 | d1          | ref_is_null
  0x5ba | 04 40       | if blockty:Empty
  0x5bc | 20 02       | local_get local_index:2
  0x5be | 0f          | return
  0x5bf | 0b          | end
  0x5c0 | 20 01       | local_get local_index:1
  0x5c2 | d4          | ref_as_non_null
  0x5c3 | 24 0a       | global_set global_index:10
  0x5c5 | 20 01       | local_get local_index:1
  0x5c7 | d4          | ref_as_non_null
  0x5c8 | 20 02       | local_get local_index:2
  0x5ca | d4          | ref_as_non_null
  0x5cb | 10 0a       | call function_index:10
  0x5cd | 20 02       | local_get local_index:2
  0x5cf | 0b          | end
============== func 24 ====================
  0x5d0 | 06          | size of function
  0x5d1 | 00          | 0 local blocks
  0x5d2 | 10 19       | call function_index:25
  0x5d4 | 41 01       | i32_const value:1
  0x5d6 | 0b          | end
============== func 25 ====================
  0x5d7 | bf 03       | size of function
  0x5d9 | 08          | 8 local blocks
  0x5da | 02 64 07    | 2 locals of type Ref((ref (module 7)))
  0x5dd | 01 64 08    | 1 locals of type Ref((ref (module 8)))
  0x5e0 | 02 64 01    | 2 locals of type Ref((ref (module 1)))
  0x5e3 | 01 64 00    | 1 locals of type Ref((ref (module 0)))
  0x5e6 | 01 64 6c    | 1 locals of type Ref((ref i31))
  0x5e9 | 03 64 05    | 3 locals of type Ref((ref (module 5)))
  0x5ec | 01 64 06    | 1 locals of type Ref((ref (module 6)))
  0x5ef | 01 64 04    | 1 locals of type Ref((ref (module 4)))
  0x5f2 | 23 12       | global_get global_index:18
  0x5f4 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x5f6 | fb 06 00    | array_new array_type_index:0
  0x5f9 | 24 13       | global_set global_index:19
  0x5fb | 41 e4 00    | i32_const value:100
  0x5fe | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x600 | fb 06 00    | array_new array_type_index:0
  0x603 | 24 14       | global_set global_index:20
  0x605 | d0 05       | ref_null hty:Concrete(Module(5))
  0x607 | 10 09       | call function_index:9
  0x609 | 41 01       | i32_const value:1
  0x60b | 41 0b       | i32_const value:11
  0x60d | d0 02       | ref_null hty:Concrete(Module(2))
  0x60f | 41 06       | i32_const value:6
  0x611 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x613 | fb 06 00    | array_new array_type_index:0
  0x616 | d0 05       | ref_null hty:Concrete(Module(5))
  0x618 | d0 06       | ref_null hty:Concrete(Module(6))
  0x61a | d0 02       | ref_null hty:Concrete(Module(2))
  0x61c | d0 04       | ref_null hty:Concrete(Module(4))
  0x61e | 41 00       | i32_const value:0
  0x620 | fb 00 05    | struct_new struct_type_index:5
  0x623 | 22 08       | local_tee local_index:8
  0x625 | 24 01       | global_set global_index:1
  0x627 | 20 08       | local_get local_index:8
  0x629 | 20 08       | local_get local_index:8
  0x62b | fb 05 05 00 | struct_set struct_type_index:5 field_index:0
  0x62f | 20 08       | local_get local_index:8
  0x631 | 10 09       | call function_index:9
  0x633 | 41 01       | i32_const value:1
  0x635 | 41 0b       | i32_const value:11
  0x637 | d0 02       | ref_null hty:Concrete(Module(2))
  0x639 | 41 06       | i32_const value:6
  0x63b | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x63d | fb 06 00    | array_new array_type_index:0
  0x640 | d0 05       | ref_null hty:Concrete(Module(5))
  0x642 | d0 06       | ref_null hty:Concrete(Module(6))
  0x644 | d0 02       | ref_null hty:Concrete(Module(2))
  0x646 | d0 04       | ref_null hty:Concrete(Module(4))
  0x648 | 41 00       | i32_const value:0
  0x64a | fb 00 05    | struct_new struct_type_index:5
  0x64d | 22 07       | local_tee local_index:7
  0x64f | 24 00       | global_set global_index:0
  0x651 | 20 08       | local_get local_index:8
  0x653 | 10 09       | call function_index:9
  0x655 | 41 01       | i32_const value:1
  0x657 | 41 0b       | i32_const value:11
  0x659 | d0 02       | ref_null hty:Concrete(Module(2))
  0x65b | 41 06       | i32_const value:6
  0x65d | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x65f | fb 06 00    | array_new array_type_index:0
  0x662 | 20 07       | local_get local_index:7
  0x664 | d0 06       | ref_null hty:Concrete(Module(6))
  0x666 | d0 02       | ref_null hty:Concrete(Module(2))
  0x668 | d0 04       | ref_null hty:Concrete(Module(4))
  0x66a | 41 00       | i32_const value:0
  0x66c | fb 00 05    | struct_new struct_type_index:5
  0x66f | 22 09       | local_tee local_index:9
  0x671 | 24 05       | global_set global_index:5
  0x673 | 20 07       | local_get local_index:7
  0x675 | 10 09       | call function_index:9
  0x677 | 41 02       | i32_const value:2
  0x679 | 41 09       | i32_const value:9
  0x67b | d0 02       | ref_null hty:Concrete(Module(2))
  0x67d | 41 02       | i32_const value:2
  0x67f | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x681 | fb 06 00    | array_new array_type_index:0
  0x684 | 41 02       | i32_const value:2
  0x686 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x688 | fb 06 00    | array_new array_type_index:0
  0x68b | 41 02       | i32_const value:2
  0x68d | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x68f | fb 06 00    | array_new array_type_index:0
  0x692 | 41 00       | i32_const value:0
  0x694 | fb 00 06    | struct_new struct_type_index:6
  0x697 | 21 0a       | local_set local_index:10
  0x699 | 20 09       | local_get local_index:9
  0x69b | 20 0a       | local_get local_index:10
  0x69d | fb 05 05 07 | struct_set struct_type_index:5 field_index:7
  0x6a1 | 20 07       | local_get local_index:7
  0x6a3 | 10 09       | call function_index:9
  0x6a5 | 41 08       | i32_const value:8
  0x6a7 | 41 07       | i32_const value:7
  0x6a9 | d0 02       | ref_null hty:Concrete(Module(2))
  0x6ab | 41 01       | i32_const value:1
  0x6ad | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x6af | fb 06 00    | array_new array_type_index:0
  0x6b2 | 41 07       | i32_const value:7
  0x6b4 | 41 f3 00    | i32_const value:115
  0x6b7 | 41 f1 00    | i32_const value:113
  0x6ba | 41 f5 00    | i32_const value:117
  0x6bd | 41 e1 00    | i32_const value:97
  0x6c0 | 41 f2 00    | i32_const value:114
  0x6c3 | 41 e5 00    | i32_const value:101
  0x6c6 | 41 e4 00    | i32_const value:100
  0x6c9 | fb 06 01    | array_new array_type_index:1
  0x6cc | fb 00 04    | struct_new struct_type_index:4
  0x6cf | 21 0b       | local_set local_index:11
  0x6d1 | 24 09       | global_set global_index:9
  0x6d3 | 41 03       | i32_const value:3
  0x6d5 | fb 1c       | ref_i31
  0x6d7 | 21 06       | local_set local_index:6
  0x6d9 | 41 03       | i32_const value:3
  0x6db | 41 f0 00    | i32_const value:112
  0x6de | 41 d0 01    | i32_const value:208
  0x6e1 | 41 00       | i32_const value:0
  0x6e3 | fb 06 01    | array_new array_type_index:1
  0x6e6 | 21 03       | local_set local_index:3
  0x6e8 | 41 04       | i32_const value:4
  0x6ea | 41 f0 00    | i32_const value:112
  0x6ed | 41 f0 00    | i32_const value:112
  0x6f0 | 41 b8 01    | i32_const value:184
  0x6f3 | 41 fc 00    | i32_const value:124
  0x6f6 | fb 06 01    | array_new array_type_index:1
  0x6f9 | 21 04       | local_set local_index:4
  0x6fb | 20 07       | local_get local_index:7
  0x6fd | 41 e9 07    | i32_const value:1001
  0x700 | 41 0c       | i32_const value:12
  0x702 | 41 0b       | i32_const value:11
  0x704 | d0 02       | ref_null hty:Concrete(Module(2))
  0x706 | 41 01       | i32_const value:1
  0x708 | 20 0b       | local_get local_index:11
  0x70a | fb 06 00    | array_new array_type_index:0
  0x70d | 41 00       | i32_const value:0
  0x70f | 20 03       | local_get local_index:3
  0x711 | 41 00       | i32_const value:0
  0x713 | 41 00       | i32_const value:0
  0x715 | 41 0a       | i32_const value:10
  0x717 | fb 00 07    | struct_new struct_type_index:7
  0x71a | 21 00       | local_set local_index:0
  0x71c | 20 07       | local_get local_index:7
  0x71e | 41 ea 07    | i32_const value:1002
  0x721 | 41 0c       | i32_const value:12
  0x723 | 41 0b       | i32_const value:11
  0x725 | d0 02       | ref_null hty:Concrete(Module(2))
  0x727 | 41 06       | i32_const value:6
  0x729 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x72b | fb 06 00    | array_new array_type_index:0
  0x72e | 41 00       | i32_const value:0
  0x730 | 20 04       | local_get local_index:4
  0x732 | 41 00       | i32_const value:0
  0x734 | 41 00       | i32_const value:0
  0x736 | 41 0a       | i32_const value:10
  0x738 | fb 00 07    | struct_new struct_type_index:7
  0x73b | 21 01       | local_set local_index:1
  0x73d | 20 0a       | local_get local_index:10
  0x73f | fb 02 06 06 | struct_get struct_type_index:6 field_index:6
  0x743 | d4          | ref_as_non_null
  0x744 | 41 00       | i32_const value:0
  0x746 | 20 0b       | local_get local_index:11
  0x748 | fb 0e 00    | array_set array_type_index:0
  0x74b | 20 0a       | local_get local_index:10
  0x74d | fb 02 06 07 | struct_get struct_type_index:6 field_index:7
  0x751 | d4          | ref_as_non_null
  0x752 | 41 00       | i32_const value:0
  0x754 | 20 01       | local_get local_index:1
  0x756 | fb 0e 00    | array_set array_type_index:0
  0x759 | 20 0a       | local_get local_index:10
  0x75b | 41 01       | i32_const value:1
  0x75d | fb 05 06 08 | struct_set struct_type_index:6 field_index:8
  0x761 | 41 14       | i32_const value:20
  0x763 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x765 | fb 06 00    | array_new array_type_index:0
  0x768 | 21 05       | local_set local_index:5
  0x76a | 20 07       | local_get local_index:7
  0x76c | 41 d1 0f    | i32_const value:2001
  0x76f | 41 0e       | i32_const value:14
  0x771 | 41 0e       | i32_const value:14
  0x773 | d0 02       | ref_null hty:Concrete(Module(2))
  0x775 | 41 08       | i32_const value:8
  0x777 | d0 6d       | ref_null hty:Abstract { shared: false, ty: Eq }
  0x779 | fb 06 00    | array_new array_type_index:0
  0x77c | d0 08       | ref_null hty:Concrete(Module(8))
  0x77e | 41 00       | i32_const value:0
  0x780 | 41 00       | i32_const value:0
  0x782 | 20 00       | local_get local_index:0
  0x784 | 20 06       | local_get local_index:6
  0x786 | d0 00       | ref_null hty:Concrete(Module(0))
  0x788 | d0 00       | ref_null hty:Concrete(Module(0))
  0x78a | 20 05       | local_get local_index:5
  0x78c | fb 00 08    | struct_new struct_type_index:8
  0x78f | 21 02       | local_set local_index:2
  0x791 | 20 02       | local_get local_index:2
  0x793 | 24 0a       | global_set global_index:10
  0x795 | 41 01       | i32_const value:1
  0x797 | 0b          | end
============== func 26 ====================
  0x798 | 96 02       | size of function
  0x79a | 06          | 6 local blocks
  0x79b | 03 6d       | 3 locals of type Ref(eqref)
  0x79d | 03 7f       | 3 locals of type I32
  0x79f | 01 64 08    | 1 locals of type Ref((ref (module 8)))
  0x7a2 | 01 6d       | 1 locals of type Ref(eqref)
  0x7a4 | 01 63 07    | 1 locals of type Ref((ref null (module 7)))
  0x7a7 | 01 63 05    | 1 locals of type Ref((ref null (module 5)))
  0x7aa | 20 01       | local_get local_index:1
  0x7ac | 41 f0 00    | i32_const value:112
  0x7af | 46          | i32_eq
  0x7b0 | 04 40       | if blockty:Empty
  0x7b2 | 20 00       | local_get local_index:0
  0x7b4 | 20 00       | local_get local_index:0
  0x7b6 | fb 02 08 0a | struct_get struct_type_index:8 field_index:10
  0x7ba | d4          | ref_as_non_null
  0x7bb | 10 0a       | call function_index:10
  0x7bd | 41 00       | i32_const value:0
  0x7bf | 0f          | return
  0x7c0 | 0b          | end
  0x7c1 | 20 01       | local_get local_index:1
  0x7c3 | 41 b8 01    | i32_const value:184
  0x7c6 | 46          | i32_eq
  0x7c7 | 04 40       | if blockty:Empty
  0x7c9 | 20 00       | local_get local_index:0
  0x7cb | 10 0b       | call function_index:11
  0x7cd | 22 04       | local_tee local_index:4
  0x7cf | d1          | ref_is_null
  0x7d0 | 04 40       | if blockty:Empty
  0x7d2 | 41 00       | i32_const value:0
  0x7d4 | 0f          | return
  0x7d5 | 0b          | end
  0x7d6 | 20 00       | local_get local_index:0
  0x7d8 | 10 0b       | call function_index:11
  0x7da | 22 03       | local_tee local_index:3
  0x7dc | d1          | ref_is_null
  0x7dd | 04 40       | if blockty:Empty
  0x7df | 20 00       | local_get local_index:0
  0x7e1 | 20 04       | local_get local_index:4
  0x7e3 | d4          | ref_as_non_null
  0x7e4 | 10 0a       | call function_index:10
  0x7e6 | 41 00       | i32_const value:0
  0x7e8 | 0f          | return
  0x7e9 | 0b          | end
  0x7ea | 20 03       | local_get local_index:3
  0x7ec | 10 13       | call function_index:19
  0x7ee | 21 05       | local_set local_index:5
  0x7f0 | 20 04       | local_get local_index:4
  0x7f2 | 10 13       | call function_index:19
  0x7f4 | 21 06       | local_set local_index:6
  0x7f6 | 20 05       | local_get local_index:5
  0x7f8 | 20 06       | local_get local_index:6
  0x7fa | 6c          | i32_mul
  0x7fb | 21 07       | local_set local_index:7
  0x7fd | 20 07       | local_get local_index:7
  0x7ff | 20 00       | local_get local_index:0
  0x801 | 20 07       | local_get local_index:7
  0x803 | 10 12       | call function_index:18
  0x805 | d4          | ref_as_non_null
  0x806 | 10 0a       | call function_index:10
  0x808 | 41 00       | i32_const value:0
  0x80a | 0f          | return
  0x80b | 0b          | end
  0x80c | 20 01       | local_get local_index:1
  0x80e | 41 fc 00    | i32_const value:124
  0x811 | 46          | i32_eq
  0x812 | 04 40       | if blockty:Empty
  0x814 | 41 01       | i32_const value:1
  0x816 | 0f          | return
  0x817 | 0b          | end
  0x818 | 20 01       | local_get local_index:1
  0x81a | 41 d0 01    | i32_const value:208
  0x81d | 46          | i32_eq
  0x81e | 04 40       | if blockty:Empty
  0x820 | 20 00       | local_get local_index:0
  0x822 | 10 0b       | call function_index:11
  0x824 | 22 02       | local_tee local_index:2
  0x826 | d1          | ref_is_null
  0x827 | 04 40       | if blockty:Empty
  0x829 | 41 00       | i32_const value:0
  0x82b | 0f          | return
  0x82c | 0b          | end
  0x82d | 20 00       | local_get local_index:0
  0x82f | fb 02 08 09 | struct_get struct_type_index:8 field_index:9
  0x833 | d4          | ref_as_non_null
  0x834 | fb 02 07 07 | struct_get struct_type_index:7 field_index:7
  0x838 | d4          | ref_as_non_null
  0x839 | 20 00       | local_get local_index:0
  0x83b | fb 02 08 07 | struct_get struct_type_index:8 field_index:7
  0x83f | 41 01       | i32_const value:1
  0x841 | 6a          | i32_add
  0x842 | fb 0d 01    | array_get_u array_type_index:1
  0x845 | 22 05       | local_tee local_index:5
  0x847 | 20 00       | local_get local_index:0
  0x849 | fb 02 08 09 | struct_get struct_type_index:8 field_index:9
  0x84d | d4          | ref_as_non_null
  0x84e | fb 02 07 05 | struct_get struct_type_index:7 field_index:5
  0x852 | d4          | ref_as_non_null
  0x853 | 20 05       | local_get local_index:5
  0x855 | fb 0b 00    | array_get array_type_index:0
  0x858 | 21 09       | local_set local_index:9
  0x85a | 20 00       | local_get local_index:0
  0x85c | 20 00       | local_get local_index:0
  0x85e | fb 02 08 07 | struct_get struct_type_index:8 field_index:7
  0x862 | 41 01       | i32_const value:1
  0x864 | 6a          | i32_add
  0x865 | fb 05 08 07 | struct_set struct_type_index:8 field_index:7
  0x869 | 20 02       | local_get local_index:2
  0x86b | 10 0d       | call function_index:13
  0x86d | 21 0b       | local_set local_index:11
  0x86f | 20 09       | local_get local_index:9
  0x871 | 20 0b       | local_get local_index:11
  0x873 | 10 0f       | call function_index:15
  0x875 | 22 0a       | local_tee local_index:10
  0x877 | d1          | ref_is_null
  0x878 | 04 40       | if blockty:Empty
  0x87a | 20 02       | local_get local_index:2
  0x87c | 20 09       | local_get local_index:9
  0x87e | 10 0e       | call function_index:14
  0x880 | 22 0a       | local_tee local_index:10
  0x882 | d1          | ref_is_null
  0x883 | 04 40       | if blockty:Empty
  0x885 | 20 00       | local_get local_index:0
  0x887 | 20 02       | local_get local_index:2
  0x889 | d4          | ref_as_non_null
  0x88a | 10 0a       | call function_index:10
  0x88c | 41 00       | i32_const value:0
  0x88e | 0f          | return
  0x88f | 0b          | end
  0x890 | 20 09       | local_get local_index:9
  0x892 | 20 0b       | local_get local_index:11
  0x894 | 20 0a       | local_get local_index:10
  0x896 | d4          | ref_as_non_null
  0x897 | 10 10       | call function_index:16
  0x899 | 0b          | end
  0x89a | 20 02       | local_get local_index:2
  0x89c | 20 0a       | local_get local_index:10
  0x89e | d4          | ref_as_non_null
  0x89f | 20 09       | local_get local_index:9
  0x8a1 | 10 11       | call function_index:17
  0x8a3 | 21 08       | local_set local_index:8
  0x8a5 | 20 08       | local_get local_index:8
  0x8a7 | 24 0a       | global_set global_index:10
  0x8a9 | 41 00       | i32_const value:0
  0x8ab | 0f          | return
  0x8ac | 0b          | end
  0x8ad | 41 00       | i32_const value:0
  0x8af | 0b          | end
============== func 27 ====================
  0x8b0 | f9 01       | size of function
  0x8b2 | 07          | 7 local blocks
  0x8b3 | 01 63 08    | 1 locals of type Ref((ref null (module 8)))
  0x8b6 | 01 63 07    | 1 locals of type Ref((ref null (module 7)))
  0x8b9 | 02 7f       | 2 locals of type I32
  0x8bb | 01 6d       | 1 locals of type Ref(eqref)
  0x8bd | 01 7f       | 1 locals of type I32
  0x8bf | 01 63 01    | 1 locals of type Ref((ref null (module 1)))
  0x8c2 | 03 7f       | 3 locals of type I32
  0x8c4 | 03 40       | loop blockty:Empty
  0x8c6 | 23 0a       | global_get global_index:10
  0x8c8 | 22 00       | local_tee local_index:0
  0x8ca | d1          | ref_is_null
  0x8cb | 04 40       | if blockty:Empty
  0x8cd | 0c 01       | br relative_depth:1
  0x8cf | 0b          | end
  0x8d0 | 20 00       | local_get local_index:0
  0x8d2 | d4          | ref_as_non_null
  0x8d3 | fb 02 08 09 | struct_get struct_type_index:8 field_index:9
  0x8d7 | 22 01       | local_tee local_index:1
  0x8d9 | d1          | ref_is_null
  0x8da | 04 40       | if blockty:Empty
  0x8dc | 0c 01       | br relative_depth:1
  0x8de | 0b          | end
  0x8df | 20 01       | local_get local_index:1
  0x8e1 | d4          | ref_as_non_null
  0x8e2 | 22 01       | local_tee local_index:1
  0x8e4 | 20 01       | local_get local_index:1
  0x8e6 | fb 02 07 08 | struct_get struct_type_index:7 field_index:8
  0x8ea | 41 01       | i32_const value:1
  0x8ec | 6a          | i32_add
  0x8ed | 22 05       | local_tee local_index:5
  0x8ef | 20 01       | local_get local_index:1
  0x8f1 | 20 05       | local_get local_index:5
  0x8f3 | fb 05 07 08 | struct_set struct_type_index:7 field_index:8
  0x8f7 | 20 05       | local_get local_index:5
  0x8f9 | 23 0f       | global_get global_index:15
  0x8fb | 46          | i32_eq
  0x8fc | 23 10       | global_get global_index:16
  0x8fe | 71          | i32_and
  0x8ff | 04 40       | if blockty:Empty
  0x901 | 20 01       | local_get local_index:1
  0x903 | 10 16       | call function_index:22
  0x905 | 0b          | end
  0x906 | 20 01       | local_get local_index:1
  0x908 | 10 14       | call function_index:20
  0x90a | 04 40       | if blockty:Empty
  0x90c | 20 01       | local_get local_index:1
  0x90e | fb 02 07 09 | struct_get struct_type_index:7 field_index:9
  0x912 | 21 09       | local_set local_index:9
  0x914 | 20 00       | local_get local_index:0
  0x916 | d4          | ref_as_non_null
  0x917 | 20 09       | local_get local_index:9
  0x919 | 10 15       | call function_index:21
  0x91b | 1a          | drop
  0x91c | 20 00       | local_get local_index:0
  0x91e | d4          | ref_as_non_null
  0x91f | 10 17       | call function_index:23
  0x921 | 21 04       | local_set local_index:4
  0x923 | 0c 01       | br relative_depth:1
  0x925 | 05          | else
  0x926 | 20 01       | local_get local_index:1
  0x928 | fb 02 07 07 | struct_get struct_type_index:7 field_index:7
  0x92c | 22 06       | local_tee local_index:6
  0x92e | d1          | ref_is_null
  0x92f | 04 40       | if blockty:Empty
  0x931 | 0c 02       | br relative_depth:2
  0x933 | 0b          | end
  0x934 | 20 06       | local_get local_index:6
  0x936 | d4          | ref_as_non_null
  0x937 | fb 0f       | array_len
  0x939 | 21 07       | local_set local_index:7
  0x93b | 03 40       | loop blockty:Empty
  0x93d | 20 00       | local_get local_index:0
  0x93f | d4          | ref_as_non_null
  0x940 | fb 02 08 07 | struct_get struct_type_index:8 field_index:7
  0x944 | 22 03       | local_tee local_index:3
  0x946 | 20 03       | local_get local_index:3
  0x948 | 20 07       | local_get local_index:7
  0x94a | 4f          | i32_ge_u
  0x94b | 04 40       | if blockty:Empty
  0x94d | 20 00       | local_get local_index:0
  0x94f | d4          | ref_as_non_null
  0x950 | 10 17       | call function_index:23
  0x952 | 21 04       | local_set local_index:4
  0x954 | 0c 01       | br relative_depth:1
  0x956 | 0b          | end
  0x957 | 20 06       | local_get local_index:6
  0x959 | d4          | ref_as_non_null
  0x95a | 20 03       | local_get local_index:3
  0x95c | fb 0d 01    | array_get_u array_type_index:1
  0x95f | 21 02       | local_set local_index:2
  0x961 | 20 00       | local_get local_index:0
  0x963 | d4          | ref_as_non_null
  0x964 | 20 02       | local_get local_index:2
  0x966 | 10 1a       | call function_index:26
  0x968 | 21 08       | local_set local_index:8
  0x96a | 20 08       | local_get local_index:8
  0x96c | 04 40       | if blockty:Empty
  0x96e | 20 00       | local_get local_index:0
  0x970 | d4          | ref_as_non_null
  0x971 | 10 17       | call function_index:23
  0x973 | 21 04       | local_set local_index:4
  0x975 | 0c 01       | br relative_depth:1
  0x977 | 0b          | end
  0x978 | 23 0a       | global_get global_index:10
  0x97a | 20 00       | local_get local_index:0
  0x97c | d3          | ref_eq
  0x97d | 04 40       | if blockty:Empty
  0x97f | 20 00       | local_get local_index:0
  0x981 | d4          | ref_as_non_null
  0x982 | 20 03       | local_get local_index:3
  0x984 | 41 01       | i32_const value:1
  0x986 | 6a          | i32_add
  0x987 | fb 05 08 07 | struct_set struct_type_index:8 field_index:7
  0x98b | 05          | else
  0x98c | 0c 01       | br relative_depth:1
  0x98e | 0b          | end
  0x98f | 0c 00       | br relative_depth:0
  0x991 | 0b          | end
  0x992 | 0b          | end
  0x993 | 23 0a       | global_get global_index:10
  0x995 | d1          | ref_is_null
  0x996 | 04 40       | if blockty:Empty
  0x998 | 0c 01       | br relative_depth:1
  0x99a | 0b          | end
  0x99b | 0c 00       | br relative_depth:0
  0x99d | 0b          | end
  0x99e | 20 04       | local_get local_index:4
  0x9a0 | 10 13       | call function_index:19
  0x9a2 | 22 03       | local_tee local_index:3
  0x9a4 | 20 03       | local_get local_index:3
  0x9a6 | 10 00       | call function_index:0
  0x9a8 | 20 03       | local_get local_index:3
  0x9aa | 0b          | end
  0x9ab | 00 9a 0f    | custom section
  0x9ae | 04 6e 61 6d | name: "name"
        | 65         
  0x9b3 | 01 de 03    | function name section
  0x9b6 | 1c          | 28 count
  0x9b7 | 00 0c 72 65 | Naming { index: 0, name: "reportResult" }
        | 70 6f 72 74
        | 52 65 73 75
        | 6c 74      
  0x9c5 | 01 0d 63 6f | Naming { index: 1, name: "compileMethod" }
        | 6d 70 69 6c
        | 65 4d 65 74
        | 68 6f 64   
  0x9d4 | 02 08 64 65 | Naming { index: 2, name: "debugLog" }
        | 62 75 67 4c
        | 6f 67      
  0x9de | 03 0e 61 72 | Naming { index: 3, name: "array_len_byte" }
        | 72 61 79 5f
        | 6c 65 6e 5f
        | 62 79 74 65
  0x9ee | 04 0e 61 72 | Naming { index: 4, name: "array_get_byte" }
        | 72 61 79 5f
        | 67 65 74 5f
        | 62 79 74 65
  0x9fe | 05 10 61 72 | Naming { index: 5, name: "array_len_object" }
        | 72 61 79 5f
        | 6c 65 6e 5f
        | 6f 62 6a 65
        | 63 74      
  0xa10 | 06 10 61 72 | Naming { index: 6, name: "array_get_object" }
        | 72 61 79 5f
        | 67 65 74 5f
        | 6f 62 6a 65
        | 63 74      
  0xa22 | 07 10 69 73 | Naming { index: 7, name: "is_small_integer" }
        | 5f 73 6d 61
        | 6c 6c 5f 69
        | 6e 74 65 67
        | 65 72      
  0xa34 | 08 17 67 65 | Naming { index: 8, name: "get_small_integer_value" }
        | 74 5f 73 6d
        | 61 6c 6c 5f
        | 69 6e 74 65
        | 67 65 72 5f
        | 76 61 6c 75
        | 65         
  0xa4d | 09 10 6e 65 | Naming { index: 9, name: "nextIdentityHash" }
        | 78 74 49 64
        | 65 6e 74 69
        | 74 79 48 61
        | 73 68      
  0xa5f | 0a 0b 70 75 | Naming { index: 10, name: "pushOnStack" }
        | 73 68 4f 6e
        | 53 74 61 63
        | 6b         
  0xa6c | 0b 0c 70 6f | Naming { index: 11, name: "popFromStack" }
        | 70 46 72 6f
        | 6d 53 74 61
        | 63 6b      
  0xa7a | 0c 0a 74 6f | Naming { index: 12, name: "topOfStack" }
        | 70 4f 66 53
        | 74 61 63 6b
  0xa86 | 0d 08 67 65 | Naming { index: 13, name: "getClass" }
        | 74 43 6c 61
        | 73 73      
  0xa90 | 0e 0c 6c 6f | Naming { index: 14, name: "lookupMethod" }
        | 6f 6b 75 70
        | 4d 65 74 68
        | 6f 64      
  0xa9e | 0f 0d 6c 6f | Naming { index: 15, name: "lookupInCache" }
        | 6f 6b 75 70
        | 49 6e 43 61
        | 63 68 65   
  0xaad | 10 0c 73 74 | Naming { index: 16, name: "storeInCache" }
        | 6f 72 65 49
        | 6e 43 61 63
        | 68 65      
  0xabb | 11 13 63 72 | Naming { index: 17, name: "createMethodContext" }
        | 65 61 74 65
        | 4d 65 74 68
        | 6f 64 43 6f
        | 6e 74 65 78
        | 74         
  0xad0 | 12 12 63 72 | Naming { index: 18, name: "createSmallInteger" }
        | 65 61 74 65
        | 53 6d 61 6c
        | 6c 49 6e 74
        | 65 67 65 72
  0xae4 | 13 13 65 78 | Naming { index: 19, name: "extractIntegerValue" }
        | 74 72 61 63
        | 74 49 6e 74
        | 65 67 65 72
        | 56 61 6c 75
        | 65         
  0xaf9 | 14 13 68 61 | Naming { index: 20, name: "hasCompiledFunction" }
        | 73 43 6f 6d
        | 70 69 6c 65
        | 64 46 75 6e
        | 63 74 69 6f
        | 6e         
  0xb0e | 15 17 65 78 | Naming { index: 21, name: "executeCompiledFunction" }
        | 65 63 75 74
        | 65 43 6f 6d
        | 70 69 6c 65
        | 64 46 75 6e
        | 63 74 69 6f
        | 6e         
  0xb27 | 16 15 74 72 | Naming { index: 22, name: "triggerJITCompilation" }
        | 69 67 67 65
        | 72 4a 49 54
        | 43 6f 6d 70
        | 69 6c 61 74
        | 69 6f 6e   
  0xb3e | 17 12 68 61 | Naming { index: 23, name: "handleMethodReturn" }
        | 6e 64 6c 65
        | 4d 65 74 68
        | 6f 64 52 65
        | 74 75 72 6e
  0xb52 | 18 0a 69 6e | Naming { index: 24, name: "initialize" }
        | 69 74 69 61
        | 6c 69 7a 65
  0xb5e | 19 16 63 72 | Naming { index: 25, name: "createMinimalBootstrap" }
        | 65 61 74 65
        | 4d 69 6e 69
        | 6d 61 6c 42
        | 6f 6f 74 73
        | 74 72 61 70
  0xb76 | 1a 11 69 6e | Naming { index: 26, name: "interpretBytecode" }
        | 74 65 72 70
        | 72 65 74 42
        | 79 74 65 63
        | 6f 64 65   
  0xb89 | 1b 09 69 6e | Naming { index: 27, name: "interpret" }
        | 74 65 72 70
        | 72 65 74   
  0xb94 | 02 93 07    | local section
  0xb97 | 17          | 23 count
  0xb98 | 03          | function 3 local name section
  0xb99 | 01          | 1 count
  0xb9a | 00 05 61 72 | Naming { index: 0, name: "array" }
        | 72 61 79   
  0xba1 | 04          | function 4 local name section
  0xba2 | 02          | 2 count
  0xba3 | 00 05 61 72 | Naming { index: 0, name: "array" }
        | 72 61 79   
  0xbaa | 01 05 69 6e | Naming { index: 1, name: "index" }
        | 64 65 78   
  0xbb1 | 05          | function 5 local name section
  0xbb2 | 01          | 1 count
  0xbb3 | 00 05 61 72 | Naming { index: 0, name: "array" }
        | 72 61 79   
  0xbba | 06          | function 6 local name section
  0xbbb | 02          | 2 count
  0xbbc | 00 05 61 72 | Naming { index: 0, name: "array" }
        | 72 61 79   
  0xbc3 | 01 05 69 6e | Naming { index: 1, name: "index" }
        | 64 65 78   
  0xbca | 07          | function 7 local name section
  0xbcb | 01          | 1 count
  0xbcc | 00 03 6f 62 | Naming { index: 0, name: "obj" }
        | 6a         
  0xbd1 | 08          | function 8 local name section
  0xbd2 | 01          | 1 count
  0xbd3 | 00 03 6f 62 | Naming { index: 0, name: "obj" }
        | 6a         
  0xbd8 | 0a          | function 10 local name section
  0xbd9 | 04          | 4 count
  0xbda | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
  0xbe3 | 01 05 76 61 | Naming { index: 1, name: "value" }
        | 6c 75 65   
  0xbea | 02 05 73 74 | Naming { index: 2, name: "stack" }
        | 61 63 6b   
  0xbf1 | 03 02 73 70 | Naming { index: 3, name: "sp" }
  0xbf5 | 0b          | function 11 local name section
  0xbf6 | 03          | 3 count
  0xbf7 | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
  0xc00 | 01 05 73 74 | Naming { index: 1, name: "stack" }
        | 61 63 6b   
  0xc07 | 02 02 73 70 | Naming { index: 2, name: "sp" }
  0xc0b | 0c          | function 12 local name section
  0xc0c | 03          | 3 count
  0xc0d | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
  0xc16 | 01 05 73 74 | Naming { index: 1, name: "stack" }
        | 61 63 6b   
  0xc1d | 02 02 73 70 | Naming { index: 2, name: "sp" }
  0xc21 | 0d          | function 13 local name section
  0xc22 | 01          | 1 count
  0xc23 | 00 03 6f 62 | Naming { index: 0, name: "obj" }
        | 6a         
  0xc28 | 0e          | function 14 local name section
  0xc29 | 0a          | 10 count
  0xc2a | 00 08 72 65 | Naming { index: 0, name: "receiver" }
        | 63 65 69 76
        | 65 72      
  0xc34 | 01 08 73 65 | Naming { index: 1, name: "selector" }
        | 6c 65 63 74
        | 6f 72      
  0xc3e | 02 05 63 6c | Naming { index: 2, name: "class" }
        | 61 73 73   
  0xc45 | 03 0c 63 75 | Naming { index: 3, name: "currentClass" }
        | 72 72 65 6e
        | 74 43 6c 61
        | 73 73      
  0xc53 | 04 0a 6d 65 | Naming { index: 4, name: "methodDict" }
        | 74 68 6f 64
        | 44 69 63 74
  0xc5f | 05 04 6b 65 | Naming { index: 5, name: "keys" }
        | 79 73      
  0xc65 | 06 06 76 61 | Naming { index: 6, name: "values" }
        | 6c 75 65 73
  0xc6d | 07 05 63 6f | Naming { index: 7, name: "count" }
        | 75 6e 74   
  0xc74 | 08 01 69    | Naming { index: 8, name: "i" }
  0xc77 | 09 03 6b 65 | Naming { index: 9, name: "key" }
        | 79         
  0xc7c | 0f          | function 15 local name section
  0xc7d | 08          | 8 count
  0xc7e | 00 08 73 65 | Naming { index: 0, name: "selector" }
        | 6c 65 63 74
        | 6f 72      
  0xc88 | 01 0d 72 65 | Naming { index: 1, name: "receiverClass" }
        | 63 65 69 76
        | 65 72 43 6c
        | 61 73 73   
  0xc97 | 02 05 63 61 | Naming { index: 2, name: "cache" }
        | 63 68 65   
  0xc9e | 03 09 63 61 | Naming { index: 3, name: "cacheSize" }
        | 63 68 65 53
        | 69 7a 65   
  0xca9 | 04 04 68 61 | Naming { index: 4, name: "hash" }
        | 73 68      
  0xcaf | 05 05 69 6e | Naming { index: 5, name: "index" }
        | 64 65 78   
  0xcb6 | 06 05 65 6e | Naming { index: 6, name: "entry" }
        | 74 72 79   
  0xcbd | 07 0a 70 72 | Naming { index: 7, name: "probeLimit" }
        | 6f 62 65 4c
        | 69 6d 69 74
  0xcc9 | 10          | function 16 local name section
  0xcca | 06          | 6 count
  0xccb | 00 08 73 65 | Naming { index: 0, name: "selector" }
        | 6c 65 63 74
        | 6f 72      
  0xcd5 | 01 0d 72 65 | Naming { index: 1, name: "receiverClass" }
        | 63 65 69 76
        | 65 72 43 6c
        | 61 73 73   
  0xce4 | 02 06 6d 65 | Naming { index: 2, name: "method" }
        | 74 68 6f 64
  0xcec | 03 05 63 61 | Naming { index: 3, name: "cache" }
        | 63 68 65   
  0xcf3 | 04 05 69 6e | Naming { index: 4, name: "index" }
        | 64 65 78   
  0xcfa | 05 05 65 6e | Naming { index: 5, name: "entry" }
        | 74 72 79   
  0xd01 | 11          | function 17 local name section
  0xd02 | 04          | 4 count
  0xd03 | 00 08 72 65 | Naming { index: 0, name: "receiver" }
        | 63 65 69 76
        | 65 72      
  0xd0d | 01 06 6d 65 | Naming { index: 1, name: "method" }
        | 74 68 6f 64
  0xd15 | 02 08 73 65 | Naming { index: 2, name: "selector" }
        | 6c 65 63 74
        | 6f 72      
  0xd1f | 03 05 73 74 | Naming { index: 3, name: "stack" }
        | 61 63 6b   
  0xd26 | 12          | function 18 local name section
  0xd27 | 01          | 1 count
  0xd28 | 00 05 76 61 | Naming { index: 0, name: "value" }
        | 6c 75 65   
  0xd2f | 13          | function 19 local name section
  0xd30 | 01          | 1 count
  0xd31 | 00 03 6f 62 | Naming { index: 0, name: "obj" }
        | 6a         
  0xd36 | 14          | function 20 local name section
  0xd37 | 01          | 1 count
  0xd38 | 00 06 6d 65 | Naming { index: 0, name: "method" }
        | 74 68 6f 64
  0xd40 | 15          | function 21 local name section
  0xd41 | 02          | 2 count
  0xd42 | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
  0xd4b | 01 09 66 75 | Naming { index: 1, name: "funcIndex" }
        | 6e 63 49 6e
        | 64 65 78   
  0xd56 | 16          | function 22 local name section
  0xd57 | 04          | 4 count
  0xd58 | 00 06 6d 65 | Naming { index: 0, name: "method" }
        | 74 68 6f 64
  0xd60 | 01 09 62 79 | Naming { index: 1, name: "bytecodes" }
        | 74 65 63 6f
        | 64 65 73   
  0xd6b | 02 0b 62 79 | Naming { index: 2, name: "bytecodeLen" }
        | 74 65 63 6f
        | 64 65 4c 65
        | 6e         
  0xd78 | 03 11 63 6f | Naming { index: 3, name: "compiledFuncIndex" }
        | 6d 70 69 6c
        | 65 64 46 75
        | 6e 63 49 6e
        | 64 65 78   
  0xd8b | 17          | function 23 local name section
  0xd8c | 03          | 3 count
  0xd8d | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
  0xd96 | 01 06 73 65 | Naming { index: 1, name: "sender" }
        | 6e 64 65 72
  0xd9e | 02 06 72 65 | Naming { index: 2, name: "result" }
        | 73 75 6c 74
  0xda6 | 19          | function 25 local name section
  0xda7 | 0c          | 12 count
  0xda8 | 00 0a 6d 61 | Naming { index: 0, name: "mainMethod" }
        | 69 6e 4d 65
        | 74 68 6f 64
  0xdb4 | 01 0d 73 71 | Naming { index: 1, name: "squaredMethod" }
        | 75 61 72 65
        | 64 4d 65 74
        | 68 6f 64   
  0xdc3 | 02 0b 6d 61 | Naming { index: 2, name: "mainContext" }
        | 69 6e 43 6f
        | 6e 74 65 78
        | 74         
  0xdd0 | 03 0d 6d 61 | Naming { index: 3, name: "mainBytecodes" }
        | 69 6e 42 79
        | 74 65 63 6f
        | 64 65 73   
  0xddf | 04 10 73 71 | Naming { index: 4, name: "squaredBytecodes" }
        | 75 61 72 65
        | 64 42 79 74
        | 65 63 6f 64
        | 65 73      
  0xdf1 | 05 05 73 74 | Naming { index: 5, name: "stack" }
        | 61 63 6b   
  0xdf8 | 06 08 72 65 | Naming { index: 6, name: "receiver" }
        | 63 65 69 76
        | 65 72      
  0xe02 | 07 0b 6f 62 | Naming { index: 7, name: "objectClass" }
        | 6a 65 63 74
        | 43 6c 61 73
        | 73         
  0xe0f | 08 0a 63 6c | Naming { index: 8, name: "classClass" }
        | 61 73 73 43
        | 6c 61 73 73
  0xe1b | 09 0d 73 6d | Naming { index: 9, name: "smallIntClass" }
        | 61 6c 6c 49
        | 6e 74 43 6c
        | 61 73 73   
  0xe2a | 0a 0a 6d 65 | Naming { index: 10, name: "methodDict" }
        | 74 68 6f 64
        | 44 69 63 74
  0xe36 | 0b 0f 73 71 | Naming { index: 11, name: "squaredSelector" }
        | 75 61 72 65
        | 64 53 65 6c
        | 65 63 74 6f
        | 72         
  0xe47 | 1a          | function 26 local name section
  0xe48 | 0c          | 12 count
  0xe49 | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
  0xe52 | 01 08 62 79 | Naming { index: 1, name: "bytecode" }
        | 74 65 63 6f
        | 64 65      
  0xe5c | 02 08 72 65 | Naming { index: 2, name: "receiver" }
        | 63 65 69 76
        | 65 72      
  0xe66 | 03 06 76 61 | Naming { index: 3, name: "value1" }
        | 6c 75 65 31
  0xe6e | 04 06 76 61 | Naming { index: 4, name: "value2" }
        | 6c 75 65 32
  0xe76 | 05 04 69 6e | Naming { index: 5, name: "int1" }
        | 74 31      
  0xe7c | 06 04 69 6e | Naming { index: 6, name: "int2" }
        | 74 32      
  0xe82 | 07 06 72 65 | Naming { index: 7, name: "result" }
        | 73 75 6c 74
  0xe8a | 08 0a 6e 65 | Naming { index: 8, name: "newContext" }
        | 77 43 6f 6e
        | 74 65 78 74
  0xe96 | 09 08 73 65 | Naming { index: 9, name: "selector" }
        | 6c 65 63 74
        | 6f 72      
  0xea0 | 0a 06 6d 65 | Naming { index: 10, name: "method" }
        | 74 68 6f 64
  0xea8 | 0b 0d 72 65 | Naming { index: 11, name: "receiverClass" }
        | 63 65 69 76
        | 65 72 43 6c
        | 61 73 73   
  0xeb7 | 1b          | function 27 local name section
  0xeb8 | 0a          | 10 count
  0xeb9 | 00 07 63 6f | Naming { index: 0, name: "context" }
        | 6e 74 65 78
        | 74         
  0xec2 | 01 06 6d 65 | Naming { index: 1, name: "method" }
        | 74 68 6f 64
  0xeca | 02 08 62 79 | Naming { index: 2, name: "bytecode" }
        | 74 65 63 6f
        | 64 65      
  0xed4 | 03 02 70 63 | Naming { index: 3, name: "pc" }
  0xed8 | 04 0b 72 65 | Naming { index: 4, name: "resultValue" }
        | 73 75 6c 74
        | 56 61 6c 75
        | 65         
  0xee5 | 05 0f 69 6e | Naming { index: 5, name: "invocationCount" }
        | 76 6f 63 61
        | 74 69 6f 6e
        | 43 6f 75 6e
        | 74         
  0xef6 | 06 09 62 79 | Naming { index: 6, name: "bytecodes" }
        | 74 65 63 6f
        | 64 65 73   
  0xf01 | 07 0e 62 79 | Naming { index: 7, name: "bytecodeLength" }
        | 74 65 63 6f
        | 64 65 4c 65
        | 6e 67 74 68
  0xf11 | 08 0c 73 68 | Naming { index: 8, name: "shouldReturn" }
        | 6f 75 6c 64
        | 52 65 74 75
        | 72 6e      
  0xf1f | 09 09 66 75 | Naming { index: 9, name: "funcIndex" }
        | 6e 63 49 6e
        | 64 65 78   
  0xf2a | 03 52       | label section
  0xf2c | 03          | 3 count
  0xf2d | 0e          | function 14 label name section
  0xf2e | 02          | 2 count
  0xf2f | 00 0e 68 69 | Naming { index: 0, name: "hierarchy_loop" }
        | 65 72 61 72
        | 63 68 79 5f
        | 6c 6f 6f 70
  0xf3f | 05 0b 73 65 | Naming { index: 5, name: "search_loop" }
        | 61 72 63 68
        | 5f 6c 6f 6f
        | 70         
  0xf4c | 0f          | function 15 label name section
  0xf4d | 01          | 1 count
  0xf4e | 01 0a 70 72 | Naming { index: 1, name: "probe_loop" }
        | 6f 62 65 5f
        | 6c 6f 6f 70
  0xf5a | 1b          | function 27 label name section
  0xf5b | 02          | 2 count
  0xf5c | 00 0e 65 78 | Naming { index: 0, name: "execution_loop" }
        | 65 63 75 74
        | 69 6f 6e 5f
        | 6c 6f 6f 70
  0xf6c | 06 10 69 6e | Naming { index: 6, name: "interpreter_loop" }
        | 74 65 72 70
        | 72 65 74 65
        | 72 5f 6c 6f
        | 6f 70      
  0xf7e | 04 75       | type name section
  0xf80 | 0a          | 10 count
  0xf81 | 00 0b 4f 62 | Naming { index: 0, name: "ObjectArray" }
        | 6a 65 63 74
        | 41 72 72 61
        | 79         
  0xf8e | 01 09 42 79 | Naming { index: 1, name: "ByteArray" }
        | 74 65 41 72
        | 72 61 79   
  0xf99 | 02 0c 53 71 | Naming { index: 2, name: "SqueakObject" }
        | 75 65 61 6b
        | 4f 62 6a 65
        | 63 74      
  0xfa7 | 03 0e 56 61 | Naming { index: 3, name: "VariableObject" }
        | 72 69 61 62
        | 6c 65 4f 62
        | 6a 65 63 74
  0xfb7 | 04 06 53 79 | Naming { index: 4, name: "Symbol" }
        | 6d 62 6f 6c
  0xfbf | 05 05 43 6c | Naming { index: 5, name: "Class" }
        | 61 73 73   
  0xfc6 | 06 0a 44 69 | Naming { index: 6, name: "Dictionary" }
        | 63 74 69 6f
        | 6e 61 72 79
  0xfd2 | 07 0e 43 6f | Naming { index: 7, name: "CompiledMethod" }
        | 6d 70 69 6c
        | 65 64 4d 65
        | 74 68 6f 64
  0xfe2 | 08 07 43 6f | Naming { index: 8, name: "Context" }
        | 6e 74 65 78
        | 74         
  0xfeb | 09 08 50 49 | Naming { index: 9, name: "PICEntry" }
        | 43 45 6e 74
        | 72 79      
  0xff5 | 05 0c       | table name section
  0xff7 | 01          | 1 count
  0xff8 | 00 09 66 75 | Naming { index: 0, name: "funcTable" }
        | 6e 63 54 61
        | 62 6c 65   
 0x1003 | 07 c2 02    | global name section
 0x1006 | 16          | 22 count
 0x1007 | 00 0b 6f 62 | Naming { index: 0, name: "objectClass" }
        | 6a 65 63 74
        | 43 6c 61 73
        | 73         
 0x1014 | 01 0a 63 6c | Naming { index: 1, name: "classClass" }
        | 61 73 73 43
        | 6c 61 73 73
 0x1020 | 02 0b 6d 65 | Naming { index: 2, name: "methodClass" }
        | 74 68 6f 64
        | 43 6c 61 73
        | 73         
 0x102d | 03 0c 63 6f | Naming { index: 3, name: "contextClass" }
        | 6e 74 65 78
        | 74 43 6c 61
        | 73 73      
 0x103b | 04 0b 73 79 | Naming { index: 4, name: "symbolClass" }
        | 6d 62 6f 6c
        | 43 6c 61 73
        | 73         
 0x1048 | 05 11 73 6d | Naming { index: 5, name: "smallIntegerClass" }
        | 61 6c 6c 49
        | 6e 74 65 67
        | 65 72 43 6c
        | 61 73 73   
 0x105b | 06 09 6e 69 | Naming { index: 6, name: "nilObject" }
        | 6c 4f 62 6a
        | 65 63 74   
 0x1066 | 07 0a 74 72 | Naming { index: 7, name: "trueObject" }
        | 75 65 4f 62
        | 6a 65 63 74
 0x1072 | 08 0b 66 61 | Naming { index: 8, name: "falseObject" }
        | 6c 73 65 4f
        | 62 6a 65 63
        | 74         
 0x107f | 09 0f 73 71 | Naming { index: 9, name: "squaredSelector" }
        | 75 61 72 65
        | 64 53 65 6c
        | 65 63 74 6f
        | 72         
 0x1090 | 0a 0d 61 63 | Naming { index: 10, name: "activeContext" }
        | 74 69 76 65
        | 43 6f 6e 74
        | 65 78 74   
 0x109f | 0b 10 6e 65 | Naming { index: 11, name: "nextIdentityHash" }
        | 78 74 49 64
        | 65 6e 74 69
        | 74 79 48 61
        | 73 68      
 0x10b1 | 0c 0b 66 69 | Naming { index: 12, name: "firstObject" }
        | 72 73 74 4f
        | 62 6a 65 63
        | 74         
 0x10be | 0d 0a 6c 61 | Naming { index: 13, name: "lastObject" }
        | 73 74 4f 62
        | 6a 65 63 74
 0x10ca | 0e 0b 6f 62 | Naming { index: 14, name: "objectCount" }
        | 6a 65 63 74
        | 43 6f 75 6e
        | 74         
 0x10d7 | 0f 0c 6a 69 | Naming { index: 15, name: "jitThreshold" }
        | 74 54 68 72
        | 65 73 68 6f
        | 6c 64      
 0x10e5 | 10 0a 6a 69 | Naming { index: 16, name: "jitEnabled" }
        | 74 45 6e 61
        | 62 6c 65 64
 0x10f1 | 11 11 74 6f | Naming { index: 17, name: "totalCompilations" }
        | 74 61 6c 43
        | 6f 6d 70 69
        | 6c 61 74 69
        | 6f 6e 73   
 0x1104 | 12 0f 6d 65 | Naming { index: 18, name: "methodCacheSize" }
        | 74 68 6f 64
        | 43 61 63 68
        | 65 53 69 7a
        | 65         
 0x1115 | 13 0b 6d 65 | Naming { index: 19, name: "methodCache" }
        | 74 68 6f 64
        | 43 61 63 68
        | 65         
 0x1122 | 14 11 63 6f | Naming { index: 20, name: "compiledFunctions" }
        | 6d 70 69 6c
        | 65 64 46 75
        | 6e 63 74 69
        | 6f 6e 73   
 0x1135 | 15 11 6e 65 | Naming { index: 21, name: "nextFunctionIndex" }
        | 78 74 46 75
        | 6e 63 74 69
        | 6f 6e 49 6e
        | 64 65 78   
