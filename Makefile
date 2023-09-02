remote?=origin
tag?=no-tag
CONTINUE=-1
add_min?=0
mut_min?=1
add_maj?=0
mut_maj?=1
add_patch?=0
mut_patch?=1
commit?=1
newversion?=
no_tag?=0

tag:
	@echo "making tags: [$(tag), $(tag)-development]"
	@if [ -n "$(tag)" ] && [ "$(tag)" != "no-tag" ]; then  \
		git tag "$(tag)"; \
		git tag "$(tag)-development"; \
		git tag | grep -e "$(tag)"; \
	fi

push-tag:
	echo "branch:$(remote) tag:[$(tag), $(tag)-development]"; 
	@git push "$(remote)" "$(tag)-development"; 
	@git push "$(remote)" "$(tag)"; 

tag-bump:
	@make tag tag="$$(cat bump.txt)"

commit-bump:
	@if [ "$(commit)" = "1" ] && [ -n "$(newversion)" ]; then  \
		git add bump.txt;  \
		git commit -m "Chore: make bumped version to: $(newversion)"; \
	fi



write-version:
	@newversion="$(major).$(minor).$(patch)"; \
	echo "$${newversion}" > bump.txt; \
	make commit-bump newversion="$(newversion)"

bump-patch:
	@version="$$(add_patch=1 make read-version)"; echo "bumping patch $${version}"; \
	make write-version $${version}

bump-minor:
	@version="$$(add_min=1 mut_patch=0 make read-version)"; echo "bumping patch $${version}"; \
	make write-version $${version}

bump-major:
	@version="$$(add_maj=1 mut_min=0 mut_patch=0 make read-version)"; echo "bumping patch $${version}"; \
	make write-version $${version}

bump:
	@make bump-patch;
	@if [ "$(no_tag)" = "0" ]; then \
		make tag-bump; \
	fi
		
check-bump:
	@git tag | grep "$$(make read-bump)"

read-version:
	@awk -F . '{print "major="($$1 + $(add_maj)) * $(mut_maj) " minor="($$2 + $(add_min)) * $(mut_min) " patch="($$3 + $(add_patch)) * $(mut_patch)}' bump.txt

version:
	@echo "$$(make read-version)"; 
	


read-bump:
	@cat bump.txt

	
	