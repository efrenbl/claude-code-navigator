# Claude Code Navigator - Makefile
# Provides common development commands

.PHONY: help install dev-setup test coverage lint format clean build publish

# Default target
help:
	@echo "Claude Code Navigator - Development Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make install      Install package in current environment"
	@echo "  make dev-setup    Set up development environment (venv + deps)"
	@echo ""
	@echo "Testing:"
	@echo "  make test         Run all tests"
	@echo "  make coverage     Run tests with coverage report"
	@echo ""
	@echo "Code Quality:"
	@echo "  make lint         Check code style"
	@echo "  make format       Auto-format code"
	@echo ""
	@echo "Build:"
	@echo "  make build        Build distribution packages"
	@echo "  make clean        Remove build artifacts"
	@echo ""
	@echo "Quick Start:"
	@echo "  make dev-setup && make test"

# Installation
install:
	pip install -e .

dev-setup:
	@echo "Setting up development environment..."
	python -m venv venv
	@echo "Activating venv and installing dependencies..."
	. venv/bin/activate && pip install --upgrade pip
	. venv/bin/activate && pip install -e ".[dev]"
	@echo ""
	@echo "Development environment ready!"
	@echo "Activate with: source venv/bin/activate"

# Testing
test:
	python -m pytest tests/ -v

coverage:
	python -m pytest tests/ --cov=src/code_map_navigator --cov-report=term --cov-report=html
	@echo ""
	@echo "HTML coverage report: htmlcov/index.html"

# Code Quality
lint:
	@echo "Checking code style..."
	python -m flake8 src/ tests/ --max-line-length=100 --ignore=E501,W503
	python -m black --check src/ tests/
	python -m isort --check-only src/ tests/
	@echo "All checks passed!"

format:
	@echo "Formatting code..."
	python -m black src/ tests/
	python -m isort src/ tests/
	@echo "Code formatted!"

# Type checking
typecheck:
	python -m mypy src/

# Build
build: clean
	python -m build

clean:
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	rm -rf src/*.egg-info/
	rm -rf .pytest_cache/
	rm -rf .mypy_cache/
	rm -rf htmlcov/
	rm -rf .coverage
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true

# Publishing
publish: build
	python -m twine upload dist/*

publish-test: build
	python -m twine upload --repository testpypi dist/*

# Quick demo
demo:
	@echo "Running quick demo..."
	@echo ""
	@echo "1. Generating code map for this project..."
	python -m code_map_navigator.code_mapper . -o .demo-codemap.json --pretty
	@echo ""
	@echo "2. Searching for 'search' symbols..."
	python -m code_map_navigator.code_search "search" -m .demo-codemap.json --pretty
	@echo ""
	@echo "3. Showing codebase stats..."
	python -m code_map_navigator.code_search --stats -m .demo-codemap.json --pretty
	@echo ""
	@echo "4. Cleaning up demo files..."
	rm -f .demo-codemap.json
	@echo "Demo complete!"

# Run a single script directly
run-mapper:
	python -m code_map_navigator.code_mapper $(ARGS)

run-search:
	python -m code_map_navigator.code_search $(ARGS)

run-reader:
	python -m code_map_navigator.line_reader $(ARGS)
