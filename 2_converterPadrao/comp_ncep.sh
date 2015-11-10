rm -f *.mod *.o create_netcdf_ncep_poll_noaer
#NCEP
pgf90 -Mpreprocess -DPGI benchmarking.f90 date_utils.f90 netcdf_utils.f90 ./ncep/ncep.f90 create_netcdf.f90 -o create_netcdf_ncep_poll_noaer -I/scratchin/grupos/catt-brams/shared/libs/pgi/netcdf-4.1.1/include -L/scratchin/grupos/catt-brams/shared/libs/pgi/netcdf-4.1.1/lib -lnetcdf

