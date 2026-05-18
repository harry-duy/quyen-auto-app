.PHONY: help backend customer staff dev clean build

help:
	@echo ""
	@echo "  make dev         Chay Backend + Customer + Staff (3 cua so)"
	@echo "  make backend     Chi chay Spring Boot backend (port 8080)"
	@echo "  make customer    Chi chay Flutter customer app"
	@echo "  make staff       Chi chay Flutter staff app"
	@echo "  make build       Build backend JAR (skip tests)"
	@echo "  make clean       Xoa toan bo build artifacts"
	@echo ""

dev:
	@powershell -ExecutionPolicy Bypass -File scripts/dev.ps1

backend:
	cd backend && ./mvnw spring-boot:run

customer:
	flutter run --flavor customer -t lib/main.dart

staff:
	flutter run --flavor staff -t lib/main_staff.dart

build:
	cd backend && ./mvnw clean package -DskipTests

clean:
	cd backend && ./mvnw clean
	flutter clean
