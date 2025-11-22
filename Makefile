CC=gcc -g -O2
LD=gcc
.PHONY: all clean
CFLAGS=-I$(CFITSIO_HOME)/include
LDFLAGS=-L$(CFITSIO_HOME)/lib
LIBS=-lcfitsio
OEXT=.o
EEXT=
RM=rm -f
all: writefimage$(EEXT) readfimage$(EEXT) writeftable$(EEXT) addfbtable$(EEXT) writefits$(EEXT) testf1$(EEXT) \
testf2$(EEXT) testf3$(EEXT) createimage$(EEXT) createimageblock$(EEXT) createimagepbyp$(EEXT) changekeys$(EEXT)

fimage(OEXT): fimage.c fimage.h
	$(CC)  $(CFLAGS) -c $<

readfimage(OEXT): readfimage.c fimage.h
	$(CC)  $(CFLAGS) -c $<

plotfimage(OEXT): plotfimage.c fimage.h
	$(CC)  $(CFLAGS) -c $<

createimage(OEXT): createimage.c fimage.h
	$(CC)  $(CFLAGS) -c $<

createimagepbyp(OEXT): createimagepbyp.c fimage.h
	$(CC)  $(CFLAGS) -c $<

createimageblock(OEXT): createimageblock.c fimage.h
	$(CC)  $(CFLAGS) -c $<

testf2(OEXT): testf2.c fimage.h
	$(CC)  $(CFLAGS) -c $<

testf3(OEXT): testf3.c fimage.h
	$(CC)  $(CFLAGS) -c $<

writefimage(OEXT): writefimage.c fimage.h
	$(CC)  $(CFLAGS) -c $<

writefits(OEXT): writefits.c fimage.h
	$(CC)  $(CFLAGS) -c $<

writeftable(OEXT): writeftable.c fimage.h
	$(CC)  $(CFLAGS) -c $<

addfbtable(OEXT): addfbtable.c fimage.h
	$(CC)  $(CFLAGS) -c $<

changekeys(OEXT): changekeys.c fimage.h
	$(CC)  $(CFLAGS) -c $<

readfimage$(EEXT): readfimage$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

plotfimage$(EEXT): plotfimage$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

testf1$(EEXT): testf1$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

testf2$(EEXT): testf2$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

testf3$(EEXT): testf3$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

writefimage$(EEXT): writefimage$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

createimage$(EEXT): createimage$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

createimagepbyp$(EEXT): createimagepbyp$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

createimageblock$(EEXT): createimageblock$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

writefits$(EEXT): writefits$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

writeftable$(EEXT): writeftable$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

addfbtable$(EEXT): addfbtable$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

changekeys$(EEXT): changekeys$(OEXT) fimage$(OEXT)
	$(CC)  $^ -o $@ $(LDFLAGS) $(LIBS)

clean:
	$(RM) *.o writefimage$(EEXT) readfimage$(EEXT) writeftable$(EEXT) addfbtable$(EEXT) writefits$(EEXT) testf1$(EEXT) \
testf2$(EEXT) testf3$(EEXT) createimage$(EEXT) createimageblock$(EEXT) createimagepbyp$(EEXT) changekeys$(EEXT)
