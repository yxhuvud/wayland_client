.PHONY :  spec clean all build init example

all : 	build spec

spec  : build
	rm -rf .test
	mkdir -p .test
	crystal spec --error-trace

build : init
	cc -march=native -g -c -Wall -O3 -o build/shim.o       src/c/shim.c               -lwayland-client
	cc -march=native -g -c -Wall -O3 -o build/xdg-shell.o  src/c/xdg-shell-protocol.c -lwayland-client -lrt

clean :
	rm build/*

init :
	mkdir -p build

example : build
	crystal build examples/complex.cr && ./complex
