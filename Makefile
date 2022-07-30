.PHONY :  spec clean all build init

all : 	build spec

spec  : build
	rm -rf .test
	mkdir -p .test
	crystal spec --error-trace

build : init
	cc -march=native -g -c -o build/shim.o -Wall -O3 src/c/shim.c -lwayland-client
	cc -march=native -g -c -o build/xdg-shell.o -Wall -O3 src/c/xdg-shell-protocol.c -lwayland-client -lrt

clean :
	rm build/*

init :
	mkdir -p build
