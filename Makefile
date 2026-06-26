# Latch — build tooling. Requires XcodeGen + Xcode on macOS.
#   brew install xcodegen
PROJECT := Latch.xcodeproj
APP_SCHEME := LatchApp
TEST_SCHEME := LatchEngineTests
CONFIG := Debug

.PHONY: gen build test run clean lint format format-check check

gen:
	xcodegen generate

build: gen
	xcodebuild -project $(PROJECT) -scheme $(APP_SCHEME) -configuration $(CONFIG) -destination 'platform=macOS' build

test: gen
	xcodebuild -project $(PROJECT) -scheme $(TEST_SCHEME) -configuration $(CONFIG) -destination 'platform=macOS' test

run: build
	@APP_PATH=$$(xcodebuild -project $(PROJECT) -scheme $(APP_SCHEME) -configuration $(CONFIG) -showBuildSettings 2>/dev/null \
		| awk '/ BUILT_PRODUCTS_DIR /{d=$$3}/ FULL_PRODUCT_NAME /{n=$$3}END{print d"/"n}'); \
	echo "Launching $$APP_PATH"; \
	open "$$APP_PATH"

lint:
	swiftlint lint

format:
	swiftformat .

format-check:
	swiftformat --lint .

# Full local gate: format check, lint, build, test.
check: format-check lint build test

clean:
	rm -rf $(PROJECT) .build DerivedData
