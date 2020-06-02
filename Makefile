.EXPORT_ALL_VARIABLES:

HUGO_ARGS ?=

clean_%:
	rm -rf ./$*
.PHONY: clean

clean: clean_public clean_tmp
.PHONY: clean

run: clean
	hugo server --bind 0.0.0.0 --buildFuture --buildDrafts ${HUGO_ARGS}
.PHONY: run

build: clean
	hugo ${HUGO_ARGS}
.PHONY: build
