C 
      PROGRAM I3D22D
      IMPLICIT NONE
      LOGICAL DEBUG
      INTEGER BITPIX, NAXIS, NAXIS1, NAXIS2, NAXIS3, NAXES(3)
      INTEGER STATUS, IUNIT, OUNIT1, OUNIT2, OUNIT3
      INTEGER ST1,ST2,ST3,NFOUND
      INTEGER BLKSZ, FPIXEL, NELEMENTS, GROUP, IOMODE, I, J, K,CNT
      REAL BSCALE, BZERO 
      LOGICAL SIMPLE, EXTEND
      CHARACTER*80 FNAME, OFILE1, OFILE2, OFILE3
      CHARACTER*1 IMG3D(5000000)
      CHARACTER*1 IMG2D1(1280,1267)
      CHARACTER*1 IMG2D2(1280,1267)
      CHARACTER*1 IMG2D3(1280,1267)
      CHARACTER*1 NULLVAL
      LOGICAL ANYF
      NULLVAL = CHAR(0)
      BLKSZ=1
      FPIXEL=1
      GROUP=1 
      IOMODE=0
      FNAME='m31.fits'
      OFILE1='m31sl1.fits'
      OFILE2='m31sl2.fits'
      OFILE3='m31sl3.fits'
      DATA STATUS /0/
      DATA DEBUG /.TRUE./
      BITPIX = 8
      BSCALE = 1.0
      BZERO = 0.0
      SIMPLE = .TRUE.

      IF (DEBUG) WRITE(0,*)'Get the free unit number for input file'
      call ftgiou(iunit,status)
      IF (DEBUG) WRITE(0,*)'iunit: ',iunit,' fname: ',fname

C     Open input FITS file
      STATUS=0
      IF (DEBUG) WRITE(0,*)'Open 3d image input FITS file'
      CALL FTOPEN(IUNIT, FNAME, IOMODE, BLKSZ, STATUS)
      IF (STATUS .NE. 0) THEN
          WRITE(*,*) 'Error opening input file'
          CALL PRINTERROR(STATUS)
          STOP
      ENDIF
C     determine the size of the image
      status = 0
      call ftgknj(iunit,'NAXIS',1,3,naxes,nfound,status)
      IF (STATUS .NE. 0) THEN
          WRITE(0,*) 'Error reading image NAXIS data'
          CALL PRINTERROR(STATUS)
          STOP
      ENDIF
      if (nfound .ne. 3)then
          print *,'READIMAGE failed to read the NAXISn keywords.'
          return
      end if
      NAXIS = NFOUND
      IF (DEBUG) WRITE(0,*)'NFOUND = ',NFOUND
      IF (DEBUG) WRITE(0,*)'NAXIS = ',NAXIS,' NAXIS1 ',NAXES(1),
     & 'NAXIS2 ',NAXES(2),'NAXIS3 ',NAXES(3)
      NAXIS1 = NAXES(1)  
      NAXIS2 = NAXES(2)  
      NAXIS3 = NAXES(3)  
C     Read the 3D IMG data
      STATUS=0
      IF (DEBUG) WRITE(0,*)'Read the 3d image data'
      NELEMENTS = NAXIS1 * NAXIS2 * NAXIS3
C     CALL FTGPV[BIJED](unit,group,fpixel,nelements,nullval, > values,anyf,status)
      CALL FTGPVB(IUNIT, GROUP, FPIXEL, NELEMENTS, 
     &            NULLVAL, IMG3D, ANYF, STATUS)
      IF (STATUS .NE. 0) THEN
          WRITE(*,*) 'Error reading 3D data'
          CALL PRINTERROR(STATUS)
          STOP
      ENDIF

C     Close input file
      IF (DEBUG) WRITE(0,*)'CLOSE the input file'
      STATUS=0
      CALL FTCLOS(IUNIT, STATUS)
      call FTFIOU(IUNIT, STATUS)
C     Extract and save slices
      IF (DEBUG) WRITE(0,*)'write on screen the 3D data array'
      DEBUG=.FALSE.
      DO 300, K = 1, NAXIS3
          IF(K.EQ.4) GOTO 400
          DO 100, J = 1, NAXIS2
              DO 200, I = 1, NAXIS1
C                  IMG2D(I,J) = IMG3D((j-1)*NAXIS1+I+0*NAXIS1*NAXIS2)
                   IF (DEBUG) WRITE(0,*)I,J,K,I+(J-1)*
     &             NAXIS1+(K-1)*NAXIS1*NAXIS2
                   CNT = I+(J-1)*NAXIS1+(K-1)*NAXIS1*NAXIS2
                   IF(CNT.LE.(NAXIS1*NAXIS2)) THEN
                     IMG2D1(I,J) = IMG3D(CNT)
                   ELSE IF((CNT.GT.(NAXIS1*NAXIS2)).AND.
     &               (CNT.LE.2*NAXIS1*NAXIS2)) THEN
                     IMG2D2(I,J) = IMG3D(CNT)                            
                   ELSE IF((CNT.GT.(2*NAXIS1*NAXIS2)).AND.
     &               (CNT.LE.3*NAXIS1*NAXIS2)) THEN
                     IMG2D3(I,J) = IMG3D(CNT)                            
                   END IF
