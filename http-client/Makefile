#
# Examples:
#   make test tests='"foo"'
#     build and run the pony tests, filtering for only those whos name
#     starts with "foo"
#

.PHONY: clean build test all

test:
	stable env ponyc -o bin test && ./bin/test --only=$(tests)

build:
	stable env ponyc -o bin http-client

clean:
	rm -f bin/*

all: clean test build
