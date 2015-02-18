VERSION=1.0.0
NAME=watchdir
SOURCE=$(NAME).go
CONFIG=$(NAME).yml
BUILD_DIR=build
DEPLOY=casa@sweetohm.net:/home/web/watchdir
OS_LIST="linux freebsd openbsd darwin windows"

all: clean test build

clean:
	rm -rf $(BUILD_DIR)

test:
	go test

build:
	mkdir -p $(BUILD_DIR)
	go build $(SOURCE)
	mv $(NAME) $(BUILD_DIR)

run: clean test build
	go run $(SOURCE) $(CONFIG)

install: clean test build
	sudo cp $(BUILD_DIR)/$(NAME) /opt/bin/
	sudo cp $(NAME).init /etc/init.d/watchdir

release: clean test build
	@if [ `git rev-parse --abbrev-ref HEAD` != "master" ]; then \
		echo "You must release on branch master"; \
		exit 1; \
	fi
	git diff --quiet --exit-code HEAD || (echo "There are uncommitted changes"; exit 1)
	git tag "RELEASE-$(VERSION)"
	git push --tag

binary: clean test
	mkdir -p $(BUILD_DIR)/$(NAME)
	gox -os=$(OS_LIST) -output=$(BUILD_DIR)/$(NAME)/{{.Dir}}_{{.OS}}_{{.Arch}}
	cp license readme.md $(BUILD_DIR)/$(NAME)
	cd $(BUILD_DIR) && tar cvf $(NAME)-$(VERSION).tar $(NAME)/*
	gzip $(BUILD_DIR)/$(NAME)-$(VERSION).tar
	scp $(BUILD_DIR)/$(NAME)-$(VERSION).tar.gz $(DEPLOY)
