.PHONY: help serve clean build start setup update-deps prereqs

# Default Hugo port
PORT ?= 1313

# Colors for help text
BLUE := \033[34m
RESET := \033[0m

# Check for required commands
NPM := $(shell command -v npm 2> /dev/null)

# Target to check for npm
check-npm:
ifndef NPM
	$(error "npm is required but not installed. Please visit https://nodejs.org/ to install")
endif

## Display this help message
help:
	@echo "$(BLUE)Goa Documentation Site$(RESET)"
	@echo "Available commands:"
	@echo
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  $(BLUE)%-15s$(RESET) %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo

## Initialize Hugo modules and install dependencies
setup:
	hugo mod get -u
	hugo mod tidy

## Start the Hugo server with live reload (alias for 'serve')
start: setup serve

## Start the Hugo server with live reload
serve:
	@echo "Starting Hugo server on http://localhost:$(PORT)..."
	hugo server -D -p $(PORT) --disableFastRender

## Clean generated files (public/ and resources/)
clean:
	@echo "Cleaning generated files..."
	rm -rf public/
	rm -rf resources/
	rm -rf .hugo_build.lock

## Build the site for production with minification
build: setup
	@echo "Building site..."
	hugo --minify

## Update npm dependencies
update-deps: check-npm  ## Update npm dependencies
	@echo "Updating npm dependencies..."
	npm update
	npm audit fix
	@echo "Dependencies updated successfully"

## Install prerequisites (npm packages, hugo)
prereqs: check-npm  ## Install prerequisites (npm, hugo)
	@echo "Installing prerequisites..."
	npm install
	go install -tags extended github.com/gohugoio/hugo@latest
	@echo "Prerequisites installed successfully"

.DEFAULT_GOAL := help
