+++
date = "2010-02-16"
slug = "2010/02/16/configure-archive-utility-in-mac-os-x"
title = "Configure Archive Utility in Mac OS X"
Categories = ["OS X", "Technology"]
Tags = ["OS X"]
+++

Having recently purchased a new MacBook Pro and electing to skip the option of running [Migration Assistant](http://en.wikipedia.org/wiki/Migration_Assistant_(Apple)) to transfer my data and settings, I noticed that a few applications were behaving differently. Over the years I've configured quite a few things on my Mac, and eventually I became accustomed to said customizations. One of the first things I noticed was that when I would unarchive a zip file, the compressed file would stay put. I remembered that a few years ago I learned of a cool way to configure Mac OS X's built-in Archive Utility, (using a System Preference pane), so I immediately went digging. To do this, simply navigate to `/System/Library/CoreServices`. From there right or control click on Archive Utility.app, and select "Show Package Contents." A new window will open containing a folder named `Contents`, within which you'll find `Resources`, and finally `Archives.prefPane`. Opening this preference pane will result in System Preferences.app asking if you'd like to install for all users or for this user only. Voila! Now you can tell Archive Utility to delete the archive after expanding it.
