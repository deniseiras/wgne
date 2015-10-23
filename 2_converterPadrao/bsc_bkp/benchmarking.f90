!> Module containing benchmarking and code evaluation tools.
!!
!! Code for random number generator based on:
!! http://gcc.gnu.org/onlinedocs/gfortran/RANDOM_005fNUMBER.html#RANDOM_005fNUMBER
module benchmarking
  implicit none

  private

  public :: randomIntNumber
  public :: getFreeUnit
  public :: handleError
  public :: inquire1dFrom3d
  public :: inquire3dfrom1d
  public :: timeCount

contains

  function timeCount(iTime) result (localTime)
    integer, optional   :: iTime
    integer             :: localTime

    integer :: finalTime
    integer :: clockRate

    if(.not. present(iTime))then
      call system_clock(count=localTime)
    else
      call system_clock(count=finalTime)
      call system_clock(COUNT_RATE=clockRate)
      localTime = finalTime - iTime
      write(*,*) 'elapsed time: ', real(localTime)/real(clockRate), 'segs'
    end if

  end function timeCount


  function inquire1dFrom3d(i0, i1, i2, n0, n1, n2) result(idx)
    integer, intent(in) :: i0
    integer, intent(in) :: i1
    integer, intent(in) :: i2
    integer, intent(in) :: n0
    integer, intent(in) :: n1
    integer, intent(in) :: n2
    integer             :: idx

    idx = i0 + ((i1-1) * n0) + (i2-1)*(n0*n1)

  end function inquire1dFrom3d

  function inquire3dFrom1d(idx,n0,n1,n2) result(is)
    integer, intent(in)   :: idx
    integer, intent(in)   :: n0
    integer, intent(in)   :: n1
    integer, intent(in)   :: n2
    integer, dimension(3) :: is

    is(3) = ceiling(real(idx)/real(n0*n1))
    is(2) = ceiling(real(idx - (is(3)-1)*n0*n1)/real(n0))
    is(1) = idx - ((is(3)-1)*n0*n1) - ((is(2)-1)*n0)

  end function inquire3dFrom1d

  function getFreeUnit() result (u)
    integer :: u
    logical :: unitOk

    do
      u = randomIntNumber()
      u = max(u,10)
#if DEBUGFLAG
      write(*,*) '[debug] inside: getFreeUnit() @ MiscUtils.f90'
      write(*,*) 'trying to open unit: ', u
#endif
      inquire(unit=u, opened=unitOk)
      if(.not. unitOk) return
    end do

  end function getFreeUnit

  function randomIntNumber() result(r)
    real    :: r

    call initRandomSeed()
    call random_number(r)
    r = r*10e1

  end function randomIntNumber

  subroutine initRandomSeed()

#if INTEL
    use ifport, only: &
      getpid
#endif
#if PGI
    integer, external :: getpid
#endif

    integer, allocatable, dimension(:) :: seed
    integer :: i
    integer :: n
    integer :: allocStat
    integer :: pid
    integer :: s

    integer, dimension(2) :: t
    integer, dimension(8) :: dt
    integer, dimension(8) :: count
    integer, dimension(8) :: tms

    !!$  ! First try if the OS provides a random number generator
    !!$  open(newunit=un, file="/dev/urandom", access="stream", &
    !!$       form="unformatted", action="read", status="old", iostat=istat)
    !!$  if (istat == 0) then
    !!$  read(un) seed
    !!$  close(un)

    call random_seed(size=n)
    allocate(seed(n), stat=allocStat)
    ! Fallback to XOR:ing the current time and pid. The PID is
    ! useful in case one launches multiple instances of the same
    ! program in parallel.
    call system_clock(count(1))
    if(count(1) .ne. 0)then
      t = transfer(count, t)
    else
      call date_and_time(values=dt)
      tms = (dt(1) - 1970) * 365_8 * 24 * 60 * 60 * 1000 + &
        dt(2) * 31_8 * 24 * 60 * 60 * 1000          + &
        dt(3) * 24 * 60 * 60 * 60 * 1000            + &
        dt(5) * 60 * 60 * 1000                      + &
        dt(6) * 60 * 1000 + dt(7) * 1000            + &
        dt(8)
      t = transfer(tms, t)
    end if
    s = ieor(t(1), t(2))
    pid = getpid() + 1099279 !@ add a prime
    s = ieor(s, pid)
    if (n >= 3) then
      seed(1) = t(1) + 36269
      seed(2) = t(2) + 72551
      seed(3) = pid
      if (n > 3) then
        seed(4:) = s + 37 * (/ (i, i = 0, n - 4) /)
      end if
    else
      seed = s + 37 * (/ (i, i = 0, n - 1 ) /)
    end if
    call random_seed(put=seed)

    deallocate(seed)

  end subroutine initRandomSeed

!!$
!!$   8   subroutine initRandomSeed()
!!$   9    integer :: i
!!$  10    integer :: n
!!$  11    integer :: tic
!!$  12    integer :: allocStat
!!$  13    integer, dimension(:), allocatable :: seed
!!$  14
!!$  15     call random_seed(size=n)
!!$  16     allocate(seed(n), stat=allocstat)
!!$  17     if(allocstat .ne. 0) stop 'fatal error: not enough memory - initRandomSeed() - utils.f90'
!!$  18
!!$  19     call system_clock(count=tic)
!!$  20
!!$  21     seed = tic + 5 * (/ (i+1, i=1, n) /)
!!$  22     call random_seed(put=seed)
!!$  23
!!$  24     deallocate(seed)
!!$  28  !
!!$  29  !            seed = clock + 37 * (/ (i - 1, i = 1, n) /)
!!$  30  !            CALL RANDOM_SEED(PUT = seed)
!!$  31
!!$  32   end subroutine initRandomSeed

  !> Displays a message and stops the program in the event of an error.
  !!
  !! @param message String containing the error message.
  !! @param source  Name of the module/file where the error occurred.
  subroutine handleError(message, source)
    implicit none

    character (*), intent(in) :: message
    character (*), intent(in) :: source

    write(*, *) 'Fatal error in ' // trim(source) // ': ' // message
    stop
  end subroutine handleError
end module benchmarking
