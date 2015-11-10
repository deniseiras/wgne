#!/bin/bash

rm -f *.mod *.o xnasa

pgf90 -Mpreprocess -DPGI benchmarking.f90 date_utils.f90 nasa.f90 -o xnasa -I/scratchin/grupos/catt-brams/shared/libs/pgi/netcdf-4.1.1/include -L/scratchin/grupos/catt-brams/shared/libs/pgi/netcdf-4.1.1/lib -lnetcdf