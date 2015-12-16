module types

    implicit none

   type var2dType
        character(len=varNameSize) nameIn
        real, dimension(lonIn,latIn,timeIn) :: value
        integer :: id
	character(len=100) longName
        character(len=10) units
    end type var2dType

    type var3dType
        character(len=varNameSize) nameIn
        real, dimension(lonIn,latIn,levIn,timeIn3d) :: value
        integer :: id
	character(len=100) longName
        character(len=10) units
    end type var2dType


end module types
