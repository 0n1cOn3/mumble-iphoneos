XT_PRODUCT = Mumble   # app bundle name

.PHONY: setup build run pack install clean

setup:
	xtool setup

build:
	xtool dev build

run:
	xtool dev run

pack:
	xtool pack

install:
	xtool install xtool/$(XT_PRODUCT).ipa

clean:
	rm -rf .build xtool
