.PHONY: test test-short test-integration test-all

# Run only short tests (basic functionality)
test-short:
	cd tests && go test -v -short -parallel 8 -timeout 30m

# Run only integration tests
test-integration:
	cd tests && go test -v -run "Integration|Lifecycle|Disaster|Compliance|Monitoring" -parallel 4 -timeout 60m

# Run all tests
test-all:
	cd tests && go test -v -parallel 8 -timeout 60m

# Default target
test: test-short