.PHONY: clean clean-all build force

all: build

build:
	bash build-maps.sh

force:
	bash build-maps.sh force

clean:
	rm -rf build
	rm -rf out

clean-all:
	git clean -ffdx
