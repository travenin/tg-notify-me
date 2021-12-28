DIST := dist

default: build

clean:
		@find . -name '*.py?' -delete
		@find . -name '.cache' -type d | xargs rm -rf
		@find . -name '.pytest_cache' -type d | xargs rm -rf
		@find . -name '__pycache__' -type d | xargs rm -rf
		@find . -name 'test-results' -type d | xargs rm -rf
		rm -rf $(DIST)
		mkdir $(DIST)

build: clean
	    cd src && zip ../$(DIST)/lambda.zip ./*

init:
		terraform -chdir=./infra init -backend-config=bucket.backend

deploy: build
		terraform -chdir=./infra apply
