      program tstd
        character*80 myword
        open(unit=99, file='err.log', status='unknown')  
        write(*,*)'err.log enter a word'
	    read(*,*)myword
	    write(*,*)'stdout: the program is ended'
	    write(*,*)'stdout: * is the same as 2'
	    write(99,*)'err.log: error messages can go on a log file'
        close(99)
      end
