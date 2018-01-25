# REQUIRES: x86
# RUN: llvm-mc -filetype=obj -triple=x86_64-pc-linux %s -o %t.o
# RUN: echo "MEMORY {                                  \
# RUN:   FOO   (ax) : ORIGIN = 0x1000, LENGTH = 0x100  \
# RUN:   BAR   (ax) : ORIGIN = 0x2000, LENGTH = 0x100  \
# RUN:   ZED   (ax) : ORIGIN = 0x3000, LENGTH = 0x100  \
# RUN:   FLASH (ax) : ORIGIN = 0x6000, LENGTH = 0x200  \
# RUN: }                                               \
# RUN: SECTIONS {                                      \
# RUN:  .foo1 : { *(.foo1) }            > FOO AT>FLASH \
# RUN:  .foo2 : { *(.foo2) BYTE(0x42) } > BAR AT>FLASH \
# RUN:  .foo3 : { *(.foo3) }            > ZED AT>FLASH \
# RUN: }" > %t.script
# RUN: ld.lld %t.o --script %t.script -o %t
# RUN: llvm-readelf -sections -program-headers %t | FileCheck %s

# CHECK: .foo1             PROGBITS        0000000000001000 001000
# CHECK: .foo2             PROGBITS        0000000000002000 002000
# CHECK: .foo3             PROGBITS        0000000000003000 003000

# CHECK: Program Headers:
# CHECK-NOT: LOAD

# CHECK:      Type  Offset   VirtAddr           PhysAddr
# CHECK-NEXT: LOAD  0x001000 0x0000000000001000 0x0000000000006000
# CHECK-NEXT: LOAD  0x002000 0x0000000000002000 0x0000000000006008
# CHECK-NEXT: LOAD  0x003000 0x0000000000003000 0x0000000000006011

# CHECK-NOT: LOAD

.section .foo1, "a"
.quad 0

.section .foo2, "ax"
.quad 0

.section .foo3, "ax"
.quad 0
