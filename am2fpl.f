      program am2fpl
C this program reads an ascii matrix image (nrows x mcolumns)
C and saves it as a fits binary table pixel list.
C it takes as input from the standard input (o from a redirected file)
C the input matrix file name
C the width of the input matrix
C the hright of the input matrix
      implicit none
      integer width,height,maxdim
      character*128 ifnam
      parameter(maxdim=500)
      character*1 values(maxdim**2)
      logical debug
      debug=.true.
C  Call needed subroutines in turn:
      print *,'# enter input filename'
      read *,ifnam
      print *,'# enter width'
      read *,width
      print *,'# enter height'
      read *,height
      call m2pl(ifnam,width,height,values)
      if(debug)print *,'going to write binary table call wbt()'
      call wbt(width,height,values)
c      call fplapl(ifnam)
      stop
      end
C *************************************************************************
C m2pl: MATRIX TO PIXEL LIST (and save in memory arrays)
C *************************************************************************
      subroutine m2pl(ifnam, width, height, values)
        implicit none
        logical debug
        integer width,height,maxdim,i,j,v
        character*128 ifnam
        parameter(maxdim=500)
        character*1 values(maxdim**2)
        character*(maxdim*4) LINE
        debug=.true.
        print *,'going to open ascii file ',ifnam 
        open(11,FILE=ifnam,err=8900)
        i=1
10      if (i.le.height) then
          if(debug) print *,'going to read row ',i
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
      parameter(maxdim=500)
      integer*2 x(maxdim**2),y(maxdim**2)
      character*1 values(maxdim**2)
      character extname*16
      integer bitpix,naxis,naxes(2)
      integer i
      character filename*80
      logical sim2ple,extend,debug
      character*16 ttype(3),tform(3),tunit(3)
      data ttype/'X','Y','VALUE'/
      data tform/'1I','1I','1B'/
      data tunit/' ',' ',' '/
      debug=.true.
      print *,'going generate the values for x() and y()'
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
      if(debug)print *,'created new empty fits file'

C     initialize parameters about the FITS image (null image 8-bit integers)
      sim2ple=.true.
      bitpix=8
      naxis=0
      naxes(1)=0
      naxes(2)=0
      extend=.true.

C     write the required header keywords
      call ftphpr(unit,sim2ple,bitpix,naxis,naxes,0,1,extend,status)
      if(debug)print *,'written required primary header keywords'

C  Move to the first (1st) HDU in the file.
      call ftmahd(unit,1,hdutype,status)
      if(debug)print *,'Moved to the first (1st) HDU in the file.'

C  Append/create a new empty HDU onto the end of the file and move to it.
      call ftcrhd(unit,status)
      if(debug)print *,'create a new empty HDU onto the end of the file
     &and move to it'

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
      if(debug)print *,'written the required header keywords which 
     &define the structure of the binary table'
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
      if(debug)print *,'written column 1' 
      colnum=2
      call ftpcli(unit,colnum,frow,felem,nrows,y,status)  
      if(debug)print *,'written column 2' 
      colnum=3
      call ftpclb(unit,colnum,frow,felem,nrows,values,status)  
      if(debug)print *,'written column 3' 

C  The FITS file must always be closed before exiting the program. 
C  Any unit numbers allocated with FTGIOU must be freed with FTFIOU.
      call ftclos(unit, status)
      if(debug)print *,'closed fits file' 
      call ftfiou(unit, status)
      if(debug)print *,'freed file unit' 

C  Check for any error, and if so print out error messages.
C  The PRINTERROR subroutine is listed near the end of this file.
      if (status .gt. 0)call printerror(status)
      end
C *************************************************************************
C fplapl: FITS PIXEL LIST TO ASCII PIXEL LIST
C *************************************************************************
      subroutine fplapl(filename)
      implicit none
C  Read and print data values from an ASCII or binary table
C  This exam2ple reads and prints out all the data in the ASCII and
C  the binary tables that were previously created by WRITEASCII and
C  wbt.  Note that the exact same FITSIO routines are
C  used to read both types of tables.

      integer status,unit,readwrite,blocksize,hdutype,ntable,cnkdim
      integer varidat,colnum,frow,felem,maxdim,width,height,cnkcnt
      parameter(maxdim=5, cnkdim=maxdim**2)
      integer*2 x(cnkdim),y(cnkdim)
      character*1 values(cnkdim),nullb
      integer nelems,nfound,irow
      integer*2 nulli
      character filename*128,ttype(3)*10
      logical anynull,debug
      debug=.false.
C  The STATUS parameter must always be initialized.
      status=0

C  Get an unused Logical Unit Number to use to open the FITS file.
      call ftgiou(unit,status)

C  Open the FITS file previously created by WRITEIMAGE
      readwrite=0
      call ftopen(unit,filename,readwrite,blocksize,status)

C  Loop twice, first reading the ASCII table, then the binary table
      ntable=2

C  Move to the next extension
          call ftmahd(unit,ntable,hdutype,status)

          if (debug) print *,' '
          if (debug) print *,'Reading binary table in HDU ',ntable

C  Read the TTYPEn keywords, which give the names of the columns
          call ftgkns(unit,'TTYPE',1,3,ttype,nfound,status)
          if (debug) write(*,2000)ttype
2000      format('#',3a10)

C  Read the data, one row at a time, and print them out
          felem=1
          nelems=maxdim**2
          nulli=0
          nullb=char(0)
          irow=1
          do 80,cnkcnt=0,159975,cnkdim
              irow=cnkcnt+1
              nelems=cnkdim
C             FTGCVI reads the X  from the first column of the table.
              colnum=1
              call ftgcvi(unit,colnum,irow,felem,nelems,nulli,x,
     &                    anynull,status)

C             FTGCVI reads the Y values from the second column.
              colnum=2
              call ftgcvi(unit,colnum,irow,felem,nelems,nulli,y,
     &                    anynull,status)

C             FTGCVE reads the PIXEL 8 BITS values from the third column.
              colnum=3
              call ftgcvb(unit,colnum,irow,felem,nelems,nullb,values,
     &                    anynull,status)
     
              do 70,irow=1,cnkdim              
                write(*,2001)x(irow),y(irow),ichar(values(irow))
70            continue
80            continue
2001          format(i5,1x,i5,1x,i3)
      
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

C  Check if status is OK (no error); if so, sim2ply return
      if (status .le. 0)return

C  The FTGERR subroutine returns a descriptive 30-character text string that
C  corresponds to the integer error status number.  A com2plete list of all
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
C  FTCMSG, is available to sim2ply clear the whole error message stack in
C  cases where one is not interested in the contents.
      call ftgmsg(errmessage)
      do while (errmessage .ne. ' ')
          print *,errmessage
          call ftgmsg(errmessage)
      end do
      end
C *************************************************************************
      subroutine deletefile(filename,status)

C  A sim2ple little routine to delete a FITS file

      integer status,unit,blocksize
      character*(*) filename

C  Sim2ply return if status is greater than zero
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
