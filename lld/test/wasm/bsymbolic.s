// RUN: llvm-mc -filetype=obj -triple=wasm32-unknown-unknown %s -o %t.o
// RUN: wasm-ld --no-entry -Bsymbolic %t.o -o %t2.so 2>&1 | FileCheck -check-prefix=WARNING %s
// WARNING: warning: -Bsymbolic is only meaningful when combined with -shared

// RUN: wasm-ld --experimental-pic -shared %t.o -o %t0.so
// RUN: obj2yaml %t0.so | FileCheck -check-prefix=NOOPTION %s

// RUN: wasm-ld --experimental-pic -shared -Bsymbolic %t.o -o %t1.so
// RUN: obj2yaml %t1.so | FileCheck -check-prefix=SYMBOLIC %s

// NOOPTION  - Type:            IMPORT
// NOOPTION:            - Module:          GOT.func
// NOOPTION-NEXT:         Field:           foo
// NOOPTION-NEXT:         Kind:            GLOBAL
// NOOPTION-NEXT:         GlobalType:      I32
// NOOPTION-NEXT:         GlobalMutable:   true
// NOOPTION-NEXT:       - Module:          GOT.mem
// NOOPTION-NEXT:         Field:           bar
// NOOPTION-NEXT:         Kind:            GLOBAL
// NOOPTION-NEXT:         GlobalType:      I32
// NOOPTION-NEXT:         GlobalMutable:   true

//      NOOPTION:  - Type:            GLOBAL
// NOOPTION-NEXT:    Globals:
// NOOPTION-NEXT:      - Index:           4
// NOOPTION-NEXT:        Type:            I32
// NOOPTION-NEXT:        Mutable:         false
// NOOPTION-NEXT:        InitExpr:
// NOOPTION-NEXT:          Opcode:          I32_CONST
// NOOPTION-NEXT:          Value:           0
// NOOPTION-NEXT:  - Type:            EXPORT

// SYMBOLIC-NOT:   - Module:          GOT.mem
// SYMBOLIC-NOT:   - Module:          GOT.func

// SYMBOLIC:       - Type:            GLOBAL
// SYMBOLIC-NEXT:    Globals:
// SYMBOLIC-NEXT:      - Index:           2
// SYMBOLIC-NEXT:        Type:            I32
// SYMBOLIC-NEXT:        Mutable:         true
// SYMBOLIC-NEXT:        InitExpr:
// SYMBOLIC-NEXT:          Opcode:          I32_CONST
// SYMBOLIC-NEXT:          Value:           0
// SYMBOLIC-NEXT:      - Index:           3
// SYMBOLIC-NEXT:        Type:            I32
// SYMBOLIC-NEXT:        Mutable:         true
// SYMBOLIC-NEXT:        InitExpr:
// SYMBOLIC-NEXT:          Opcode:          I32_CONST
// SYMBOLIC-NEXT:          Value:           0
// SYMBOLIC-NEXT:      - Index:           4
// SYMBOLIC-NEXT:        Type:            I32
// SYMBOLIC-NEXT:        Mutable:         false
// SYMBOLIC-NEXT:        InitExpr:
// SYMBOLIC-NEXT:          Opcode:          I32_CONST
// SYMBOLIC-NEXT:          Value:           0
// SYMBOLIC-NEXT:  - Type:            EXPORT

.globl foo
foo:
  .functype foo () -> ()
  end_function

.globl get_foo_address
get_foo_address:
  .functype get_foo_address () -> (i32)
  global.get foo@GOT
  end_function

.globl get_bar_address
get_bar_address:
  .functype get_bar_address () -> (i32)
  global.get bar@GOT
  end_function

.globl bar
.section  .data.bar,"",@
bar:
  .int 42
.size bar, 4
