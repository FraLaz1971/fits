      program main

C     this is just a simple main program that calls all the example subroutines

      call writeimage
      call writeascii
      call writebintable
      call copyhdu
      call selectrows
      call readheader
      call readimage
      call readtable
      end
      subroutine writeimage

C     Create a FITS primary array containing a 2-D image

      integer status,unit,blocksize,bitpix,naxis,naxes(2)
      integer i,j,group,fpixel,nelements,array(300,200)
      character filename*80
      logical simple,extend

      status=0
C     Name of the FITS file to be created:
      filename='ATESTFILEZ.FITS'

C     Delete the file if it already exists, so we can then recreate it
      call deletefile(filename,status)

C     Get an unused Logical Unit Number to use to open the FITS file
      call ftgiou(unit,status)

C     create the new empty FITS file
      blocksize=1
      call ftinit(unit,filename,blocksize,status)

C     initialize parameters about the FITS image (300 x 200 16-bit integers)
      simple=.true.
      bitpix=16
      naxis=2
      naxes(1)=300
      naxes(2)=200
      extend=.true.

C     write the required header keywords
      call ftphpr(unit,simple,bitpix,naxis,naxes,0,1,extend,status)

C     initialize the values in the image with a linear ramp function
      do j=1,naxes(2)
          do i=1,naxes(1)
              array(i,j)=i+j
          end do
      end do

C     write the array to the FITS file
      group=1
      fpixel=1
      nelements=naxes(1)*naxes(2)
      call ftpprj(unit,group,fpixel,nelements,array,status)

C     write another optional keyword to the header
      call ftpkyj(unit,'EXPOSURE',1500,'Total Exposure Time',status)

C     close the file and free the unit number
      call ftclos(unit, status)
      call ftfiou(unit, status)

C     check for any error, and if so print out error messages
      if (status .gt. 0)call printerror(status)
      end
      subroutine writeascii

C     Create an ASCII table containing 3 columns and 6 rows

      integer status,unit,readwrite,blocksize,tfields,nrows,rowlen
      integer nspace,tbcol(3),diameter(6), colnum,frow,felem
      real density(6)
      character filename*40,extname*16
      character*16 ttype(3),tform(3),tunit(3),name(6)
      data ttype/'Name','Diameter','Density'/
      data tform/'A8','I6','F4.2'/
      data tunit/' ','km','g/cm'/
      data name/'Mercury','Venus','Earth','Mars','Jupiter','Saturn'/
      data diameter/4880,12112,12742,6800,143000,121000/
      data density/5.1,5.3,5.52,3.94,1.33,0.69/

      status=0
C     Name of the FITS file to append the ASCII table to:
      filename='ATESTFILEZ.FITS'

C     Get an unused Logical Unit Number to use to open the FITS file
      call ftgiou(unit,status)

C     open the FITS file, with write access
      readwrite=1
      call ftopen(unit,filename,readwrite,blocksize,status)

C     append a new empty extension onto the end of the primary array
      call ftcrhd(unit,status)

C     define parameters for the ASCII table (see the above data statements)
      tfields=3
      nrows=6
      extname='PLANETS_ASCII'
      
C     calculate the starting position of each column, and the total row length
      nspace=1
      call ftgabc(tfields,tform,nspace,rowlen,tbcol,status)

C     write the required header parameters for the ASCII table
      call ftphtb(unit,rowlen,nrows,tfields,ttype,tbcol,tform,tunit,
     &            extname,status)

C     write names to the first column, diameters to 2nd col., and density to 3rd
      frow=1
      felem=1
      colnum=1
      call ftpcls(unit,colnum,frow,felem,nrows,name,status)
      colnum=2
      call ftpclj(unit,colnum,frow,felem,nrows,diameter,status)  
      colnum=3
      call ftpcle(unit,colnum,frow,felem,nrows,density,status)  

C     close the FITS file and free the unit number
      call ftclos(unit, status)
      call ftfiou(unit, status)

C     check for any error, and if so print out error messages
      if (status .gt. 0)call printerror(status)
      end
      subroutine writebintable

