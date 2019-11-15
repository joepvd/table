SHELL := /bin/bash

.PHONY: test
test: ngetopt.awk
	test/runtests.sh

.PHONY: man
man: .ensure-rst2man.py table.1.gz libtable.2.gz

.PHONY: ngetopt.awk
ngetopt.awk:
	gawk -i ngetopt 'BEGIN{exit}' || curl https://raw.githubusercontent.com/joepvd/ngetopt.awk/master/ngetopt.awk >ngetopt.awk

%.gz: %.rst
	rst2man.py $< | gzip >$@

.PHONY: .ensure-rst2man.py
.ensure-rst2man.py:
	@command -v rst2man.py >/dev/null
