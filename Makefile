TYPST ?= typst

CONTENT_DIR := content
BUILD_DIR := build

ENTRYPOINTS := $(wildcard $(CONTENT_DIR)/*/main.typ)
TOPICS := $(notdir $(patsubst %/,%,$(dir $(ENTRYPOINTS))))
PDFS := $(addprefix $(BUILD_DIR)/,$(addsuffix .pdf,$(TOPICS)))

.PHONY: all build list watch force $(TOPICS)

all: build

build: $(PDFS)

$(TOPICS): %: $(BUILD_DIR)/%.pdf

$(BUILD_DIR)/%.pdf: $(CONTENT_DIR)/%/main.typ force
	@mkdir -p "$(BUILD_DIR)"
	$(TYPST) compile "$<" "$@" --root .

list:
	@for topic in $(TOPICS); do echo "$$topic"; done

watch:
	@test -n "$(TOPIC)" || { \
		echo "Usage: make watch TOPIC=<topic>"; \
		echo "Available topics: $(TOPICS)"; \
		exit 2; \
	}
	@test -f "$(CONTENT_DIR)/$(TOPIC)/main.typ" || { \
		echo "Unknown topic: $(TOPIC)"; \
		echo "Available topics: $(TOPICS)"; \
		exit 2; \
	}
	@mkdir -p "$(BUILD_DIR)"
	$(TYPST) watch "$(CONTENT_DIR)/$(TOPIC)/main.typ" \
		"$(BUILD_DIR)/$(TOPIC).pdf" \
		--root .

force:
