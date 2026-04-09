.PHONY: clean clean-all

COUNTRIES := $(shell cat build-maps.sh  | sed -n '/AVAILABLE_MAPS=(/,/)/p' | sed '1d;$d' | sed 's/"//g')

all: $(COUNTRIES)

$(COUNTRIES): %:
	bash build-maps.sh $@


# Force build targets
$(COUNTRIES:=-force): %-force:
	bash build-maps.sh $* force

# QMapShack renders the map differently than the device, and
# we need to thicken the border lines to see roughly how it will
# look like on the device
$(COUNTRIES:=-qmapshack): %-qmapshack:
	bash build-maps.sh $* qmapshack

clean:
	rm -rf build
	rm -rf out

clean-all:
	git clean -ffdx
