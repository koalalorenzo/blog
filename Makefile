.EXPORT_ALL_VARIABLES:
.DEFAULT_GOAL := clean

DATE ?= $(shell date +"%Y%m")
HUGO_ARGS ?= --minify

__IMAGES_TO_CONVERT ?= $(shell find . -type f -and -not -path "./bower_components/*" -and \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \))
__GIF_TO_CONVERT ?= $(shell find . -type f -and -not -path "./bower_components/*" -and -name "*.gif")

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

%.webp:
	cwebp -short -q 85 $* -o $(basename $*).webp
	find . -type f -and \( -iname "*.md" -o -iname "*.markdown" \) \
		-exec gsed -i '' "s#$(patsubst %,%,$*)#$(patsubst %,%,$(basename $*)).webp#g" {} \;


%.gifwebp:
	gif2webp -mt -mixed -q 60 $*.gif -o $(basename $*).webp
	find . -type f -and \( -iname "*.md" -o -iname "*.markdown" \) \
		-exec gsed -i '' "s#$(patsubst %,%,$*).gif#$(patsubst %,%,$(basename $*)).webp#g" {} \;

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
	-hugo new posts/${DATE}/content.md
.PHONY: new_post
