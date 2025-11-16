      program wiuchar

C  This is the FITSIO cookbook program that contains an annotated listing of
C  various computer programs that read and write files in FITS format
C  using the FITSIO subroutine interface.  These examples are
C  working programs which users may adapt and modify for their own
C  purposes.  This Cookbook serves as a companion to the FITSIO User's
C  Guide that provides more complete documentation on all the
C  available FITSIO subroutines.

C  Call the correct subroutine in turn:

      call writeimage
      write(0,*) 'the writeimage program ended.'

      end
C *************************************************************************
      subroutine writeimage

C  Create a FITS primary array containing a 2-D image
C  Takes in input the output file name, the number of
C  columns of the image (weight), the number of rows (height).
C  the size of the pixel in bits, if the pixel is signed or not 
      integer status,unit,blocksize,bitpix,bzero,naxis,naxes(2)
      integer i,j,group,fpixel,nelements,keyval, uval
      character myval
      character endian*3,key*6
      character filename*80, mysign*16, keyword*64, comment*60
C cfname=configuration file containing input metadata for the image to create
C ifname=ascii file containing the image array points
      character*80 ifname,cfname
      integer array(10000,10000)
      logical simple,extend
	  integer FIELDS(500)
	  CHARACTER*2000 LINE
      logical debug
      debug=.true.

