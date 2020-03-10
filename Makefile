.EXPORT_ALL_VARIABLES:

clean_%:
	rm -rf ./$*
.PHONY: clean

clean: clean_public clean_tmp
.PHONY: clean

run: clean
	hugo server --bind 0.0.0.0
.PHONY: run

build: clean
	hugo
.PHONY: build
