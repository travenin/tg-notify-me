default: build

clean:
		rm -rf build
		mkdir build

build: clean
	    zip build/lambda.zip src/*

deploy: build
		terraform -chdir=./infra apply
