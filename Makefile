#!/usr/bin/make

.PHONY: build
build:
	hugo --minify -t cactus

.PHONY: serve
serve:
	hugo server -D --disableFastRender
