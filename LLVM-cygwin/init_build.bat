set LLVM_ROOT=%1
set OBJ_ROOT=%LLVM_ROOT%/build

cd %OBJ_ROOT%
make clean
make -j2 all
make install
