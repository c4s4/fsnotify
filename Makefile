NAME=watchdir
VERSION=$(shell changelog release version)
BUILD_DIR=build
OS_LIST="!plan9"

YELLOW=\033[1m\033[93m
CYAN=\033[1m\033[96m
CLEAR=\033[0m

.PHONY: build

help:
	@echo "$(CYAN)clean$(CLEAR)    Clean generated files"
	@echo "$(CYAN)test$(CLEAR)     Run unit tests"
	@echo "$(CYAN)build$(CLEAR)    Build application for current platform"
	@echo "$(CYAN)compile$(CLEAR)  Generate binaries for all platforms"
	@echo "$(CYAN)archive$(CLEAR)  Generate distribution archive"
	@echo "$(CYAN)release$(CLEAR)  Release application"help:
	

clean:
	@echo "$(YELLOW)Cleaning generated files$(CLEAR)"
	rm -rf $(BUILD_DIR)

test:
	@echo "$(YELLOW)Running unit tests$(CLEAR)"
	go test

build:
	@echo "$(YELLOW)Building application for current platform$(CLEAR)"
	mkdir -p $(BUILD_DIR)
	sed -e s/UNKNOWN/$(VERSION)/ $(NAME).go > $(BUILD_DIR)/$(NAME).go
	cd $(BUILD_DIR) && go build $(NAME).go

compile: clean
	@echo "$(YELLOW)Generating binaries for all platforms$(CLEAR)"
	mkdir -p $(BUILD_DIR)/$(NAME)-$(VERSION)
	sed -e s/UNKNOWN/$(VERSION)/ $(NAME).go > $(BUILD_DIR)/$(NAME).go
	cd $(BUILD_DIR) && gox -os=$(OS_LIST) -output=$(NAME)-$(VERSION)/$(NAME)-{{.OS}}-{{.Arch}}

archive: compile
	@echo "$(YELLOW)Generating distribution archive$(CLEAR)"
	cp LICENSE.txt $(BUILD_DIR)/$(NAME)-$(VERSION)
	md2pdf README.md && mv README.pdf $(BUILD_DIR)/$(NAME)-$(VERSION)
	changelog to html style > $(BUILD_DIR)/$(NAME)-$(VERSION)/CHANGELOG.html
	cd $(BUILD_DIR) && tar cvf $(NAME)-$(VERSION).tar $(NAME)-$(VERSION)/*
	gzip $(BUILD_DIR)/$(NAME)-$(VERSION).tar

release: archive
	@echo "$(YELLOW)Releasing application$(CLEAR)"
	release
