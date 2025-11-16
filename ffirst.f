      program writeimage

C     Create a FITS primary array containing a 2-D image

      integer status,unit,blocksize,bitpix,naxis,naxes(2)
      integer i,j,group,fpixel,nelements,array(300,200)
      character filename*80
      logical simple,extend

      status=0
C     Name of the FITS file to be created:
      filename='ATESTFILE.FITS'

C     Get an unused Logical Unit Number to use to create the FITS file
      call ftgiou(unit,status)
      print *,'unit =',unit
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
      do 10 j=1,naxes(2)
          do 20 i=1,naxes(1)
              array(i,j)=i+j
20        continue
10    continue

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
      end
