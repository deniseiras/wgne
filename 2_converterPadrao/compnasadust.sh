rm -f *.mod *.o create_netcdf_nasadust
#NASA Dust
gfortran -cpp -ffree-form benchmarking.f90 date_utils.f90 netcdf_utils.f90 ./nasa/nasadust.f90 create_netcdf.f90 -o create_netcdf_nasadust -I/opt/netcdf-4.0.1/include -L/opt/netcdf-4.0.1/lib -lnetcdf 
