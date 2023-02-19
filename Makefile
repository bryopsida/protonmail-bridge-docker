build:
	docker build . -t ghcr.io/bryopsida/protonmail-bridge:local
run:
	docker run ghcr.io/bryopsida/protonmail-bridge:local
shell:
	docker run -it ghcr.io/bryopsida/protonmail-bridge:local /bin/sh