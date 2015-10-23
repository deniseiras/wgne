#!/bin/bash

rm -f *.mod *.o exec output_*.nc

pgf90 -Mpreprocess -DPGI benchmarking.f90 date_utils.f90 barcelona.f90 -o exec -I/scratchin/grupos/catt-brams/shared/libs/pgi/netcdf-4.1.1/include -L/scratchin/grupos/catt-brams/shared/libs/pgi/netcdf-4.1.1/lib -lnetcdf
