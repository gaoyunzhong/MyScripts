#!/bin/bash

LLVM_ROOT=$1
INSTALL_ROOT=$1/install/bin
FRONT_END_ROOT=$1/llvm-gcc/bin
FRONT_END_COLLECT2_PATH=$1/llvm-gcc/libexec/gcc/i386-mingw32/4.2.1
PATH=$PATH:$INSTALL/bin:$INSTALL_ROOT:$FRONT_END_ROOT:$FRONT_END_COLLECT2_PATH

cat > hello.c << EOF
#include <stdio.h>
int main()
{
    printf("hello\n");
    return 0;
}
EOF

llvm-gcc hello.c -o hello
echo "llvm-gcc emits:"
./hello

llvm-gcc -O3 -emit-llvm hello.c -c -o hello.bc
echo "lli emits"
lli hello.bc

llc hello.bc -o hello.s
gcc hello.s -o hello.native
echo "llc emits"
./hello.native

rm -f hello.c hello hello.bc hello.s hello.native
