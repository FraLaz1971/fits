      program main
      implicit none
      integer width,height,maxdim
      character*128 ifnam
      parameter(maxdim=5000)
      integer*2 x(maxdim**2),y(maxdim**2)
      character*1 values(maxdim**2)
C  This is the FITSIO cookbook program that contains an annotated listing of
C  various computer programs that read and write files in FITS format
C  using the FITSIO subroutine interface.  These examples are
C  working programs which users may adapt and modify for their own
C  purposes.  This Cookbook serves as a companion to the FITSIO User's
C  Guide that provides more complete documentation on all the
C  available FITSIO subroutines.

C  Call each subroutine in turn:
      print *,'enter input filename'
      read *,ifnam
      print *,'enter width'
      read *,width
      print *,'enter height'
      read *,height
      call rpl(ifnam,width,height,values)
      call wbt(width,height,values)
      stop
      end
C *************************************************************************
C RPL: READ PIXEL LIST (and save in memory arrays)
C *************************************************************************
      subroutine rpl(ifnam, width, height, values)
        implicit none
        logical debug
        integer width,height,maxdim,i,j,v
        character*128 ifnam
        parameter(maxdim=5000)
        integer*2 x(maxdim**2),y(maxdim**2)
        character*1 values(maxdim**2)
        character*(maxdim*4) LINE
        debug=.false.
        print *,'going to open ascii file ',ifnam 
        open(11,FILE=ifnam,err=8900)
        i=1
10      if (i.le.height) then
          if(debug)print *,'read row ',i
          read(11,110,end=80,err=9600) LINE
        else
          goto 80
        end if
        J=1
        if(debug)PRINT *,'READ LINE ',LINE
        DO 20,J=1,width
             read(LINE((J-1)*4+1:(J-1)*4+4),100,err=9700) v
             values((i-1)*width+j)=char(v)
             if(debug) PRINT *,'READ ELEMENT ',J,ichar(VALUES(J))
20      continue
        if(debug) then
        if (i.eq.1) print *,'n. columns:',j-1
        endif
        i=i+1
        J=1
        GOTO 10
80      close(11)
        if(debug) print '(''read'',I5,'' rows'')',i-1
        GOTO 9999
100     format(I4)
110     format(A)
8900    PRINT *, 'ERROR IN OPENING FILE',IFNAM
        GOTO 9999
9000    PRINT *, 'INPUT FILE NAME NOT ENTERED: EXITING'
        GOTO 9999
9100    PRINT *, 'ERROR IN READING INPUT FILE NAME: EXITING' 
9200    PRINT *, 'WIDTH NOT ENTERED: EXITING'
        GOTO 9999
9300    PRINT *, 'ERROR IN READING WIDTH: EXITING'
        GOTO 9999
9400    PRINT *, 'HEIGTH NOT ENTERED: EXITING'
        GOTO 9999
9500    PRINT *, 'ERROR IN READING HEIGHT: EXITING'
        GOTO 9999
9600    PRINT *, 'ERROR IN READING PIXEL LINE'
        GOTO 80
9700    PRINT *, 'ERROR IN READING PIXEL ELEMENT'
        GOTO 80
9999    CONTINUE
      end
C *************************************************************************
C WBT: WRITE BINARY TABLE 
C *************************************************************************

      subroutine wbt(width,height,values)
      implicit none
C  This routine creates a FITS binary table, or BINTABLE, containing
C  3 columns and nrows rows.  
      integer status,unit,readwrite,blocksize,hdutype,tfields,nrows
      integer varidat,colnum,frow,felem,maxdim,width,height
      parameter(maxdim=5000)
      integer*2 x(maxdim**2),y(maxdim**2)
      character*1 values(maxdim**2)
      character extname*16
      integer bitpix,naxis,naxes(2)
      integer i,j
      character filename*80
      logical simple,extend
      character*16 ttype(3),tform(3),tunit(3)
      data ttype/'X','Y','VALUE'/
      data tform/'1I','1I','1B'/
      data tunit/' ',' ',' '/
C  The STATUS parameter must always be initialized.
      status=0
      do 10,i=1,width*height
        x(i)=mod(i-1,width)+1
        y(i)=(i-1)/width+1
10    continue
C  Name of the FITS file to append the ASCII table to:
      filename='pixels.fits'
      call deletefile(filename,status)
      if(status.ne.0) print *,'ERROR IN DELETING FILE',filename        
C  Get an unused Logical Unit Number to use to open the FITS file.
      call ftgiou(unit,status)

C  Open the FITS file, with write access.
      readwrite=1
C     create the new empty FITS file
      blocksize=1
      call ftinit(unit,filename,blocksize,status)

C     initialize parameters about the FITS image (null image 8-bit integers)
      simple=.true.
      bitpix=8
      naxis=0
      naxes(1)=0
      naxes(2)=0
      extend=.true.

C     write the required header keywords
      call ftphpr(unit,simple,bitpix,naxis,naxes,0,1,extend,status)

C  Move to the first (1st) HDU in the file (the ASCII table).
      call ftmahd(unit,1,hdutype,status)

C  Append/create a new empty HDU onto the end of the file and move to it.
      call ftcrhd(unit,status)

C  Define parameters for the binary table (see the above data statements)
      tfields=3
