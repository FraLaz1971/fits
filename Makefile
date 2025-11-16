CC=gcc
LD=gcc
.PHONY: all clean
CFLAGS=-I$(CFITSIO_HOME)
LDFLAGS=-L$(CFITSIO_HOME)
LIBS=-lcfitsio -lm
OEXT=.o
EEXT=
RM=rm -f
all: writefimage$(EEXT) readfimage$(EEXT) writeftable$(EEXT) addfbtable$(EEXT) fimage2bin$(EEXT)

fimage(OEXT): fimage.c fimage.h
	$(CC) -c $(CFLAGS) $<

readfimage(OEXT): readfimage.c fimage.h
	$(CC) -c $(CFLAGS) $<

fimage2bin(OEXT): fimage2bin.c fimage.h
	$(CC) -c $(CFLAGS) $<

writefimage(OEXT): writefimage.c fimage.h
	$(CC) -c $(CFLAGS) $<

writeftable(OEXT): writeftable.c fimage.h
	$(CC)  $(CFLAGS) -c $<

addfbtable(OEXT): addfbtable.c fimage.h
	$(CC)  $(CFLAGS) -c $<

readfimage$(EEXT): readfimage$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

fimage2bin$(EEXT): fimage2bin$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

writefimage$(EEXT): writefimage$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

writeftable$(EEXT): writeftable$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

addfbtable$(EEXT): addfbtable$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)
clean:
	$(RM) *.o writefimage$(EEXT) readfimage$(EEXT) writeftable$(EEXT) addfbtable$(EEXT) fimage2bin$(EEXT)

