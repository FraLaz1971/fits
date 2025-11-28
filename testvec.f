      program tstvec
        integer i,n,nmax,myivec(10)
        real myrvec(10)
        character*10 str(10)
        data str /10*' '/
	    data myrvec(1)/0.1/,myrvec(2)/10.678/,myrvec(3)/-567.0/,
     1   myrvec(4)/-1025.76/,myrvec(5)/12.8/,myrvec(6)/21000.5/,
     2   myrvec(7)/0.0/,myrvec(8)/0.0/,myrvec(9)/0.0/,myrvec(10)/0.0/
	    data myivec(1)/0/,myivec(2)/10/,myivec(3)/-567/,
     1   myivec(4)/1025/,myivec(5)/13/,myivec(6)/21000/,
     2   myivec(7)/0/,myivec(8)/0/,myivec(9)/0/,myivec(10)/0/
        nmax=6
        do 10,i=1,nmax
	      write(str(i),100) myrvec(i)
10      continue
        write(str(i),'(A)') ' '
        print *,str
        print *
        do 20,i=1,nmax
	      write(str(i),200) myivec(i)
20      continue
        write(str(i),'(A)') ' '
        print *,str
        print *
        n=nmax
30      if (n.le.0) goto 40
	      write(str(i),200) myivec(nmax-n+1)
          n = n-1
        goto 30
40      continue
        write(str(i),'(A)') ' '
        print *,str
        print *
        stop
100     format(F9.2,1X,:)
200     format(I6,1X,:)
      end
