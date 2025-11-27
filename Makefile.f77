FC=f77 -g
FD=f77 
FFLAG=
#CFITSIO_HOME=C:\cfitsio
FDFLAGS=-L$(CFITSIO_HOME)/lib
LIBS=-lcfitsio
RM=rm -rf
OEXT=.o
EEXT=
.PHONY: all clean
all: writeimage$(EEXT) writeimagef$(EEXT) wiuchar$(EEXT) test32d$(EEXT) \
	img3Dto2Dimg$(EEXT) img3Dto2Dimg2$(EEXT)

writeimage$(OEXT): writeimage.f
	$(FC) -c $<
writeimage$(EEXT): writeimage$(OEXT)
	$(FD) -o $@ $^ $(FDFLAGS) $(LIBS)
writeimagef$(OEXT): writeimagef.f
	$(FC) -c $<
writeimagef$(EEXT): writeimagef$(OEXT)
	$(FD) -o $@ $^ $(FDFLAGS) $(LIBS)
wiuchar$(OEXT): wiuchar.f
	$(FC) -c $<
wiuchar$(EEXT): wiuchar$(OEXT)
	$(FD) -o $@ $^ $(FDFLAGS) $(LIBS)
test32d$(OEXT): test32d.f
	$(FC) -c $<
img3Dto2Dimg$(OEXT): img3Dto2Dimg.f
	$(FC) -c $<
img3Dto2Dimg$(EEXT): img3Dto2Dimg$(OEXT)
	$(FD) -o $@ $^ $(FDFLAGS) $(LIBS)
img3Dto2Dimg2$(OEXT): img3Dto2Dimg2.f
	$(FC) -c $<
img3Dto2Dimg2$(EEXT): img3Dto2Dimg2$(OEXT)
	$(FD) -o $@ $^ $(FDFLAGS) $(LIBS)
test32d$(EEXT): test32d$(OEXT)
	$(FD) -o $@ $^ $(FDFLAGS) $(LIBS)
clean:
	$(RM) *.o writeimage$(EEXT) writeimagef$(EEXT) wiuchar$(EEXT) test32d$(EEXT) \
	img3Dto2Dimg$(EEXT) img3Dto2Dimg2$(EEXT) image*.fits m31sl*.fits
