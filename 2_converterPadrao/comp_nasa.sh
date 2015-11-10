rm -f *.mod *.o create_netcdf_nasa
#NASA
pgf90 -Mpreprocess -DPGI benchmarking.f90 date_utils.f90 netcdf_utils.f90 ./nasa/nasa.f90 create_netcdf.f90 -o create_netcdf_nasa -I/scratchin/grupos/catt-brams/shared/libs/pgi/netcdf-4.1.1/include -L/scratchin/grupos/catt-brams/shared/libs/pgi/netcdf-4.1.1/lib -lnetcdf
#gfortran -cpp -ffree-form benchmarking.f90 date_utils.f90 netcdf_utils.f90 ./nasa/nasa.f90 create_netcdf.f90 -o create_netcdf_nasa_dust -I/opt/netcdf-4.0.1/include -L/opt/netcdf-4.0.1/lib -lnetcdf 
