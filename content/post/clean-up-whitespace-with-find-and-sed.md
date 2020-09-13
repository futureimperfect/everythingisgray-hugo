+++
title = "Clean Up Whitespace With find and sed"
date = "2014-10-07"
slug = "2014/10/07/clean-up-whitespace-with-find-and-sed"
published = false
Categories = ["Technology", "Unix", "OS X"]
+++

Unclean whitespace in source code makes me sad. The following will remove all trailing whitespace in files within the current directory that end with `.h` or `.m`, (which makes me happy). I've only tested this on OS X.

`find . -regex '.*\.[mh]$' -exec sed -i '' 's/[ \t]*$//' {} \;`

*BUT WAIT!*

Before you blindly paste this into your command prompt and hit return, (and complain to me that I made you remove all lines ending with 't'), the `\t` should actually be a tab character. To replace `\t` with a tab character, type `Control` + `v`, then hit tab. The command will now look like this, (which is a space, then a tab):

`find . -regex '.*\.[mh]$' -exec sed -i '' 's/[     ]*$//' {} \;`
