---
title: "Sonos, Apple TV 4K, and Dolby Atmos"
date: 2023-05-16T22:56:58-04:00
draft: false
---

I (somewhat) recently purchased a Sonos system to use as my TV speakers and for listening to music around the house. Overall, just about everything worked out-of-the-box, but I did have some trouble getting Dolby Atmos working with my Apple TV 4K, specifically. I eventually got it working after fiddling with the settings on my LG TV for a while, but I figured I'd write about it here in case it will help others or if I forget. :P

My current setup includes the following:

* [LG 55UP8000PUA 55" 4K Smart UHD TV](https://www.amazon.com/gp/product/B08WHNFFR1/)
* [Apple TV 4K (3rd generation) Wi-Fi + Ethernet](https://support.apple.com/en-us/HT200008)
* [Sonos Beam (Gen 2)](https://www.sonos.com/en-us/shop/beam)
* [Sonos Sub (Gen 3)](https://www.sonos.com/en-us/shop/sub)
* 2 x [Sonos One SL](https://www.sonos.com/en-us/shop/one-sl)s
* [Sonos Five](https://www.sonos.com/en-us/shop/five) (connected directly to my [ELAC Miracord 50 Turntable](https://www.elac.com/category/turntables/miracord-50/))

When I first set things up, I noticed that the Sonos app only showed "Stereo (PCM)" in the player screen, even when playing back content that supported Dolby Atmos, (I chose [Star Wars: Andor](https://www.disneyplus.com/series/star-wars-andor/3xsQKWG00GL5) as the source material for testing). I did however notice that I could get Dolby Atmos to work on the built-in Disney+ app on my LG TV, just not the Apple TV. But I like my Apple TV, so I kept digging.

After drilling through the TV's menus a couple of times, the settings I ultimately changed to get everything working were:

* Settings > Sound > eARC Support: **Enable**
* Settings > Sound > Digital Sound Output: **Pass Through**
* Settings > Sound > Select HDMI Input Audio Format: **Bitstream**

I figured out the first two fairly quickly, as I was able to find others who had similar problems online. The last one, however, took a bit longer. I eventually did a Google search for "PCM vs. Bitstream" since I stumbled across the option in the TV menus. After changing that setting I saw the Dolby Atmos logo in the playback screen of the Sonos iOS app. Yay!
