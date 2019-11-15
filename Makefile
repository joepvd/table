SHELL := /bin/bash

.PHONY: test
test:
	test/runtests.sh

.PHONY: man
man: .ensure-rst2man.py table.1.gz libtable.2.gz

%.gz: %.rst
	rst2man.py $< | gzip >$@

.PHONY: .ensure-rst2man.py
.ensure-rst2man.py:
	@command -v rst2man.py >/dev/null
