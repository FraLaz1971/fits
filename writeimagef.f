      program wi2

C     this is just a simple main program that calls the writeimage subroutine

      call writeimage
      end

      subroutine writeimage

C     Create a FITS primary array containing a 2-D image

      integer status,unit,blocksize,bitpix,bzero,naxis,naxes(2)
      integer i,j,group,fpixel,nelements,keyval, uval
      character myval
      character endian*3,key*6
      character filename*80, mysign*16, keyword*64, comment*60
C cfname=configuration file containing input metadata for the image to create
C ifname=ascii file containing the image array points
      character*80 ifname,cfname
      real array(6840,5321)
      logical simple,extend
	  REAL FIELDS(6840)
      INTEGER IOSTAT, REC_NUM
      INTEGER RECLEN
	  CHARACTER*32767 LINE
      logical debug
      debug=.false.
      RECLEN = 102600
      open(unit=99, file='err.log', status='unknown')  
      status=0
      
      write(*,*) 'enter the name of the input configuration file'
      read *,cfname
      open(11,FILE=cfname,STATUS='old',ERR=999)
C BITPIX 8
      read(11,100) key,bitpix
C SIGN   signed
      read(11,110) key,mysign
C ENDIAN LSB
      read(11,110) key,endian
C WIDTH  500
      read(11,100) key,naxes(1)
C HEIGHT 320
      read(11,100) key,naxes(2)
C IFNAME mariner_mercury.asc 
      read(11,110) key,ifname
C OFNAME image001.fits
      read(11,110) key,filename
      close(11)
      write(*,*) 'configuration:'
      write(*,*)'BITPIX: ',bitpix
      write(*,*)'SIGN:   ',mysign
      write(*,*)'ENDIAN: ',endian
      write(*,*)'NAXIS1: ',naxes(1)
      write(*,*)'NAXIS2: ',naxes(2)
      write(*,*)'IFNAME: ',ifname
      write(*,*)'OFNAME: ',filename



C     Name of the FITS file to be created:

C     Delete the file if it already exists, so we can then recreate it
      call deletefile(filename,status)

C     Get an unused Logical Unit Number to use to open the FITS file
      call ftgiou(unit,status)

C     create the new empty FITS file
      blocksize=1
      status=0
      call ftinit(unit,filename,blocksize,status)
      write(*,*)'created empty fits file ',filename
C     initialize parameters about the FITS image 
      simple=.true.
      naxis=2
      extend=.true.
C  Write the required header keywords to the file
      status=0
      comment = 'pixel format is signed byte'
      write(*,*) 'Write the required header keywords to ',filename
C  read the image data from the ascii file
      write(*,*) 'opening for reading the image file ',ifname
C     write the required header keywords
      write(*,*) 'before calling ftphpr'
      call ftphpr(unit,simple,bitpix,naxis,naxes,0,1,extend,status)
      status=0
      write(*,*) 'ended reading input image file'
      write(*,*) 'unit: ', unit
      write(*,*) 'simple: ', simple
      write(*,*) 'bitpix: ', bitpix
      write(*,*) 'naxis: ', naxis
      write(*,*) 'naxes(1): ', naxes(1)
      write(*,*) 'naxes(2): ', naxes(2)
      write(*,*) 'pcount: ', 0
      write(*,*) 'gcount: ', 1
      write(*,*) 'extend: ', extend
      write(*,*) 'status: ', status
C     write the array to the FITS file
      group=1
      fpixel=1
      nelements=naxes(1)
      OPEN(UNIT=12, FILE=IFNAME, ACCESS='DIRECT', FORM='FORMATTED',
     &     RECL=RECLEN, STATUS='OLD', IOSTAT=IOSTAT,ERR=999)      
C     open(12,FILE=ifname,STATUS='old',FORM='FORMATTED',ERR=999)
      do 10,j=1,naxes(2)
C          READ(12,'(A)',END=90) LINE
          READ(12,FMT=900, REC=REC_NUM) FIELDS
C          IF (DEBUG) WRITE(*,*) LINE
C	      READ(LINE,*) FIELDS
          IF (DEBUG) WRITE(*,*) 'READ ROW ',J
      write(*,*) 'before calling ftppre'
      call ftppre(unit,group,fpixel,naxes(1),FIELDS,status)
      fpixel = fpixel + naxes(1)
10    continue
      close(12)
90    print *,'debug = ',debug
      if(debug) then
      do 30,j=1,naxes(1)
        do 40,i=1,naxes(2)
          print *,j,i,ARRAY(I,J)
40      continue
30    continue
      end if


C     write another optional keyword to the header
      call ftpkyj(unit,'EXPOSURE',1500,'Total Exposure Time',status)

C     close the file and free the unit number
      call ftclos(unit, status)
      call ftfiou(unit, status)

C     check for any error, and if so print out error messages
      if (status .gt. 0)call printerror(status)
100   format(A7,I8)
110   format(A7,A)
120   format(A)
900   FORMAT(6840F15.6)
990   goto 9999
999   write(*,*) 'ERROR: cannot read input configuration file'
      goto 9999
1000  write(*,*) 'ERROR: cannot read input image file'
9999  continue
      close(99)
      end

      subroutine printerror(status)

C     Print out the FITSIO error messages to the user

      integer status
      character errtext*30,errmessage*80

C     check if status is OK (no error); if so, simply return
      if (status .le. 0)return

C     get the text string which describes the error
      call ftgerr(status,errtext)
      print *,'FITSIO Error Status =',status,': ',errtext

C     read and print out all the error messages on the FITSIO stack
      call ftgmsg(errmessage)
      do while (errmessage .ne. ' ')
          print *,errmessage
          call ftgmsg(errmessage)
      end do
      end

      subroutine deletefile(filename,status)

C     A simple little routine to delete a FITS file

      integer status,unit,blocksize
      character*(*) filename

C     simply return if status is greater than zero
      if (status .gt. 0)return

C     Get an unused Logical Unit Number to use to open the FITS file
      call ftgiou(unit,status)

C     try to open the file, to see if it exists
      call ftopen(unit,filename,1,blocksize,status)

      if (status .eq. 0)then
C         file was opened;  so now delete it 
          call ftdelt(unit,status)
      else if (status .eq. 103)then
C         file doesn't exist, so just reset status to zero and clear errors
          status=0
          call ftcmsg
      else
C         there was some other error opening the file; delete the file anyway
          status=0
          call ftcmsg
          call ftdelt(unit,status)
      end if

C     free the unit number for later reuse
      call ftfiou(unit, status)
      end
