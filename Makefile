.EXPORT_ALL_VARIABLES:

DATE ?= $(shell date +"%Y%m")
HUGO_ARGS ?=

__IMAGES_TO_CONVERT ?= $(shell find ./static/images -type f -and \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \))

clean_%:
	rm -rf ./$*
.PHONY: clean

.DEFAULT_GOAL :=
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
		-exec sed -i '' s#$(patsubst static/%,%,$*)#$(patsubst static/%,%,$(basename $*)).webp#g {} \;

convert_images:
	$(MAKE) $(patsubst %,%.webp,${__IMAGES_TO_CONVERT})
	rm ${__IMAGES_TO_CONVERT}
.PHONY: convert_images

new_post:
	-hugo new posts/${DATE}.md
	mkdir -p static/posts/${DATE}/
	touch static/posts/${DATE}/.gitkeep
.PHONY: new_post
