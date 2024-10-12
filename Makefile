CC := /usr/bin/g++
TARGET := lsenum
SRC := lsenum.cc
INSTALLDIR := /usr/local/bin

all:
	$(CC) -o $(TARGET) $(SRC)


install:
	cp -p $(TARGET) $(INSTALLDIR) 


.PHONY:
clean:
	rm ./lsenum 
