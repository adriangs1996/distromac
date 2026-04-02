# distromac Makefile

# --- VM Tests ---
DISTROMAC_TEST_IMAGE ?= ghcr.io/cirruslabs/macos-sequoia-base:latest

.PHONY: test-vm
test-vm:
	DISTROMAC_TEST_IMAGE=$(DISTROMAC_TEST_IMAGE) \
	DISTROMAC_TEST_FLAGS="$(FLAGS)" \
	DISTROMAC_TEST_SUITE="$(SUITE)" \
	bash tests/vm/run.sh

.PHONY: test-vm-pull
test-vm-pull:
	tart pull $(DISTROMAC_TEST_IMAGE)
