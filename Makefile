TAG = $(BUILD_NUMBER)
PROJECT = wagtailtrans-sandbox

.PHONY: dist

default: develop

define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean:
	@find . -name '*.pyc' | xargs rm
	@find src -name '*.egg-info' | xargs rm -rf

develop: clean requirements
	@python manage.py migrate

requirements:
	@pip install --upgrade -e .
	@pip install --upgrade -e .[test]

qt:
	@py.test -q --reuse-db tests/ --tb=short

coverage:
	@coverage run --source wagtailtrans -m py.test -q --reuse-db --tb=short tests
	@coverage report -m
	@coverage html
	$(BROWSER) htmlcov/index.html

lint:
	@flake8 wagtail

isort:
	isort `find . -name '*.py' -not -path '*/migrations/*'`

dist: clean ## builds source and wheel package
	@python setup.py sdist bdist_wheel
	ls -l dist

release: dist ## package and upload a release
	twine upload -r lukkien dist/*

# Docker commands
package:
	python setup.py sdist

build: package
	docker build -t $(PROJECT) .

run: build
	docker run --name $(PROJECT) -d -P -p 8000:80 $(PROJECT)

destroy:
	docker rm -f $(PROJECT)

ssh:
	docker exec -it $(PROJECT) /bin/bash

push: build
	docker tag $(PROJECT) registry.lukkien.com/$(PROJECT):$(TAG)
	docker push registry.lukkien.com/$(PROJECT):$(TAG)

deploy-test: push
	ssh deploy-lukkien@192.168.226.18 ./tools/docker/restart $(PROJECT) $(TAG)
