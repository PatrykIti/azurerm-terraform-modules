.PHONY: test test-short test-integration test-all docs clean validate

test-short:
	go test -v -short -parallel 8 -timeout 30m

test-integration:
	go test -v -run "Integration|Lifecycle|CreationTime" -parallel 4 -timeout 60m

test-all:
	go test -v -parallel 8 -timeout 60m

test: test-short

clean:
	find . -name "*.tfstate*" -type f -delete
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name "terraform.tfstate.d" -type d -exec rm -rf {} +

fmt:
	gofmt -w .

validate-fixtures:
	@for dir in fixtures/*/; do \
		if [ -f "$$dir/main.tf" ]; then \
			echo "Validating $$dir..."; \
			cd $$dir && terraform init -backend=false && terraform validate && cd ../..; \
		fi \
	done
