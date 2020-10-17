+++
title = "Python One-liner for Determining Java Vendor"
date = "2014-03-09"
slug = "2014/03/09/python-one-liner-for-determining-java-vendor"
published = false
Categories = ["OS X", "Technology", "Python"]
+++

Here's a Python one-liner that prints the Java vendor on OS X clients, (e.g., Apple or Oracle).

```sh
python -c 'import os,plistlib; jv = plistlib.readPlist(os.path.join(os.path.realpath("/Library/Internet Plug-Ins/JavaAppletPlugin.plugin"), "Contents/Info.plist"))["CFBundleIdentifier"].split(".")[1]; print jv.capitalize()'
```

Why?

...Because we can.
