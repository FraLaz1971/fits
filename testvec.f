      program tstv
        integer i,nmax
        parameter(nmax=6)
        real rvec(10)/-1.0,17.123,-10000.12,-177.99
     &  ,66.77,-1023.54,65.2,-2.3,-77.1989,99.2/
        do 10,i=1,nmax
          print 500,rvec(i)
10      continue
      stop
500   format(F10.3,1X,$)
      end
