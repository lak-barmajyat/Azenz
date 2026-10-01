qmllint:
	@output="$$(script -qec 'uv run pyside6-project qmllint' /dev/null 2>&1)"; \
	status=$$?; \
	if [ $$status -ne 0 ] || printf '%s\n' "$$output" | grep -Eq "returned [1-9][0-9]*"; then \
		printf '%s\n' "$$output" \
			| sed "s|$$(pwd)/||g" \
			| grep -Ev '^pyside6-(qmllint|rcc) '; \
		exit 1; \
	fi
