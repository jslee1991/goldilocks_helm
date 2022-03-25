##################################################################
# sample
#
##################################################################

CPP = g++
CFLAGS = -g -Wall

INC = -I$(GOLDILOCKS_HOME)/include
LFLAGS = -L$(GOLDILOCKS_HOME)/lib

LIB = -lgoldilocksesql -lpthread -ldl -lm -lrt
ifeq ($(CSMODE), 1)
    LIB += -lgoldilocksc
else
    ifeq ($(MIXMODE), 1)
        LIB += -lgoldilocks
    else
        LIB += -lgoldilocksa
    endif
endif

GPEC = gpec
GPECFLAGS = 
#GPECFLAGS = --unsafe-null --no-prompt

TARGET_OVERVIEW = overview
OBJECT_OVERVIEW = overview.o dbConn.o

##################################################################
# implicit rules
##################################################################
.SUFFIXES: .gc .cpp

.gc.cpp:
	$(GPEC) $(GPECFLAGS) --output=$@ $^

.cpp.o:
	$(CPP) $(CFLAGS) -c $(INC) $^

##################################################################
# build rules
##################################################################

all : $(TARGET_OVERVIEW)

$(TARGET_OVERVIEW) : $(OBJECT_OVERVIEW)
	$(CPP) -o $(TARGET_OVERVIEW) $(OBJECT_OVERVIEW) $(LFLAGS) $(LIB)

overview.cpp: overview.gc
dbConn.cpp: dbConn.gc

clean :
	rm -rf $(TARGET_OVERVIEW) $(OBJECT_OVERVIEW)
