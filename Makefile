.PHONY: testapp devices

# Boot emulator/simulator (nếu cần) và chạy app trên Android + iOS.
testapp:
	@./scripts/testapp.sh

devices:
	@flutter devices
