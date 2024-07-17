.PHONY: clean clean-all build force

all: build

build:
	bash build-maps.sh

force:
	bash build-maps.sh force

# QMapShack renders the map differently than the device, and
# we need to thicken the border lines to see roughly how it will
# look like on the device
qmapshack:
	bash build-maps.sh qmapshack

clean:
	rm -rf build
	rm -rf out

clean-all:
	git clean -ffdx
