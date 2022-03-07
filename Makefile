CC := /usr/bin/gcc
TARGET := lsenum
SRC := lsenum.c
INSTALLDIR := /usr/local/bin

all:
	$(CC) -o $(TARGET) $(SRC)


install:
	cp -p $(TARGET) $(INSTALLDIR) 


.PHONY:
clean:
	rm ./lsenum 
