# Makefile for sl (Steam Locomotive)
# Author: Reverend Steven Milanese

PREFIX = /usr/local
BINDIR = $(PREFIX)/bin
INSTALL = install
RM = rm -f

# Default target
all:
	@echo "sl - Steam Locomotive"
	@echo "Usage: make install   - Install sl to $(BINDIR)"
	@echo "       make uninstall - Remove sl from $(BINDIR)"
	@echo "       make test      - Test sl locally"

# Install sl
install:
	$(INSTALL) -d $(BINDIR)
	$(INSTALL) -m 755 sl $(BINDIR)/sl
	@echo "sl installed to $(BINDIR)/sl"
	@echo "Type 'sl' to see the train!"

# Uninstall sl
uninstall:
	$(RM) $(BINDIR)/sl
	@echo "sl removed from $(BINDIR)"

# Test locally
test:
	./sl

# Run with different options
demo:
	@echo "=== Classic Train ==="
	./sl
	@echo "=== Flying Train ==="
	./sl -F
	@echo "=== C51 Train ==="
	./sl -c
	@echo "=== Accident ==="
	./sl -a

.PHONY: all install uninstall test demo