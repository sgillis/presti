ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

elm:
	docker run --rm -v ${ROOT_DIR}/src:/src sgillis/elm bash -c "cd src && elm-make Presti.elm"

watch:
	@while true; do make elm; sleep 1; done
