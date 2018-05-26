.PHONY: run

build:
	docker build --build-arg GOOS=$(os) --build-arg GOARCH=$(arch) -t jamesrwhite/minicron/client .
	docker run --rm jamesrwhite/minicron/client cat minicron > ./minicron
	chmod +x ./minicron

shell:
	docker run --rm -it jamesrwhite/minicron/client bash
