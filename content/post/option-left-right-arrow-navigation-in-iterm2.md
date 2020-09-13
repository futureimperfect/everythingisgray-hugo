+++
title = "Option (Left|Right) Arrow Navigation in iTerm2"
date = "2013-11-03"
slug = "2013/11/03/option-left-right-arrow-navigation-in-iterm2"
published = false
Categories = ["Technology", "OS X"]
Tags = ["Technology", "OS X"]
+++

Today I decided to switch to [iTerm2][1] on OS X. Shortly after making this decision I was frustrated by not being able to "jump" between words with the option-arrow shortcut. Fortunately, the solution is rather simple — just modify the option-left/right arrow shortcuts in **Preferences > Profiles > Keys**. The "Action" should be "Send Escape Sequence" + **b** for jumping backwards and **f** for jumping forward, (e.g., `^[b`, and `^[f`).

I know I've tried iTerm in the past, and I'm pretty sure not being able to do this right away kept me from continuing to use the tool. After making this change everything has been swell, though.

[![iTerm2 Preferences](/images/2013-11-03-option-left-right-arrow-navigation-in-iterm2/iterm2_preferences.png)](https://code.google.com/p/iterm2/wiki/Keybindings)

[1]: http://www.iterm2.com/#/section/home
