rm -f *.mod *.o create_netcdf_nasa_dust
#NASA Dust
gfortran -cpp -ffree-form benchmarking.f90 date_utils.f90 netcdf_utils.f90 ./nasa/nasa.f90 create_netcdf.f90 -o create_netcdf_nasa_dust -I/opt/netcdf-4.0.1/include -L/opt/netcdf-4.0.1/lib -lnetcdf 
