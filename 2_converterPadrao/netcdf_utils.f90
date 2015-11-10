module netcdf_utils
    use netcdf
    implicit none

contains
    subroutine closeFile(ncId)
        implicit none
        integer, intent(in) :: ncId
        print*, "FECHANDO ARQUIVO ", ncId
        call check(nf90_close(ncId))
    end subroutine closeFile

    subroutine openFile(ncid, inputFile)
        implicit none
        character(len=255), intent(in) :: inputFile
        integer, intent(inout) :: ncid
        print *, "ABRINDO ARQUIVO ", trim(inputFile)
        call check(nf90_open(trim(inputFile), NF90_NOWRITE, ncid))
        print*, "ARQUIVO ABERTO: ", trim(inputFile), ncid
    end subroutine openFile

    subroutine createFile(ncid, outputFile)
        implicit none
        integer,intent(inout) :: ncid
        character(len=255), intent(in) :: outputFile
        print*, "CRIANDO ARQUIVO ", outputFile
!        call check(nf90_create(trim(outputFile), NF90_CLOBBER, ncid))
        call check(nf90_create(trim(outputFile), NF90_64BIT_OFFSET, ncid))
    end subroutine createFile

    subroutine check(status)
        implicit none
        integer, intent (in) :: status
        if(status /= nf90_noerr) then
            print *, "####### ERROR ########"
            print *, trim(nf90_strerror(status))
            print *, status
            stop "Stopped"
        end if
    end subroutine check

end module netcdf_utils
