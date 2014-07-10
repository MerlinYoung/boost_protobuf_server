#############################################################  
# Generic Makefile for C/C++ Program  
#  
# License: GPL (General Public License)  
# Author:  merlinyoung@126.com  
#  
# Description:  
# ------------  
# This is an easily customizable makefile template. The purpose is to  
# provide an instant building environment for C/C++ programs.  
#  
# It searches all the C/C++ source files in the specified directories,  
# makes dependencies, compiles and links to form an executable.  
#  
# Besides its default ability to build C/C++ programs which use only  
# standard C/C++ libraries, you can customize the Makefile to build  
# those using other libraries. Once done, without any changes you can  
# then build programs using the same or less libraries, even if source  
# files are renamed, added or removed. Therefore, it is particularly  
# convenient to use it to build codes for experimental or study use.  
#  
# GNU make is expected to use the Makefile. Other versions of makes  
# may or may not work.  
#  
# Make Target:  
# ------------  
# The Makefile provides the following targets to make:  
#   $ make		   compile and link  
#   $ make NODEP=yes compile and link without generating dependencies  
#   $ make objs	  compile only (no linking)  
#   $ make tags	  create tags for Emacs editor  
#   $ make ctags	 create ctags for VI editor  
#   $ make clean	 clean objects and the executable file  
#   $ make distclean clean objects, the executable and dependencies  
#   $ make help	  get the usage of the makefile  
#  
#===========================================================================  
  
## Customizable Section: adapt those variables to suit your program.  
##==========================================================================  

# The C program compiler.  
#CC	 = gcc  
  
# The C++ program compiler.  
#CXX	= g++  
  
# Un-comment the following line to compile C programs as C++ ones.  
#CC	 = $(CXX)  
  
# The command used to delete file.  
#RM	 = rm -f  
  
# The pre-processor and compiler options.  
# Users can override those variables from the command line.  
CFLAGS  = -g -O2 -std=c11 
CXXFLAGS= -g -O2 -std=c++11
  
# The options used in linking as well as in any direct use of ld.  
LDFLAGS   =  

LIBS = -lboost_system -lprotobuf
# The directories in which source files reside.  
# If not specified, only the current directory will be serached.  
SRCDIRS   =  
  
# The executable file name.  
# If not specified, current directory name or `a.out' will be used.  
PROGRAM   =  
  
## Implicit Section: change the following only when necessary.  
##==========================================================================  
  
# The source file types (headers excluded).  
# .c indicates C source files, and others C++ ones.  
SRCEXTS = .c .C .cc .cpp .CPP .c++ .cxx .cp  
  
# The header file types.  
HDREXTS = .h .H .hh .hpp .HPP .h++ .hxx .hp  
  
  
ETAGS = etags  
ETAGSFLAGS =  
  
CTAGS = ctags  
CTAGSFLAGS =  
  
## Stable Section: usually no need to be changed. But you can add more.  
##==========================================================================  
SHELL   = /bin/sh  
EMPTY   =  
SPACE   = $(EMPTY) $(EMPTY)  
ifeq ($(PROGRAM),)  
  CUR_PATH_NAMES = $(subst /,$(SPACE),$(subst $(SPACE),_,$(CURDIR)))  
  PROGRAM = $(word $(words $(CUR_PATH_NAMES)),$(CUR_PATH_NAMES))  
  ifeq ($(PROGRAM),)  
	PROGRAM = a.out  
  endif  
endif  
ifeq ($(SRCDIRS),)  
  SRCDIRS = .  