C     Create a binary table containing 3 columns and 6 rows

      integer status,unit,readwrite,blocksize,hdutype,tfields,nrows
      integer varidat,diameter(6), colnum,frow,felem
      real density(6)
      character filename*40,extname*16
      character*16 ttype(3),tform(3),tunit(3),name(6)
      data ttype/'Name','Diameter','Density'/
      data tform/'8A','1J','1E'/
      data tunit/' ','km','g/cm'/
      data name/'Mars','Jupiter','Saturn','Uranus','Neptune','Pluto'/
      data diameter/6800,143000,121000,47000,45000,6000/
      data density/3.94,1.33,0.69,1.56,2.27,1.0/

      status=0
C     Name of the FITS file to append the ASCII table to:
      filename='ATESTFILEZ.FITS'

C     Get an unused Logical Unit Number to use to open the FITS file
      call ftgiou(unit,status)

C     open the FITS file, with write access
      readwrite=1
      call ftopen(unit,filename,readwrite,blocksize,status)

C     move to the last (2nd) HDU in the file
      call ftmahd(unit,2,hdutype,status)

C     append/create a new empty HDU onto the end of the file and move to it
      call ftcrhd(unit,status)

C     define parameters for the binary table (see the above data statements)
      tfields=3
      nrows=6
      extname='PLANETS_BINARY'
      varidat=0
      
C     write the required header parameters for the binary table
      call ftphbn(unit,nrows,tfields,ttype,tform,tunit,
     &            extname,varidat,status)

C     write names to the first column, diameters to 2nd col., and density to 3rd
      frow=1
      felem=1
      colnum=1
      call ftpcls(unit,colnum,frow,felem,nrows,name,status)
      colnum=2
      call ftpclj(unit,colnum,frow,felem,nrows,diameter,status)  
      colnum=3
      call ftpcle(unit,colnum,frow,felem,nrows,density,status)  

C     close the FITS file and free the unit number
      call ftclos(unit, status)
      call ftfiou(unit, status)

C     check for any error, and if so print out error messages
      if (status .gt. 0)call printerror(status)
      end
      subroutine copyhdu

C     copy the 1st and 3rd HDUs from the input file to a new FITS file

      integer status,inunit,outunit,readwrite,blocksize,morekeys,hdutype
      character infilename*40,outfilename*40

      status=0
C     Name of the FITS files:
      infilename='ATESTFILEZ.FITS'
      outfilename='BTESTFILEZ.FITS'

C     Delete the file if it already exists, so we can then recreate it
      call deletefile(outfilename,status)

C     Get  unused Logical Unit Numbers to use to open the FITS files
      call ftgiou(inunit,status)
      call ftgiou(outunit,status)

C     open the input FITS file, with readonly access
      readwrite=0
      call ftopen(inunit,infilename,readwrite,blocksize,status)

C     create the new empty FITS file with the standard block size
      blocksize=1
      call ftinit(outunit,outfilename,blocksize,status)

C     copy the primary array from the input file to the output file
      morekeys=0
      call ftcopy(inunit,outunit,morekeys,status)

C     append/create a new empty extension on the end of the output file
      call ftcrhd(outunit,status)

C     skip to the 3rd extension in the input file
      call ftmahd(inunit,3,hdutype,status)

C     copy this extension from the input file to the output file
      call ftcopy(inunit,outunit,morekeys,status)  

C     close the FITS file and free the unit numbers
      call ftclos(inunit, status)
      call ftclos(outunit, status)
      call ftfiou(-1, status)

C     check for any error, and if so print out error messages
      if (status .gt. 0)call printerror(status)
      end
      subroutine selectrows

C     select rows from an input table and copy them to the output table

      integer status,inunit,outunit,readwrite,blocksize,hdutype
      integer nkeys,nspace,naxes(2),nfound,colnum,frow,felem
      integer noutrows,irow,temp(100),i
      real nullval,density(6)
      character infilename*40,outfilename*40,record*80
      logical exact,anynulls

      status=0
