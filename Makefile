.PHONY: help version-bump validate-workflows install test lint clean

help:
	@echo "Available commands:"
	@echo "  make version-bump   - Bump version and update all references"
	@echo "  make validate-workflows - Validate workflow consistency between EN/PT"
	@echo "  make install        - Install SpecSwift CLI locally"
	@echo "  make test           - Run tests"
	@echo "  make lint           - Run linting checks"
	@echo "  make clean          - Clean build artifacts"

version-bump:
	@read -p "Enter new version (e.g., 1.1.0): " new_ver; \
	echo "$$new_ver" > VERSION; \
	sed -i '' "s/VERSION=\".*\"/VERSION=\"$$new_ver\"/" bin/specswift; \
	sed -i '' "s/VERSION=\".*\"/VERSION=\"$$new_ver\"/" install.sh; \
	echo "✓ Updated to version $$new_ver"; \
	echo ""; \
	echo "Changed files:"; \
	echo "  - VERSION"; \
	echo "  - bin/specswift"; \
	echo "  - install.sh"; \
	echo ""; \
	git add VERSION bin/specswift install.sh && git status

validate-workflows:
	@echo "Validating workflow consistency between EN and PT..."
	@echo ""
	@./scripts/validate-workflows.sh

install:
	@./install.sh --local

test:
	@echo "No tests configured yet. Add tests to enable this command."

lint:
	@echo "Running shellcheck..."
	@which shellcheck > /dev/null || (echo "shellcheck not found. Install with: brew install shellcheck" && exit 1)
	@shellcheck bin/specswift lib/scripts/*.sh install.sh scripts/validate-workflows.sh

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf DerivedData .build
	@echo "✓ Clean complete"