c nrows=maxdim**2
      extname='PIXEL_LIST'
      varidat=0
      nrows=width*height
      
C  FTPHBN writes all the required header keywords which define the
C  structure of the binary table. NROWS and TFIELDS gives the number of
C  rows and columns in the table, and the TTYPE, TFORM, and TUNIT arrays
C  give the column name, format, and units, respectively of each column.
      call ftphbn(unit,nrows,tfields,ttype,tform,tunit,
     &            extname,varidat,status)

C  Write names to the first column, diameters to 2nd col., and density to 3rd
C  FTPCLS writes the string values to the NAME column (column 1) of the
C  table.  The FTPCLJ and FTPCLE routines write the diameter (integer) and
C  density (real) value to the 2nd and 3rd columns.  The FITSIO routines
C  are column oriented, so it is usually easier to read or write data in a
C  table in a column by column order rather than row by row.  Note that
C  the identical subroutine calls are used to write to either ASCII or
C  binary FITS tables.
      frow=1
      felem=1
      colnum=1
      call ftpcli(unit,colnum,frow,felem,nrows,x,status)
      colnum=2
      call ftpcli(unit,colnum,frow,felem,nrows,y,status)  
      colnum=3
      call ftpclb(unit,colnum,frow,felem,nrows,values,status)  

C  The FITS file must always be closed before exiting the program. 
C  Any unit numbers allocated with FTGIOU must be freed with FTFIOU.
      call ftclos(unit, status)
      call ftfiou(unit, status)

C  Check for any error, and if so print out error messages.
C  The PRINTERROR subroutine is listed near the end of this file.
      if (status .gt. 0)call printerror(status)
      end
C *************************************************************************
      subroutine readtable

C  Read and print data values from an ASCII or binary table
C  This example reads and prints out all the data in the ASCII and
C  the binary tables that were previously created by WRITEASCII and
C  wbt.  Note that the exact same FITSIO routines are
C  used to read both types of tables.

      integer status,unit,readwrite,blocksize,hdutype,ntable
      integer felem,nelems,nullj,diameter,nfound,irow,colnum
      real nulle,density
      character filename*40,nullstr*1,name*8,ttype(3)*10
      logical anynull

C  The STATUS parameter must always be initialized.
      status=0

C  Get an unused Logical Unit Number to use to open the FITS file.
      call ftgiou(unit,status)

C  Open the FITS file previously created by WRITEIMAGE
      filename='ATESTFILEZ.FITS'
      readwrite=0
      call ftopen(unit,filename,readwrite,blocksize,status)

C  Loop twice, first reading the ASCII table, then the binary table
      do ntable=2,3

C  Move to the next extension
          call ftmahd(unit,ntable,hdutype,status)

          print *,' '
          if (hdutype .eq. 1)then
              print *,'Reading ASCII table in HDU ',ntable
          else if (hdutype .eq. 2)then
              print *,'Reading binary table in HDU ',ntable
          end if

C  Read the TTYPEn keywords, which give the names of the columns
          call ftgkns(unit,'TTYPE',1,3,ttype,nfound,status)
          write(*,2000)ttype
2000      format(2x,'Row   ',3a10)

C  Read the data, one row at a time, and print them out
          felem=1
          nelems=1
          nullstr=' '
          nullj=0
          nulle=0.
          do irow=1,6
C             FTGCVS reads the NAMES from the first column of the table.
              colnum=1
              call ftgcvs(unit,colnum,irow,felem,nelems,nullstr,name,
     &                    anynull,status)

C             FTGCVJ reads the DIAMETER values from the second column.
              colnum=2
              call ftgcvj(unit,colnum,irow,felem,nelems,nullj,diameter,
     &                    anynull,status)

C             FTGCVE reads the DENSITY values from the third column.
              colnum=3
              call ftgcve(unit,colnum,irow,felem,nelems,nulle,density,
     &                    anynull,status)
              write(*,2001)irow,name,diameter,density
2001          format(i5,a10,i10,f10.2)
          end do
      end do

C  The FITS file must always be closed before exiting the program. 
C  Any unit numbers allocated with FTGIOU must be freed with FTFIOU.
      call ftclos(unit, status)
      call ftfiou(unit, status)

C  Check for any error, and if so print out error messages.
C  The PRINTERROR subroutine is listed near the end of this file.
      if (status .gt. 0)call printerror(status)
      end
C *************************************************************************
      subroutine printerror(status)

C  This subroutine prints out the descriptive text corresponding to the
C  error status value and prints out the contents of the internal
C  error message stack generated by FITSIO whenever an error occurs.

      integer status
      character errtext*30,errmessage*80

C  Check if status is OK (no error); if so, simply return
      if (status .le. 0)return

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
          print *,'file was opened;  so now delete ',filename
          call ftdelt(unit,status)
      else if (status .eq. 103)then
C         file doesn't exist, so just reset status to zero and clear errors
          print *,'file',filename, ' does not exist, so just reset 
     &status to zero and clear errors '
          status=0
          call ftcmsg
      else
C         there was some other error opening the file; delete the file anyway
          print *,'there was some other error opening the file; 
     &delete the file anyway'
          status=0
          call ftcmsg
          call ftdelt(unit,status)
      end if

C  Free the unit number for later reuse
      call ftfiou(unit, status)
      end
