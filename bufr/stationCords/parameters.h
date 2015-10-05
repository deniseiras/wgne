!# variable precision.
integer, parameter :: R8 = selected_real_kind(8)
integer, parameter :: I8 = selected_int_kind(8)

!# variable sizes.
integer, parameter :: BIGSTRING     = 500
integer, parameter :: FILENAMESIZE  = 255
integer, parameter :: TINYSTRING    = 50
integer, parameter :: GRADSVAR      = 20
integer, parameter :: DATESIZE      = 14
integer, parameter :: STATIONNAME   = 10

!# date parameters.
integer, parameter :: SECONDSPERDAY = 86400
integer, parameter :: BASEYEAR      = 1900

!# execution parameters.
integer, parameter :: MAXMETRICS    = 25
