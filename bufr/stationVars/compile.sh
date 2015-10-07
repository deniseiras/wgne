#!/bin/sh

gfortran -cpp -ffixed-line-length-none -g -fbacktrace -fcheck=bounds iso_varying_string.f95 benchmarking.f90 date_utils.f90 inmet_stations.f90 get_station_vars.f90 -o generateVars.x
rm *.mod