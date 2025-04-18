
.PHONY: shell
shell:
	nix develop -f onix.nix -j auto -v shell

.PHONY: lock
lock:
	nix develop -f onix.nix lock
