release:
	@git tag `grep -o -E '[0-9]\.[0-9]\.[0-9]{1,2}' gh-md-toc`
	@git push --tags origin master

test:
	@bats tests
