# pasta — build tooling. Requires XcodeGen + Xcode on macOS.
#   brew install xcodegen
PROJECT := pasta.xcodeproj
APP_SCHEME := PastaApp
TEST_SCHEME := PastaEngineTests
CONFIG := Debug

.PHONY: gen build test run clean

gen:
	xcodegen generate

build: gen
	xcodebuild -project $(PROJECT) -scheme $(APP_SCHEME) -configuration $(CONFIG) build

test: gen
	xcodebuild -project $(PROJECT) -scheme $(TEST_SCHEME) -configuration $(CONFIG) test

run: build
	@APP_PATH=$$(xcodebuild -project $(PROJECT) -scheme $(APP_SCHEME) -configuration $(CONFIG) -showBuildSettings 2>/dev/null \
		| awk '/ BUILT_PRODUCTS_DIR /{d=$$3}/ FULL_PRODUCT_NAME /{n=$$3}END{print d"/"n}'); \
	echo "Launching $$APP_PATH"; \
	open "$$APP_PATH"

clean:
	rm -rf $(PROJECT) .build DerivedData