C  The STATUS parameter must be initialized before using FITSIO.  A
C  positive value of STATUS is returned whenever a serious error occurs.
C  FITSIO uses an `inherited status' convention, which means that if a
C  subroutine is called with a positive input value of STATUS, then the
C  subroutine will exit immediately, preserving the status value. For 
C  simplicity, this program only checks the status value at the end of 
C  the program, but it is usually better practice to check the status 
C  value more frequently.
C  read configuration file
      write(0,*) 'enter the name of the input configuration file'
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
      write(0,*) 'configuration:'
      write(0,*)'BITPIX: ',bitpix
      write(0,*)'SIGN:   ',mysign
      write(0,*)'ENDIAN: ',endian
      write(0,*)'NAXIS1: ',naxes(1)
      write(0,*)'NAXIS2: ',naxes(2)
      write(0,*)'IFNAME: ',ifname
      write(0,*)'OFNAME: ',filename


C  Name of the FITS file to be created:
C      filename='ATESTFILEZ.FITS'

C  Delete the file if it already exists, so we can then recreate it.
C  The deletefile subroutine is listed at the end of this file.
      call deletefile(filename,status)

C  Get an unused Logical Unit Number to use to open the FITS file.
C  This routine is not required;  programmers can choose any unused
C  unit number to open the file.
      status=0
      call ftgiou(unit,status)

C  Create the new empty FITS file.  The blocksize parameter is a
C  historical artifact and the value is ignored by FITSIO.
      blocksize=1
      status=0
      write(0,*) 'Create the new empty FITS file ',filename
      call ftinit(unit,filename,blocksize,status)
      if (status.gt.0) call printerror(status)
C  Initialize parameters about the FITS image.
C  BITPIX = 16 means that the image pixels will consist of 16-bit
C  integers.  The size of the image is given by the NAXES values. 
C  The EXTEND = TRUE parameter indicates that the FITS file
C  may contain extensions following the primary array.
      simple=.true.
      naxis=2
      extend=.true.

C  Write the required header keywords to the file
      status=0
      comment = 'pixel format is signed byte'
      write(0,*) 'Write the required header keywords to ',filename
      call ftphpr(unit,simple,bitpix,naxis,naxes,0,1,extend,status)
      write(0,*) 'naxes(1):',naxes(1),'naxes(2):',naxes(2)
C  write the current date
      call FTPDAT(unit,status)
C  read the image data from the ascii file
      write(0,*) 'opening for reading the image file ',ifname
      open(12,FILE=ifname,STATUS='old',FORM='FORMATTED',ERR=999)
      do 10,j=1,naxes(2)
          READ(12,'(A)',END=90) LINE
	      READ(LINE,*) FIELDS
          do 20,i=1,naxes(1)
                array(I,J) = FIELDS(I)
            if (debug) print *,j,i,FIELDS(I)
20        continue
10    continue
      close(12)
90    print *,'debug = ',debug
      if(debug) then
      do 30,j=1,320
        do 40,i=1,500
          print *,j,i,ARRAY(I,J)
40      continue
30    continue
      end if
      write(0,*) 'ended reading input image file'
      
C  Write the array to the FITS file.
C  The last letter of the subroutine name defines the datatype of the
C  array argument; in this case the 'J' indicates that the array has an
C  integer*4 datatype. ('I' = I*2, 'E' = Real*4, 'D' = Real*8).
C  The 2D array is treated as a single 1-D array with NAXIS1 * NAXIS2
C  total number of pixels.  GROUP is seldom used parameter that should
C  almost always be set = 1.
      group=1
      fpixel=1
      nelements=naxes(1)*naxes(2)
      write(0,*) 'Write the array to the fits file'
      status=0
C FTPSS[BIJKED](unit,group,naxis,naxes,fpixels,lpixels,array, > status)
C      call ftpprb(unit,group,fpixel,nelements,array,status)
       call FTP2DB(unit,group,10000,naxes(1),naxes(2),array,status)
C      CALL FTPPRJ(unit, fpixel, nelements, array, status)

C  Write another optional keyword to the header
C  The keyword record will look like this in the FITS file:
C
C  EXPOSURE=                 1500 / Total Exposure Time
C
      write(0,*) 'Write EXPOSURE KEYWORD in the header'
      status=0
      call ftpkyj(unit,'EXPOSURE',1500,'Total Exposure Time',status)

C  The FITS file must always be closed before exiting the program. 
C  Any unit numbers allocated with FTGIOU must be freed with FTFIOU.
      write(0,*) 'Close the file'
      call ftclos(unit, status)
      write(0,*) 'Free the unit'
      call ftfiou(unit, status)

C  Check for any errors, and if so print out error messages.
C  The PRINTERROR subroutine is listed near the end of this file.
      if (status .gt. 0) call printerror(status)
100   format(A7,I3)
110   format(A7,A80)
120   format(A)
990   goto 9999
999   write(0,*) 'ERROR: cannot read input configuration file'
      goto 9999
1000  write(0,*) 'ERROR: cannot read input image file'
9999  continue
      end
C *************************************************************************
      subroutine printerror(status)

C  This subroutine prints out the descriptive text corresponding to the
C  error status value and prints out the contents of the internal
C  error message stack generated by FITSIO whenever an error occurs.

      integer status
      character errtext*30,errmessage*80

C  Check if status is OK (no error); if so, simply return
      if (status .le. 0) return

C  The FTGERR subroutine returns a descriptive 30-character text string that
C  corresponds to the integer error status number.  A complete list of all
C  the error numbers can be found in the back of the FITSIO User's Guide.
      call ftgerr(status,errtext)
      print *,'FITSIO Error Status =',status,': ',errtext

C  FITSIO usually generates an internal stack of error messages whenever
C  an error occurs.  These messages provide much more information on the
C  cause of the problem than can be provided by the single integer error
C  status value.  The FTGMSG subroutine retrieves the oldest message from
C  the stack and shifts any remaining messages on the stack down one
C  position.  FTGMSG is called repeatedly until a blank message is
C  returned, which indicates that the stack is empty.  Each error message
C  may be up to 80 characters in length.  Another subroutine, called
C  FTCMSG, is available to simply clear the whole error message stack in
C  cases where one is not interested in the contents.
      call ftgmsg(errmessage)
      do while (errmessage .ne. ' ')
          print *,errmessage
          call ftgmsg(errmessage)
      end do
      end
C *************************************************************************
      subroutine deletefile(filename,status)

C  A simple little routine to delete a FITS file

      integer status,unit,blocksize
      character*(*) filename

C  Simply return if status is greater than zero
      if (status .gt. 0)return

C  Get an unused Logical Unit Number to use to open the FITS file
      call ftgiou(unit,status)

C  Try to open the file, to see if it exists
      call ftopen(unit,filename,1,blocksize,status)

      if (status .eq. 0)then
C         file was opened;  so now delete it 
          write(0,*) 'deleting the file ',filename
          call ftdelt(unit,status)
      else if (status .eq. 103)then
C         file doesn't exist, so just reset status to zero and clear errors
          status=0
          call ftcmsg
          write(0,*) 'file ',filename,' doesn''t exist: doing nothing'
      else
C         there was some other error opening the file; delete the file anyway
          status=0
          call ftcmsg
          write(0,*) 'deleting the file ',filename
          call ftdelt(unit,status)
      end if

C  Free the unit number for later reuse
      call ftfiou(unit, status)
      end
