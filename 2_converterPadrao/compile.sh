
execF="create_netcdf_"$1"_"$2"_"$3

rm -f *.mod *.o ${execF}
case $1 in
	"nasa")
	module="./nasa/nasa.f90"
	;;
	"ncep")
	module="./ncep/ncep.f90"
	;;
	"ecmwf")
	module="./ecmwf/ecmwf_all.f90"
	;;
	*)
	;;
esac
echo $module

pgf90 -Mpreprocess -DPGI benchmarking.f90 date_utils.f90 netcdf_utils.f90 $module create_netcdf.f90 -o ${execF} -I/scratchin/grupos/catt-brams/shared/libs/pgi/netcdf-4.1.1/include -L/scratchin/grupos/catt-brams/shared/libs/pgi/netcdf-4.1.1/lib -lnetcdf

#gfortran -cpp -ffree-form benchmarking.f90 date_utils.f90 netcdf_utils.f90 ./nasa/nasa.f90 create_netcdf.f90 -o create_netcdf_nasa_dust -I/opt/netcdf-4.0.1/include -L/opt/netcdf-4.0.1/lib -lnetcdf 
