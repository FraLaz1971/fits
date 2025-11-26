C 
      PROGRAM I3D22D
      IMPLICIT NONE
      INTEGER BITPIX, NAXIS, NAXIS1, NAXIS2, NAXIS3, NAXES(3)
      INTEGER STATUS, IUNIT, OUNIT, I, J
      INTEGER BLOCKSIZE, FPIXEL, NELEMENTS, GROUP, NFOUND
      REAL BSCALE, BZERO
      LOGICAL SIMPLE, EXTEND
      LOGICAL DEBUG
      CHARACTER*80 FNAME, OUTFILE1, OUTFILE2, OUTFILE3      
      CHARACTER*1 IMAGE3D(5000000)
      CHARACTER*1 IMAGE2D(1280,1267)
      CHARACTER*1 NULLVAL
      LOGICAL ANYF
      DATA FNAME /'m31.fits'/
      DATA OUTFILE1 /'m31sl1_2.fits'/
      DATA OUTFILE2 /'m31sl2_2.fits'/
      DATA OUTFILE3 /'m31sl3_2.fits'/
      DATA STATUS /0/
      DATA DEBUG /.TRUE./
C     Get FITS file parameters from your header
      NAXIS1 = 1280
      NAXIS2 = 1267  
      NAXIS3 = 3
      BITPIX = 8
      BSCALE = 1.0
      BZERO = 0.0
      SIMPLE = .TRUE.
      ANYF = .FALSE.
      BLOCKSIZE=1
      FPIXEL=1
      GROUP=1 

      IF (DEBUG) WRITE(*,*)'Get the free unit number for input file'
      call ftgiou(iunit,status)
      IF (DEBUG) WRITE(*,*)'iunit: ',iunit,' fname: ',fname

C     Open input FITS file read-only (=0)
      STATUS = 0
      CALL FTOPEN(IUNIT, FNAME, 0, BLOCKSIZE, STATUS)
      IF (STATUS .NE. 0) THEN
          WRITE(*,*) 'Error opening input file'
          CALL PRINTERROR(STATUS)
          STOP
      ENDIF
      WRITE(*,*) 'input file opened'
      call ftgknj(iunit,'NAXIS',1,3,naxes,nfound,status)
      IF (STATUS .NE. 0) THEN
          WRITE(*,*) 'Error reading image NAXIS data'
          CALL PRINTERROR(STATUS)
          STOP
      ENDIF
      if (nfound .ne. 3)then
          print *,'READIMAGE failed to read the NAXISn keywords.'
          CALL PRINTERROR(STATUS)
          STOP
      end if
      NAXIS = NFOUND
      IF (DEBUG) WRITE(*,*)'NFOUND = ',NFOUND
      IF (DEBUG) WRITE(*,*)'NAXIS = ',NAXIS,' NAXIS1 ',NAXES(1),
     & 'NAXIS2 ',NAXES(2),'NAXIS3 ',NAXES(3)
      NAXIS1 = NAXES(1)  
      NAXIS2 = NAXES(2)  
      NAXIS3 = NAXES(3)  

C     Read the 3D image data
      NELEMENTS = NAXIS1 * NAXIS2 * NAXIS3
      STATUS = 0
      CALL FTGPVB(IUNIT, GROUP, FPIXEL, NELEMENTS, 
     &            NULLVAL, IMAGE3D, ANYF, STATUS)
C      CALL FTGPVB(IUNIT, GROUP, FPIXEL, NELEMENTS, 
C     &            BZERO, BSCALE, IMAGE3D, ANYF, STATUS)
      IF (STATUS .NE. 0) THEN
          WRITE(*,*) 'Error reading 3D data'
          CALL PRINTERROR(STATUS)
          STOP
      ENDIF
      WRITE(*,*) 'read 3D data'

C     Close input file
      CALL FTCLOS(IUNIT, STATUS)
      call ftfiou(iunit, status)
      WRITE(*,*) 'closed input file'

C     Extract and save first slice (z=1)
      DO 100 J = 1, NAXIS2
          DO 200 I = 1, NAXIS1
              IMAGE2D(I,J) = IMAGE3D(I+(J-1)*NAXIS1+0*NAXIS1*NAXIS2)
