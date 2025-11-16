FC=f77
FD=f77
FFLAG=
FDFLAGS=-L$(CFITSIO_HOME)
LIBS=-lcfitsio
RM=rm -rf
OEXT=.o
EEXT=
.PHONY: all clean
all: writeimage$(EEXT)

writeimage$(OEXT): writeimage.f
	$(FC) -c $<
writeimage$(EEXT): writeimage$(OEXT)
	$(FD) -o $@ $^ $(FDFLAGS) $(LIBS)
clean: writeimage$(EEXT)
	$(RM) *.o writeimage$(EEXT)	
