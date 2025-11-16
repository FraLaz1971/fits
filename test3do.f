      program tst3do
	integer i,j,k,naxis1,naxis2,naxis3
	parameter(naxis1=1280,naxis2=1267,naxis3=3)
	do 10,k=1,naxis3
	  do 20,j=1,naxis2
	    do 30,i=1,naxis1
	      print *,i,j,k
30          continue
20	  continue
10	continue
      end