200           CONTINUE
100      CONTINUE
300   CONTINUE      
400   CONTINUE
      debug = .true.

      
      IF (DEBUG) WRITE(0,*)'going to call cr2dft ',OFILE1
      CALL CR2DFT(OFILE1, IMG2D1, NAXIS1, NAXIS2, 
     &                  BITPIX, BSCALE, BZERO)
      ST1=STATUS
      
      IF (DEBUG) WRITE(0,*)'save the second 2d image on ',OFILE2
      STATUS=0
      CALL CR2DFT(OFILE2, IMG2D2, NAXIS1, NAXIS2, 
     &                  BITPIX, BSCALE, BZERO)
      ST2=STATUS

      IF (DEBUG) WRITE(0,*)'save the 3rd 2d image on ',OFILE3
      STATUS=0
      CALL CR2DFT(OFILE3, IMG2D3, NAXIS1, NAXIS2, 
     &                  BITPIX, BSCALE, BZERO)
      ST3=STATUS
      IF((ST1.EQ.0).AND.(ST2.EQ.0).AND.(ST3.EQ.0)) THEN
        WRITE(*,*) '3D FITS file successfully split into 3 2D IMGs'
      ELSE
        WRITE(*,*) 'ERROR IN CREATING THE 3 2D IMGs'
      ENDIF
      STOP
      END

C     Subroutine to create 2D FITS files
      SUBROUTINE CR2DFT(FNAME, IMG, NAXIS1, NAXIS2,
     &                        BITPIX, BSCALE, BZERO)
      IMPLICIT NONE
      CHARACTER*80 FNAME
      INTEGER NAXIS1, NAXIS2, NAXES(2), BITPIX
      CHARACTER*1 IMG(NAXIS1, NAXIS2)
      REAL BSCALE, BZERO
      LOGICAL DEBUG
      INTEGER STATUS, OUNIT, BLKSZ, FPIXEL, GROUP, NELEMENTS
      LOGICAL SIMPLE, EXTEND
      
      STATUS = 0
      BLKSZ = 1
      SIMPLE = .TRUE.
      EXTEND = .FALSE.
      DEBUG = .TRUE.
      FPIXEL = 1 
      GROUP = 1
      NAXES(1)=NAXIS1
      NAXES(2)=NAXIS2
      call deletefile(fname,status)
      status=0
      call ftgiou(ounit,status)
C     Create new FITS file
      IF (DEBUG) WRITE(0,*)'creating OUTPUT file ', FNAME 
      CALL FTINIT(OUNIT, FNAME, BLKSZ, STATUS)
      IF (STATUS .NE. 0) THEN
          WRITE(0,*) 'Error creating output file: ', FNAME
          CALL PRINTERROR(STATUS)
          RETURN
      ENDIF

C     Write primary header

      STATUS=0
      IF (DEBUG) WRITE(0,*)'writing primary header'      
      CALL FTPHPR(OUNIT,SIMPLE,BITPIX,2,NAXES,
     &            0,1,EXTEND,STATUS)
      
C     Write additional header keywords
c      STATUS=0
c      CALL FTPKYE(OUNIT, 'BSCALE', BSCALE, 10, 
c     &            'Data scaling factor', STATUS)
c      STATUS=0
c      CALL FTPKYE(OUNIT, 'BZERO', BZERO, 10,
c     &            'Data zero point', STATUS)
c      STATUS=0
c      CALL FTPKYF(OUNIT, 'DATAMAX', 255.0, 1,
c     &            'Maximum data value', STATUS)
c      STATUS=0
c      STATUS=0
c      CALL FTPKYF(OUNIT, 'DATAMIN', 0.0, 1,
c     &            'Minimum data value', STATUS)
      STATUS=0
      IF (DEBUG) WRITE(0,*)'writing history keyword'      
      CALL FTPHIS(OUNIT, 'Extracted from 3D FITS file', STATUS)

C     Write IMG data
      NELEMENTS = NAXIS1 * NAXIS2
      STATUS=0
      IF (DEBUG) WRITE(0,*)'writing image data'      
      CALL FTPPRB(OUNIT, GROUP, FPIXEL, NELEMENTS, IMG, STATUS)

C     Close the file
      STATUS=0
      IF (DEBUG) WRITE(0,*)'closing the file'      
      CALL FTCLOS(OUNIT, STATUS)
      call FTFIOU(OUNIT, STATUS)
      
      IF (STATUS .NE. 0) THEN
          WRITE(0,*) 'Error writing file: ', FNAME
          CALL PRINTERROR(STATUS)
      ELSE
          WRITE(0,*) 'Successfully created: ', FNAME
      ENDIF
      
      RETURN
      END
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