endif  
PROTOS = $(wildcard *.proto)
PROTOHS = $(patsubst %.proto,%.pb.h, $(PROTOS))
PROTOCS = $(patsubst %.proto,%.pb.cc, $(PROTOS))
#JCE_SRC     := $(wildcard *.jce)
#JCE_H       := $(patsubst %.jce,%.h, $(JCE_SRC))
#JCE_CPP     := $(patsubst %.jce,%.cpp, $(JCE_INTER))
SOURCES = $(foreach d,$(SRCDIRS),$(wildcard $(addprefix $(d)/*,$(SRCEXTS))))  
HEADERS = $(foreach d,$(SRCDIRS),$(wildcard $(addprefix $(d)/*,$(HDREXTS))))  
SRC_CXX = $(filter-out %.c,$(SOURCES))  
OBJS	= $(addsuffix .o, $(basename $(SOURCES)))  
#DEPS	= $(OBJS:.o=.d)  
DEPS	= $(foreach tmp,$(OBJS:.o=.d),$(dir $(tmp)).$(notdir $(tmp)))
    
## Define some useful variables.  
DEP_OPT = $(shell if `$(CC) --version | grep "GCC" >/dev/null`; then \
	echo "-MM "; else echo "-M"; fi )  
DEPEND	  = $(CC)  $(DEP_OPT)  $(CXXFLAGS)  
DEPEND.d	= $(subst -g ,,$(DEPEND))  
COMPILE.c   = $(CC) $(CFLAGS) -c  
COMPILE.cxx = $(CXX) $(CXXFLAGS) -c  
LINK.c	  = $(CC)  $(LDFLAGS)  
LINK.cxx	= $(CXX) $(LDFLAGS)  
  
.PHONY: all objs tags ctags clean distclean help show  
  
# Delete the default suffixes  
.SUFFIXES:  
  
all: $(PROTOHS) $(PROTOCS) $(PROGRAM)  

# Rules for creating protobuf
# -----------------------------------------
$(PROTOHS):$(PROTOS)
	@echo parse $@ ...
	protoc --cpp_out=./ $<

# Rules for creating dependency files (.d).  
#------------------------------------------  
  
.%.d:%.c
	@echo build $@ ...    
	@echo -n $(dir $<) > $@  
	@$(DEPEND.d) $< >> $@  
  
.%.d:%.C  
	@echo build $@ ...    
	@echo -n $(dir $<) > $@  
	@$(DEPEND.d) $< >> $@  
  
.%.d:%.cc  
	@echo build $@ ...    
	@echo -n $(dir $<) > $@  
	@$(DEPEND.d) $< >> $@  
  
.%.d:%.cpp  
	@echo build $@ ...    
	@echo -n $(dir $<) > $@  
	@$(DEPEND.d) $< >> $@  
  
.%.d:%.CPP  
	@echo build $@ ...    
	@echo -n $(dir $<) > $@  
	@$(DEPEND.d) $< >> $@  
  
.%.d:%.c++  
	@echo build $@ ...    
	@echo -n $(dir $<) > $@  
	@$(DEPEND.d) $< >> $@  
  
.%.d:%.cp  
	@echo build $@ ...    
	@echo -n $(dir $<) > $@  
	@$(DEPEND.d) $< >> $@  
  
.%.d:%.cxx  
	@echo build $@ ...    
	@echo -n $(dir $<) > $@  
	@$(DEPEND.d) $< >> $@  
  
# Rules for generating object files (.o).  
#----------------------------------------  
objs:$(OBJS)  
  
%.o:%.c  
	$(COMPILE.c) $< -o $@  
  
%.o:%.C  
	$(COMPILE.cxx) $< -o $@  
  
%.o:%.cc  
	$(COMPILE.cxx) $< -o $@  
  
%.o:%.cpp  
	$(COMPILE.cxx) $< -o $@  
  
%.o:%.CPP  
	$(COMPILE.cxx) $< -o $@  
  
%.o:%.c++  
	$(COMPILE.cxx) $< -o $@  
  
%.o:%.cp  
	$(COMPILE.cxx) $< -o $@  
  
%.o:%.cxx  
	$(COMPILE.cxx) $< -o $@  
  
# Rules for generating the tags.  
#-------------------------------------  
tags: $(HEADERS) $(SOURCES)  
	$(ETAGS) $(ETAGSFLAGS) $(HEADERS) $(SOURCES)  
  
ctags: $(HEADERS) $(SOURCES)  
	$(CTAGS) $(CTAGSFLAGS) $(HEADERS) $(SOURCES)  
  
# Rules for generating the executable.  
#-------------------------------------  
$(PROGRAM):$(OBJS)  
ifeq ($(SRC_CXX),)			  # C program  
	$(LINK.c)   $(OBJS) $(LIBS) -o $@  
	@echo Type ./$@ to execute the program.  
else							# C++ program  
	$(LINK.cxx) $(OBJS) $(LIBS) -o $@  
	@echo Type ./$@ to execute the program.  
endif  
  
  
clean:  
	$(RM) $(OBJS) $(PROGRAM) $(PROGRAM).exe  
  
distclean: clean  
	$(RM) $(DEPS) $(PROTOHS) $(PROTOCS)  
  
# Show help.  
help:  
	@echo 'Generic Makefile for C/C++ Programs (gcmakefile) version 0.5'  
	@echo 'Copyright (C) 2007, 2008 whyglinux <whyglinux@hotmail.com>'  
	@echo  
	@echo 'Usage: make [TARGET]'  
	@echo 'TARGETS:'  
	@echo '  all	   (=make) compile and link.'  
	@echo '  NODEP=yes make without generating dependencies.'  
	@echo '  objs	  compile only (no linking).'  
	@echo '  tags	  create tags for Emacs editor.'  
	@echo '  ctags	 create ctags for VI editor.'  
	@echo '  clean	 clean objects and the executable file.'  
	@echo '  distclean clean objects, the executable and dependencies.'  
	@echo '  show	  show variables (for debug use only).'  
	@echo '  help	  print this message.'  
	@echo  
	@echo 'Report bugs to <whyglinux AT gmail DOT com>.'  
  
# Show variables (for debug use only.)  
show:  
	@echo 'PROGRAM	 :' $(PROGRAM)  
	@echo 'SRCDIRS	 :' $(SRCDIRS)  
	@echo 'PROTOS	 :' $(PROTOS)  
	@echo 'PROTOHS	 :' $(PROTOHS)  
	@echo 'PROTOCS	 :' $(PROTOCS)  
	@echo 'HEADERS	 :' $(HEADERS)  
	@echo 'SOURCES	 :' $(SOURCES)  
	@echo 'SRC_CXX	 :' $(SRC_CXX)  
	@echo 'OBJS		:' $(OBJS)  
	@echo 'DEPS		:' $(DEPS)  
	@echo 'DEPEND	  :' $(DEPEND)  
	@echo 'COMPILE.c   :' $(COMPILE.c)  
	@echo 'COMPILE.cxx :' $(COMPILE.cxx)  
	@echo 'link.c	  :' $(LINK.c)  
	@echo 'link.cxx	:' $(LINK.cxx)  
  
ifndef NODEP  
ifneq ($(DEPS),)  
  -include $(DEPS)  
endif  
endif  
## End of the Makefile ##  Suggestions are welcome  ## All rights reserved ##  
##############################################################  