C     Names of the FITS files:
      infilename='ATESTFILEZ.FITS'
      outfilename='BTESTFILEZ.FITS'

C     Get  unused Logical Unit Numbers to use to open the FITS files
      call ftgiou(inunit,status)
      call ftgiou(outunit,status)

C     open the FITS files, with the appropriate read/write access
      readwrite=0
      call ftopen(inunit,infilename,readwrite,blocksize,status)
      readwrite=1
      call ftopen(outunit,outfilename,readwrite,blocksize,status)

C     move to the 3rd HDU in the input file (a binary table in this case)
      call ftmahd(inunit,3,hdutype,status)

C     move to the last extension in the output file
      do while (status .eq. 0)
          call ftmrhd(outunit,1,hdutype,status)
      end do

      if (status .eq. 107)then
C         this is normal; it just means we hit the end of file
          status=0
          call ftcmsg
      end if

C     create a new empty extension in the output file
      call ftcrhd(outunit,status)

C     find the number of keywords in the input table header
      call ftghsp(inunit,nkeys,nspace,status)

C     copy all the keywords from the input to the output extension
      do i=1,nkeys
          call ftgrec(inunit,i,record,status)
          call ftprec(outunit,record,status)
      end do

C     force FITSIO to read the output file keywords to define the data structure
      call ftrdef(outunit,status)
C     get the width of the table (in bytes) and the number of rows
      call ftgknj(inunit,'NAXIS',1,2,naxes,nfound,status)

C     find which column contains the DENSITY values
      exact=.false.
      call ftgcno(inunit,exact,'DENSITY',colnum,status)

C     read the DENSITY column values
      frow=1
      felem=1
      nullval=-99.
      call ftgcve(inunit,colnum,frow,felem,naxes(2),nullval,
     &            density,anynulls,status)

C     If the density is less than 3.0, copy the row to the output table
      noutrows=0
      do irow=1,naxes(2)
          if (density(irow) .lt. 3.0)then
              noutrows=noutrows+1
              call ftgtbb(inunit,irow,1,naxes(1),temp,status)
              call ftptbb(outunit,noutrows,1,naxes(1),temp,status)
          end if
      end do

C     update the NAXIS2 keyword with the correct no. of rows in the output file
      call ftmkyj(outunit,'NAXIS2',noutrows,'&',status)

C     close the FITS file and free the unit numbers
      call ftclos(inunit, status)
      call ftclos(outunit, status)
      call ftfiou(-1, status)

C     check for any error, and if so print out error messages
      if (status .gt. 0)call printerror(status)
      end
      subroutine readheader

C     Print out all the header keywords in all extensions of a FITS file

      integer status,unit,readwrite,blocksize,nkeys,nspace,hdutype,i
      character filename*80,record*80

      status=0

C     Get an unused Logical Unit Number to use to open the FITS file
      call ftgiou(unit,status)

C     name of FITS file 
      filename='ATESTFILEZ.FITS'

C     open the FITS file, with read-only access
      readwrite=0
      call ftopen(unit,filename,readwrite,blocksize,status)

100   continue

C     Determine the number of keywords in the header
      call ftghsp(unit,nkeys,nspace,status)

C     Read each 80-character keyword record, and print it out
      do i = 1, nkeys
          call ftgrec(unit,i,record,status)
          print *,record
      end do

C     Print out and END record, and a blank line to mark the end of the header
      if (status .eq. 0)then
          print *,'END'
          print *,' '
      end if

C     try moving to the next extension in the FITS file, if it exists
      call ftmrhd(unit,1,hdutype,status)

      if (status .eq. 0)then
C         success, so loop back and print out keywords in this extension
          go to 100

      else if (status .eq. 107)then
C         hit end of file, so quit
          print *,'***** END OF FILE *****'
          status=0
          call ftcmsg
      end if

C     close the file, free the unit number, and exit
      call ftclos(unit, status)
      call ftfiou(unit, status)

