#!/usr/bin/make -f
# -*- makefile -*-
PYTHONPATH := ${CURDIR}
export PYTHONPATH


all: help
help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""
	@echo "   1. make clean                             - Clean all pyc and caches"
	@echo "   2. make run                               - Run application locally"
	@echo "   3. make deploy                            - Deploy de Application"
	@echo "   4. make front                             - Install Front dependencies"
	@echo "   5. make lib                               - Generate lib"
	@echo "   6. make test                              - Run tests"
	@echo ""
	@echo ""


.PHONY: clean
clean:
	@echo "Limpando arquivos pyc e caches..."
	rm -rf build/ dist/ docs/_build *.egg-info
	find $(CURDIR) -name "*.py[co]" -delete
	find $(CURDIR) -name "*.orig" -delete
	find $(CURDIR)/$(MODULE) -name "__pycache__" | xargs rm -rf


.PHONY: run
run:run_front
	# dev_appserver.py app.yaml worker.yaml
	@echo "Running"


.PHONY: deploy
deploy:
ifeq ($(strip $(ENV)),)
	@echo "Export ENV variable first, like: export ENV='acorsi'"
else
	rm -rf lib; pip install -r requirements.txt -t lib; gcloud app deploy app.yaml worker.yaml queue.yaml index.yaml cron.yaml --no-promote --project gweb-gfw-oort-dev -v $(ENV) -q
endif


.PHONY: front_deploy
front_deploy:
ifeq ($(strip $(ENV)),)
	@echo "Export ENV variable first, like: export ENV='acorsi'"
else
	cd frontend;yarn ; node node_modules/gulp/bin/gulp.js build --apiurl "https://$(ENV)-dot-gweb-gfw-oort-dev.appspot.com" --budgeturl "https://develop-dot-gweb-gfw-oort-budget-dev.appspot.com/" --clientid "91996667519-th3i7o846tl6dbbvar28vg7mo0bqn905.apps.googleusercontent.com"
endif


.PHONY: lib
lib:
	rm -rf lib;pip install -r requirements.txt -t lib

.PHONY: test
test:clean
		# py.test -xrs --pep8 --flakes tests/
		py.test -xrs tests/

.PHONY: run_front
run_front:
ifeq ($(strip $(ENV)),)
        @echo "Export ENV variable first, like: export ENV='acorsi'"
else
	cd frontend; yarn; node node_modules/gulp/bin/gulp.js --fb-cred gs://gweb-gfw-oort-dev.appspot.com/firebase.json --apiurl "https://$(ENV)-dot-gweb-gfw-oort-dev.appspot.com" --budgeturl "https://develop-dot-gweb-gfw-oort-budget-dev.appspot.com/" --clientid "91996667519-th3i7o846tl6dbbvar28vg7mo0bqn905.apps.googleusercontent.com"

endif

.PHONY: rollback
rollback:
	python /home/CIT/acorsi/sources/google-cloud-sdk/platform/google_appengine/appcfg.py -A gweb-gfw-oort-dev --version acorsi rollback ./


.PHONY: min
min:
	gcloud app deploy app.yaml --no-promote --project gweb-gfw-oort-dev -v $(ENV) -q
