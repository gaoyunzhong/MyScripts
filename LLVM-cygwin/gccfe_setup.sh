#!/bin/bash

LLVM_ROOT=$1

function do_clean_all {
    local OBJ_ROOT=$LLVM_ROOT/build

    cd LLVM_ROOT
    rm -rf build install llvm llvm-gcc
    cd $OBJ_ROOT
    make clean
}

function do_init_checkout {
    cd $LLVM_ROOT
    mv llvm-gcc llvm-gcc_backup
    svn co http://llvm.org/svn/llvm-project/llvm-gcc-4.2/trunk llvm-gcc
}

function do_update_all {
    cd $LLVM_ROOT
    svn update llvm-gcc
}

function remove_carriage {
    sed 's/\r\n/\n/' $1 > temp
    mv temp $1
}

function remove_carriage_config {
    remove_carriage $1/configure
    chmod u+x $1/configure
    for CONFIG_FILE in $1/config.sub $1/config.guess
    do
        remove_carriage $CONFIG_FILE
    done
}

function remove_carriage_all {
    remove_carriage_config $1
    for CONFIG_FILE in $1/install-sh $1/mkinstalldirs
    do
        remove_carriage $CONFIG_FILE
        chmod u+x $CONFIG_FILE
    done
}

function do_remove_carriage {
    local SRC_ROOT=$LLVM_ROOT/llvm-gcc

    remove_carriage_all $SRC_ROOT
}

function do_configure {
    local SRC_ROOT=$LLVM_ROOT/llvm-gcc
    local OBJ_ROOT=$LLVM_ROOT/build
    local INSTALL_DIR=$LLVM_ROOT/install

    mkdir -p $OBJ_ROOT
    cd $OBJ_ROOT
    $SRC_ROOT/configure --prefix=$INSTALL_DIR --program-prefix=llvm- \
        --enable-llvm=$LLVM_ROOT\build --enable-languages=c,c++ \
        --enable-checking --target=i686-pc-cygwin --with-tune=generic \
        --with-arch=pentium4 
}

function do_build {
    local OBJ_ROOT=$LLVM_ROOT/build

    cd $OBJ_ROOT
    # parallel build
    make -j2 all
    make install
}

#init_checkout
do_update_all
#do_remove_carriage
do_configure
do_build
