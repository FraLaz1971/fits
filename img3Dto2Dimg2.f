C 
      PROGRAM I3D22D
      IMPLICIT NONE
      INTEGER BITPIX, NAXIS, NAXIS1, NAXIS2, NAXIS3, NAXES(3)
      INTEGER STATUS, IUNIT, OUNIT, I, J, POSI
      INTEGER BLOCKSIZE, FPIXEL, NELEMENTS, GROUP, NFOUND
      REAL BSCALE, BZERO
      LOGICAL SIMPLE, EXTEND
      LOGICAL DEBUG
      CHARACTER*80 FNAME, OUTFILE1, OUTFILE2, OUTFILE3, COMM      
      CHARACTER*1 IMAGE3D(14701344)
      CHARACTER*1 IMAGE2D(2096,2338)
      CHARACTER*1 NULLVAL
      CHARACTER*1 CTF
      LOGICAL ANYF
      DATA STATUS /0/
      DATA DEBUG /.TRUE./
      PRINT *,'ENTER THE NAME OF THE INPUT 3D IMAGE FILE'
      READ(*,*) FNAME
C     CREATE THE 3 OUTPUT FILE NAMES
      ctf='.'
      posi=index(FNAME,ctf)-1
      write(*,*) 'POSI = ',POSI
      write(OUTFILE1,'(A,A)') FNAME(1:posi),'_sl1.fits'
      write(OUTFILE2,'(A,A)') FNAME(1:posi),'_sl2.fits'
      write(OUTFILE3,'(A,A)') FNAME(1:posi),'_sl3.fits'
      write(*,*) 'OUTFILE1 = ',OUTFILE1
      write(*,*) 'OUTFILE2 = ',OUTFILE2
      write(*,*) 'OUTFILE3 = ',OUTFILE3
C     Get FITS file parameters from your header
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
      call ftgknj(iunit,'NAXIS',1,4,naxes,nfound,status)
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
      IF (DEBUG) WRITE(*,*)'NAXIS = ',NAXIS,' NAXES(1) ',NAXES(1),
     & 'NAXES(2) ',NAXES(2),'NAXES(3) ',NAXES(3)
      NAXIS1 = NAXES(1)  
      NAXIS2 = NAXES(2)  
      NAXIS3 = NAXES(3)  
c read the BITPIX KEYWORD FROM THE HEADER OF THE INPUT FILE
      call ftgkyj(iunit,'BITPIX',bitpix,comm,status)
      IF (DEBUG) WRITE(*,*)'BITPIX = ',BITPIX,' ',COMM
      call ftgkye(iunit,'BSCALE',BSCALE,comm,status)
      IF (DEBUG) WRITE(*,*)'BSCALE = ',BSCALE,' ',COMM
      call ftgkye(iunit,'BZERO',BZERO,comm,status)
      IF (DEBUG) WRITE(*,*)'BZERO = ',BZERO,' ',COMM
C     Read the 3D image data
      NELEMENTS = NAXIS1 * NAXIS2 * NAXIS3
      STATUS = 0
      CALL FTGPVB(IUNIT, GROUP, FPIXEL, NELEMENTS, 
     &            NULLVAL, IMAGE3D, ANYF, STATUS)
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
      CALL deletefile(OUTFILE1,status)
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
      
      CALL deletefile(OUTFILE2,status)
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
    
      CALL deletefile(OUTFILE3,status)
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
      subroutine readheader(filename)

C  Print out all the header keywords in all extensions of a FITS file

      integer status,unit,readwrite,blocksize,nkeys,nspace,hdutype,i,j
      character filename*80,record*80
      common /config/ BITPIX,NAXIS,NAXES(3)

C  The STATUS parameter must always be initialized.
      status=0

C  Get an unused Logical Unit Number to use to open the FITS file.
      call ftgiou(unit,status)

C     name of FITS file is coming as subroutine parameter

C     open the FITS file, with read-only access.  The returned BLOCKSIZE
C     parameter is obsolete and should be ignored. 
      readwrite=0
      call ftopen(unit,filename,readwrite,blocksize,status)

      j = 0
100   continue
      j = j + 1

      WRITE(*,*)'Header listing for HDU', j

C  The FTGHSP subroutine returns the number of existing keywords in the
C  current header data unit (CHDU), not counting the required END keyword,
      call ftghsp(unit,nkeys,nspace,status)
      WRITE(*,*)'there are ',nkeys,'keywords'
C  Read each 80-character keyword record, and print it out.
      do i = 1, nkeys
          call ftgrec(unit,i,record,status)
          WRITE(*,*) record
      end do

C  Print out an END record, and a blank line to mark the end of the header.
      if (status .eq. 0)then
          WRITE(*,*)'END'
          WRITE(*,*)' '
      end if

C  Try moving to the next extension in the FITS file, if it exists.
C  The FTMRHD subroutine attempts to move to the next HDU, as specified by
C  the second parameter.   This subroutine moves by a relative number of
C  HDUs from the current HDU.  The related FTMAHD routine may be used to
C  move to an absolute HDU number in the FITS file.  If the end-of-file is
C  encountered when trying to move to the specified extension, then a
C  status = 107 is returned.
      call ftmrhd(unit,1,hdutype,status)

      if (status .eq. 0)then
C         success, so jump back and print out keywords in this extension
          go to 100

      else if (status .eq. 107)then
C         hit end of file, so quit
          WRITE(*,*)'file ends after current:',J,'HDU'
          status=0
      end if

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

C  Free the unit number for later reuse
      call ftfiou(unit, status)
      end
