#!/bin/sh

gfortran -cpp -ffixed-line-length-none -g -fbacktrace -fcheck=bounds iso_varying_string.f95 benchmarking.f90 date_utils.f90 inmet_stations.f90 get_station_vars.f90 -o read.x
gfortran -cpp -ffixed-line-length-none -g -fbacktrace -fcheck=bounds benchmarking.f90 date_utils.f90 inmet_stations.f90 evaluate_t2m.f90 -o t2m.x
rm *.mod