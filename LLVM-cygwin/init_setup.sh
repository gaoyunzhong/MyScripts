#!/bin/bash

LLVM_ROOT=$1

function do_clean_all {
    local OBJ_ROOT=$LLVM_ROOT/build

    cd $LLVM_ROOT
    rm -rf build install llvm llvm-gcc
    cd $OBJ_ROOT
    make clean
}

function do_init_checkout {
## subversion checkout of LLVM suite, test suite;
## extraction of LLVMGCC front end from (separately) downloaded package;

    cd $LLVM_ROOT
    svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm
    cd $LLVM_ROOT/llvm/projects
    svn co http://llvm.org/svn/llvm-project/test-suite/trunk test-suite
    cd $LLVM_ROOT
    tar jxf llvm-gcc4.2-2.9-x86-mingw32.tar.bz2
    mv llvm-gcc4.2-2.9-x86-mingw32 llvm-gcc
}

function do_update_all {
    cd $LLVM_ROOT
    svn update llvm
    cd $LLVM_ROOT/llvm/projects
    svn update test-suite
    cd $LLVM_ROOT
    svn co http://llvm.org/svn/llvm-project/llvm-gcc-4.2/trunk llvm-gcc
}

function remove_carriage {
    sed 's/\r\n/\n/' $1 > temp
    mv temp $1
}

function remove_carriage_config {
    remove_carriage $1/configure
    chmod u+x $1/configure
    for CONFIG_FILE in $1/autoconf/config.sub $1/autoconf/config.guess
    do
        remove_carriage $CONFIG_FILE
    done
}

function remove_carriage_all {
    remove_carriage_config $1
    for CONFIG_FILE in $1/autoconf/install-sh $1/autoconf/mkinstalldirs
    do
        remove_carriage $CONFIG_FILE
        chmod u+x $CONFIG_FILE
    done
}

function do_remove_carriage {
    local SRC_ROOT=$LLVM_ROOT/llvm

    remove_carriage_all $SRC_ROOT
    remove_carriage_config $SRC_ROOT/projects/sample
    remove_carriage_all $SRC_ROOT/projects/test-suite
}

function do_configure {
    local SRC_ROOT=$LLVM_ROOT/llvm
    local OBJ_ROOT=$LLVM_ROOT/build
    local INSTALL_DIR=$LLVM_ROOT/install
    local FRONT_END_DIR=$LLVM_ROOT/llvm-gcc

    mkdir -p $OBJ_ROOT
    cd $OBJ_ROOT
    $SRC_ROOT/configure --prefix=$INSTALL_DIR --with-llvmgccdir=$FRONT_END_DIR \
        --disable-optimized --enable-targets=powerpc,x86
}

function do_build {
    local OBJ_ROOT=$LLVM_ROOT/build

    cd $OBJ_ROOT
    # parallel build
    make -j2 all
    make install
}

#do_clean_all
#do_init_checkout
do_update_all
do_remove_carriage
do_configure
do_build
