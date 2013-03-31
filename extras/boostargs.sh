#!/bin/bash
#
# Set the boost args

BOOST_ALL_ADDL_ARGS="variant=release -s NO_COMPRESSION=1 --layout=system --without-mpi"
case $CXX in
  *pgCC)
    BOOST_ALL_ADDL_ARGS="toolset=pgi $BOOST_ALL_ADDL_ARGS --without-program_options"
    ;;
  *)
    ;;
esac
BOOST_SER_ADDL_ARGS="link=static $BOOST_ALL_ADDL_ARGS --without-python --build-dir=ser --stagedir=ser/stage"

