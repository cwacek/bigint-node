
.PHONY: test  coverage
	
test:
	mocha

coverage:
	jscoverage lib lib-cov
	BIGINT_COV=1 mocha --reporter html-cov > test/coverage.html
	-rm -r lib-cov
