
.PHONY: test  coverage

MOCHA="node_modules/.bin/mocha --compilers coffee:coffee-script/register"

test:
	$(MOCHA)

coverage:
	jscoverage lib lib-cov
	BIGINT_COV=1 $(MOCHA) --reporter html-cov > test/coverage.html
	-rm -r lib-cov
