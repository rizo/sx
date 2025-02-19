
.PHONY: shell
shell:
	nix develop -f default.nix -j auto -v shell

.PHONY: lock
lock:
	nix develop -f default.nix lock
