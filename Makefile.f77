FC=f77 -g
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
wiuchar$(OEXT): wiuchar.f
	$(FC) -c $<
wiuchar$(EEXT): wiuchar$(OEXT)
	$(FD) -o $@ $^ $(FDFLAGS) $(LIBS)
test32d$(OEXT): test32d.f
	$(FC) -c $<
test32d$(EEXT): test32d$(OEXT)
	$(FD) -o $@ $^ $(FDFLAGS) $(LIBS)
clean:
	$(RM) *.o writeimage$(EEXT) image*.fits m31sl*.fits
