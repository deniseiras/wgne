rm -f *.mod *.o create_netcdf_ecmwf_poll_noaer
#ECMWF
pgf90 -Mpreprocess -DPGI benchmarking.f90 date_utils.f90 netcdf_utils.f90 ./ecmwf/ecmwf_all.f90 create_netcdf.f90 -o create_netcdf_ecmwf_poll_noaer -I/scratchin/grupos/catt-brams/shared/libs/pgi/netcdf-4.1.1/include -L/scratchin/grupos/catt-brams/shared/libs/pgi/netcdf-4.1.1/lib -lnetcdf

