+++
title = "Determining Guest Login Status"
date = "2013-08-10"
slug = "2013/08/10/determining-guest-login-status"
Categories = ["OS X", "Technology"]
Tags = ["OS X", "Technology"]
+++

The other day I was presented with the challenge of determining whether Guest login was enabled on 150+ Macs. Fortunately, my client was using the [Casper Suite][1], so I was able to whip up an Extension Attribute rather quickly. Here's what I came up with to get the status:

{{< gist 6203175 095e34ac6a7818ebe4321649bae44a7a618c8faf >}}

[1]: http://www.jamfsoftware.com/software/casper-suite
