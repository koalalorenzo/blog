.DEFAULT_GOAL := clean

DATE ?= $(shell date +"%Y%m")
HUGO_ARGS ?= --minify --gc

# Fixes CF_PAGES_URL to be blog.setale.me when deploying in master
CF_PAGES_URL ?= https://blog.setale.me/
ifeq (${CF_PAGES_BRANCH},main)
CF_PAGES_URL := https://blog.setale.me/
endif

.EXPORT_ALL_VARIABLES:

__IMAGES_TO_CONVERT ?= $(shell find . -type f -and -not -path "./bower_components/*" -and \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \))
__GIF_TO_CONVERT ?= $(shell find . -type f -and -not -path "./bower_components/*" -and -name "*.gif")

clean_%:
	rm -rf ./$*
.PHONY: clean

clean: clean_public clean_tmp clean_resources
.PHONY: clean

run: clean_public
	hugo server --bind 0.0.0.0 --buildFuture --buildDrafts ${HUGO_ARGS}
.PHONY: run

build: clean_public
	hugo -b ${CF_PAGES_URL} ${HUGO_ARGS}
	du -sh ./public
.PHONY: build

%.webp:
	cwebp -short -q 85 "$*" -o "$(basename $*).webp"

%.gifwebp:
	gif2webp -mt -mixed -q 60 "$*.gif" -o "$(basename $*).webp"

convert_images:
ifneq (${__IMAGES_TO_CONVERT},)
	$(MAKE) $(patsubst %,%.webp,${__IMAGES_TO_CONVERT})
	rm ${__IMAGES_TO_CONVERT}
endif
ifneq (${__GIF_TO_CONVERT},)
	$(MAKE) $(patsubst %,%webp,${__GIF_TO_CONVERT})
	rm ${__GIF_TO_CONVERT}
endif
.PHONY: convert_images

new_post:
	-hugo new posts/${DATE}/index.md
.PHONY: new_post
