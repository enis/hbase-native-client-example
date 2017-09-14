# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

#use "g++" to compile source files
CC := g++
LD := g++

BUILD_PATH := build
DEBUG_PATH := $(BUILD_PATH)/debug
RELEASE_PATH := $(BUILD_PATH)/release
SRC_DIR := .
DEBUG_BUILD_DIR := $(DEBUG_PATH)/
RELEASE_BUILD_DIR := $(RELEASE_PATH)/
LOCAL_INCLUDE_DIR := /usr/local/include

INCLUDE_DIR := $(SRC_DIR) $(LOCAL_INCLUDE_DIR)

DEBUG_LINK_LIB = -lHBaseClient_d
RELEASE_LINK_LIB = -lHBaseClient

#flags to pass to the CPP compiler & linker
CPPFLAGS_DEBUG := -D_GLIBCXX_USE_CXX11_ABI=0 -g -Wall -std=c++14 -pedantic -fPIC -MMD -MP
CPPFLAGS_RELEASE := -D_GLIBCXX_USE_CXX11_ABI=0 -DNDEBUG -O2 -Wall -std=c++14 -pedantic -fPIC -MMD -MP
LDFLAGS := -lprotobuf -lzookeeper_mt -lsasl2 -lfolly -lwangle
LINKFLAG := -shared

#define list of source files and object files
ALLSRC := $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.cc))
SRC := $(ALLSRC)
DEBUG_OBJ := $(patsubst %.cc,$(DEBUG_PATH)/%.o,$(SRC))
RELEASE_OBJ := $(patsubst %.cc,$(RELEASE_PATH)/%.o,$(SRC))
INCLUDES := $(addprefix -I,$(INCLUDE_DIR))

#define load-client
LOAD_CLIENT_SRC = load-client.cc
LOAD_CLIENT_DEBUG_OBJ = $(patsubst %.cc,$(DEBUG_PATH)/%.o,$(LOAD_CLIENT_SRC))
LOAD_CLIENT_RELEASE_OBJ = $(patsubst %.cc,$(RELEASE_PATH)/%.o,$(LOAD_CLIENT_SRC))
LOAD_CLIENT_DEBUG = $(DEBUG_PATH)/load_client_d
LOAD_CLIENT_RELEASE =  $(RELEASE_PATH)/load_client

build: checkdirs $(LOAD_CLIENT_DEBUG) $(LOAD_CLIENT_RELEASE)

vpath %.cc $(SRC_DIR)

$(DEBUG_BUILD_DIR)/load-client.o: load-client.cc
	$(CC) -c load-client.cc -o $(DEBUG_BUILD_DIR)/load-client.o -MMD -MP -MT$$@ $(CPPFLAGS_DEBUG) $(INCLUDES)
$(LOAD_CLIENT_DEBUG): $(DEBUG_BUILD_DIR)/load-client.o
	$(CC) $^ -o $@ $(LDFLAGS_DEBUG) $(DEBUG_LINK_LIB)

$(RELEASE_BUILD_DIR)/load-client.o: load-client.cc
	$(CC) -c load-client.cc -o $(RELEASE_BUILD_DIR)/load-client.o -MMD -MP -MT$$@ $(CPPFLAGS_RELEASE) $(INCLUDES)
$(LOAD_CLIENT_RELEASE): $(RELEASE_BUILD_DIR)/load-client.o
	$(CC) $^ -o $@ $(LDFLAGS_RELEASE) $(RELEASE_LINK_LIB)

.PHONY: all clean checkdirs default help

checkdirs: $(DEBUG_BUILD_DIR) $(RELEASE_BUILD_DIR)

$(DEBUG_BUILD_DIR):
	@mkdir -p $@

$(RELEASE_BUILD_DIR):
	@mkdir -p $@

clean:
	@rm -rf $(BUILD_PATH)

help:
	@echo "Available targets:"
	@echo ""
	@echo " all          : builds everything, creates doc and runs tests."
	@echo " build        : will build/rebuild everything."
	@echo " clean        : removes docs folder, object files and local libraries from build/ directory."
	@echo "If no target is specified 'build' will be executed"

all: build
