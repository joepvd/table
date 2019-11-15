SHELL := /bin/bash -O nullglob

.PHONY: test
test: ngetopt.awk
	test/runtests.sh

.PHONY: man
man: .ensure-rst2man.py table.1.gz libtable.2.gz

.PHONY: ngetopt.awk
ngetopt.awk:
	gawk -i ngetopt 'BEGIN{exit}' 2>/dev/null || curl -sSL https://raw.githubusercontent.com/joepvd/ngetopt.awk/master/ngetopt.awk >ngetopt.awk

%.gz: %.rst
	rst2man.py $< | gzip >$@

.PHONY: .ensure-rst2man.py
.ensure-rst2man.py:
	@command -v rst2man.py >/dev/null

.PHONY: show-failing-tests
show-failing-tests:
	for f in test/*.out; do head $$f $${f/out}ok; done