200     CONTINUE
100   CONTINUE
      WRITE(*,*) 'first slice extracted'
      
      CALL CR2DFT(OUTFILE1, IMAGE2D, NAXIS1, NAXIS2, 
     &                  BITPIX, BSCALE, BZERO)
      WRITE(*,*) 'first slice saved'

C     Extract and save second slice (z=2)
      DO 300 J = 1, NAXIS2
          DO 400 I = 1, NAXIS1
              IMAGE2D(I,J) = IMAGE3D(I+(J-1)*NAXIS1+1*NAXIS1*NAXIS2)
400       CONTINUE
300   CONTINUE
      WRITE(*,*) 'second slice extracted'
      
      CALL CR2DFT(OUTFILE2, IMAGE2D, NAXIS1, NAXIS2,
     &                  BITPIX, BSCALE, BZERO)
      WRITE(*,*) 'second slice saved'

C     Extract and save third slice (z=3)
      DO 500 J = 1, NAXIS2
          DO 600 I = 1, NAXIS1
              IMAGE2D(I,J) = IMAGE3D(I+(J-1)*NAXIS1+2*NAXIS1*NAXIS2)
600       CONTINUE
500   CONTINUE
        WRITE(*,*) 'third slice extracted'
    
      CALL CR2DFT(OUTFILE3, IMAGE2D, NAXIS1, NAXIS2,
     &                  BITPIX, BSCALE, BZERO)
      WRITE(*,*) 'third slice saved'

C     Clean up
C      DEALLOCATE(IMAGE3D, IMAGE2D)
      WRITE(*,*) '3D FITS file successfully split into 3 2D images'
      STOP
      END

C     Subroutine to create 2D FITS files
      SUBROUTINE CR2DFT(FNAME, IMAGE, NAXIS1, NAXIS2,
     &                        BITPIX, BSCALE, BZERO)
      IMPLICIT NONE
      CHARACTER*(*) FNAME
      INTEGER NAXIS1, NAXIS2, BITPIX,NAXES(2)
      CHARACTER*1 IMAGE(NAXIS1, NAXIS2)
      REAL BSCALE, BZERO
      INTEGER STATUS, OUNIT, BLOCKSIZE, FPIXEL, GROUP, NELEMENTS
      LOGICAL SIMPLE, EXTEND
      LOGICAL DEBUG
      BLOCKSIZE=1
      FPIXEL=1
      GROUP=1       
      STATUS = 0
      SIMPLE = .TRUE.
      DEBUG = .TRUE.
      EXTEND = .FALSE.
      NAXES(1)=NAXIS1
      NAXES(2)=NAXIS2

      call ftgiou(ounit,status)

C     Create new FITS file
      CALL FTINIT(OUNIT, FNAME, BLOCKSIZE, STATUS)
      IF (STATUS .NE. 0) THEN
          WRITE(*,*) 'Error creating output file: ', FNAME
          CALL PRINTERROR(STATUS)
          RETURN
      ENDIF

C     Write primary header
      CALL FTPHPR(OUNIT, SIMPLE, BITPIX, 2, NAXES,
     &            0, 0, EXTEND, STATUS)
      
C     Write additional header keywords
      CALL FTPKYF(OUNIT, 'DATAMAX', 255.0, 1,
     &            'Maximum data value', STATUS)
      CALL FTPKYF(OUNIT, 'DATAMIN', 0.0, 1,
     &            'Minimum data value', STATUS)
      CALL FTPHIS(OUNIT, 'Extracted from 3D FITS file', STATUS)

C     Write image data
      NELEMENTS = NAXIS1 * NAXIS2
      STATUS=0
      IF (DEBUG) WRITE(*,*)'writing image data'      
      CALL FTPPRB(OUNIT, GROUP, FPIXEL, NELEMENTS, IMAGE, STATUS)

C     Close the file
      CALL FTCLOS(OUNIT, STATUS)
      call ftfiou(ounit, status)
      IF (STATUS .NE. 0) THEN
          WRITE(*,*) 'Error writing file: ', FNAME
          CALL PRINTERROR(STATUS)
      ELSE
          WRITE(*,*) 'Successfully created: ', FNAME
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