C     check for any error, and if so print out error messages
      if (status .gt. 0)call printerror(status)
      end
      subroutine readimage

C     Read a FITS image and determine the minimum and maximum pixel value

      integer status,unit,readwrite,blocksize,naxes(2),nfound
      integer group,firstpix,nbuffer,npixels,i
      real datamin,datamax,nullval,buffer(100)
      logical anynull
      character filename*80

      status=0

C     Get an unused Logical Unit Number to use to open the FITS file
      call ftgiou(unit,status)

C     open the FITS file previously created by WRITEIMAGE
      filename='ATESTFILEZ.FITS'
      readwrite=0
      call ftopen(unit,filename,readwrite,blocksize,status)

C     determine the size of the image
      call ftgknj(unit,'NAXIS',1,2,naxes,nfound,status)

C     check that it found both NAXIS1 and NAXIS2 keywords
      if (nfound .ne. 2)then
          print *,'READIMAGE failed to read the NAXISn keywords.'
          return
       end if

C     initialize variables
      npixels=naxes(1)*naxes(2)
      group=1
      firstpix=1
      nullval=-999
      datamin=1.0E30
      datamax=-1.0E30

      do while (npixels .gt. 0)
C         read up to 100 pixels at a time 
          nbuffer=min(100,npixels)
      
          call ftgpve(unit,group,firstpix,nbuffer,nullval,
     &            buffer,anynull,status)

C         find the min and max values
          do i=1,nbuffer
              datamin=min(datamin,buffer(i))
              datamax=max(datamax,buffer(i))
          end do

C         increment pointers and loop back to read the next group of pixels
          npixels=npixels-nbuffer
          firstpix=firstpix+nbuffer
      end do

C     print out the min and max values
      print *,'Min and max values in the image are:',datamin,datamax

C     close the file and free the unit number
      call ftclos(unit, status)
      call ftfiou(unit, status)

C     check for any error, and if so print out error messages
      if (status .gt. 0)call printerror(status)
      end
      subroutine readtable

C     read and print data values from an ASCII or binary table

      integer status,unit,readwrite,blocksize,hdutype,ntable
      integer felem,nelems,nullj,diameter,nfound,irow,colnum
      real nulle,density(1)
      character filename*40,nullstr*1,name*8,ttype(3)*10
      logical anynull

      status=0

C     Get an unused Logical Unit Number to use to open the FITS file
      call ftgiou(unit,status)

C     open the FITS file previously created by WRITEIMAGE
      filename='ATESTFILEZ.FITS'
      readwrite=0
      call ftopen(unit,filename,readwrite,blocksize,status)

C     loop twice, first reading the ASCII table, then the binary table
      do ntable=1,2

C         move to the next extension
          call ftmrhd(unit,1,hdutype,status)

          print *,' '
          if (hdutype .eq. 1)then
              print *,'Extension ',ntable,' is an ASCII table.'
          else if (hdutype .eq. 2)then
              print *,'Extension ',ntable,' is a binary table.'
          end if

C         read the TTYPEn keywords, which give the names of the columns
          call ftgkns(unit,'TTYPE',1,3,ttype,nfound,status)
          write(*,2000)ttype
2000      format(8x,3a10)

C         read the data, one row at a time, and print them out
          felem=1
          nelems=1
          nullstr=' '
          nullj=0
          nulle=0.
          do irow=1,6
              colnum=1
              call ftgcvs(unit,colnum,irow,felem,nelems,nullstr,name,
     &                    anynull,status)
              colnum=2
              call ftgcvj(unit,colnum,irow,felem,nelems,nullj,diameter,
     &                    anynull,status)
              colnum=3
              call ftgcve(unit,colnum,irow,felem,nelems,nulle,density,
     &                    anynull,status)
              write(*,2001)irow,name,diameter,density
2001          format(i4,a10,i10,f10.2)
          end do
      end do

C     close the file and free the unit number
      call ftclos(unit, status)
      call ftfiou(unit, status)

C     check for any error, and if so print out error messages
      if (status .gt. 0)call printerror(status)
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
