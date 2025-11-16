C 
      PROGRAM I3D22D
      IMPLICIT NONE
      INTEGER BITPIX, NAXIS, NAXIS1, NAXIS2, NAXIS3
      INTEGER STATUS, IUNIT, OUNIT1, OUNIT2, OUNIT3
      INTEGER BLOCKSIZE, FPIXEL, NELEMENTS, GROUP
      PARAMETER (BLOCKSIZE=1, FPIXEL=1, GROUP=1)
      REAL BSCALE, BZERO
      LOGICAL SIMPLE, EXTEND
      CHARACTER*80 FNAME, OUTFILE1, OUTFILE2, OUTFILE3
      
      CHARACTER*1 IMAGE3D(12000000)
      CHARACTER*1 IMAGE2D(2000,2000)
      
      DATA FNAME /'m31.fits'/
      DATA OUTFILE1 /'m31sl1.fits'/
      DATA OUTFILE2 /'m31sl2.fits'/
      DATA OUTFILE3 /'m31sl3.fits'/
      DATA STATUS /0/

C     Get FITS file parameters from your header
      NAXIS1 = 1280
      NAXIS2 = 1267  
      NAXIS3 = 3
      BITPIX = 8
      BSCALE = 1.0
      BZERO = 0.0
      SIMPLE = .TRUE.


C     Open input FITS file
      CALL FTOPEN(IUNIT, FNAME, 0, BLOCKSIZE, STATUS)
      IF (STATUS .NE. 0) THEN
          WRITE(*,*) 'Error opening input file'
          CALL PRINTERR(STATUS)
          STOP
      ENDIF

C     Read the 3D image data
      NELEMENTS = NAXIS1 * NAXIS2 * NAXIS3
      CALL FTGPVB(IUNIT, GROUP, FPIXEL, NELEMENTS, 
     &            BZERO, BSCALE, IMAGE3D, ANYF, STATUS)
      IF (STATUS .NE. 0) THEN
          WRITE(*,*) 'Error reading 3D data'
          CALL PRINTERR(STATUS)
          STOP
      ENDIF

C     Close input file
      CALL FTCLOS(IUNIT, STATUS)

C     Extract and save first slice (z=1)
      DO 100 J = 1, NAXIS2
          DO 200 I = 1, NAXIS1
              IMAGE2D(I,J) = IMAGE3D(I*NAXIS2+J,0*NAXIS1*NAXIS2)
200     CONTINUE
100   CONTINUE
      
      CALL CR2DFT(OUTFILE1, IMAGE2D, NAXIS1, NAXIS2, 
     &                  BITPIX, BSCALE, BZERO)

C     Extract and save second slice (z=2)
      DO 300 J = 1, NAXIS2
          DO 400 I = 1, NAXIS1
              IMAGE2D(I,J) = IMAGE3D(I,J,2)
  400     CONTINUE
  300 CONTINUE
      
      CALL CR2DFT(OUTFILE2, IMAGE2D, NAXIS1, NAXIS2,
     &                  BITPIX, BSCALE, BZERO)

C     Extract and save third slice (z=3)
      DO 500 J = 1, NAXIS2
          DO 600 I = 1, NAXIS1
              IMAGE2D(I,J) = IMAGE3D(I,J,3)
  600     CONTINUE
  500 CONTINUE
      
      CALL CR2DFT(OUTFILE3, IMAGE2D, NAXIS1, NAXIS2,
     &                  BITPIX, BSCALE, BZERO)

C     Clean up
      DEALLOCATE(IMAGE3D, IMAGE2D)
      WRITE(*,*) '3D FITS file successfully split into 3 2D images'
      STOP
      END

C     Subroutine to create 2D FITS files
      SUBROUTINE CR2DFT(FNAME, IMAGE, NAXIS1, NAXIS2,
     &                        BITPIX, BSCALE, BZERO)
      IMPLICIT NONE
      CHARACTER*(*) FNAME
      INTEGER NAXIS1, NAXIS2, BITPIX
      CHARACTER*1 IMAGE(NAXIS1, NAXIS2)
      REAL BSCALE, BZERO
      
      INTEGER STATUS, OUNIT, BLOCKSIZE, FPIXEL, GROUP, NELEMENTS
      PARAMETER (BLOCKSIZE=1, FPIXEL=1, GROUP=1)
      LOGICAL SIMPLE, EXTEND
      
      STATUS = 0
      SIMPLE = .TRUE.
      EXTEND = .FALSE.

C     Create new FITS file
      CALL FTINIT(OUNIT, FNAME, BLOCKSIZE, STATUS)
      IF (STATUS .NE. 0) THEN
          WRITE(*,*) 'Error creating output file: ', FNAME
          CALL PRINTERR(STATUS)
          RETURN
      ENDIF

C     Write primary header
      CALL FTPHPR(OUNIT, SIMPLE, BITPIX, 2, [NAXIS1, NAXIS2],
     &            0, 0, EXTEND, STATUS)
      
C     Write additional header keywords
      CALL FTPKYE(OUNIT, 'BSCALE', BSCALE, 10, 
     &            'Data scaling factor', STATUS)
      CALL FTPKYE(OUNIT, 'BZERO', BZERO, 10,
     &            'Data zero point', STATUS)
      CALL FTPKYF(OUNIT, 'DATAMAX', 255.0, 1,
     &            'Maximum data value', STATUS)
      CALL FTPKYF(OUNIT, 'DATAMIN', 0.0, 1,
     &            'Minimum data value', STATUS)
      CALL FTPHIS(OUNIT, 'Extracted from 3D FITS file', STATUS)

C     Write image data
      NELEMENTS = NAXIS1 * NAXIS2
      CALL FTPPRI(OUNIT, GROUP, FPIXEL, NELEMENTS, IMAGE, STATUS)

C     Close the file
      CALL FTCLOS(OUNIT, STATUS)
      
      IF (STATUS .NE. 0) THEN
          WRITE(*,*) 'Error writing file: ', FNAME
          CALL PRINTERR(STATUS)
      ELSE
          WRITE(*,*) 'Successfully created: ', FNAME
      ENDIF
      
      RETURN
      END
