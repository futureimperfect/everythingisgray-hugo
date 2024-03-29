---
title: "Custom Tidbyt Apps"
date: 2023-05-24T23:14:20-04:00
draft: false
---

I've had my [Tidbyt](https://tidbyt.com/) for almost a year now, and generally speaking I really like it. But one of its biggest gaps (in my opinion) is the lack of support for custom apps. Tidbyt apps _are_ relatively [easy to write](https://github.com/tidbyt/pixlet/blob/main/docs/tutorial.md), (they're written in [Starlark](https://github.com/bazelbuild/starlark), a dialect of Python). They also have a directory of [Community Apps](https://tidbyt.dev/docs/publish/community-apps) which anyone can contribute to. However, if you just want to build a silly custom app that you have no intention of sharing, (or you just can't imagine other people getting use out of it), then your options are fairly limited. You _can_ [render a WebP image from a Starlark source file and push it to your device](https://tidbyt.dev/docs/build/build-for-tidbyt#push-to-a-tidbyt), but if you want it to continuously update there's not much you can do. This is unfortunate, because I was trying to build a custom countdown clock for my daughter based entirely on an inside joke, (her favorite musician is [Nick Rattigan](https://en.wikipedia.org/wiki/Nick_Rattigan), and one of her friends called him "rat man" at some point and it stuck). So when we recently got tickets to [Adjacent Fest in Atlantic City](https://adjacentfestival.com/) (where he was playing), I decided to create a modified version of the [Countdown Clock](https://github.com/tidbyt/community/tree/main/apps/countdownclock) app with an image I cobbled together of a rat with a man, counting down to the days left before the concert. I ended up solving this problem by writing a script to generate the WebP image, pushing it to my device, and triggering it to run every 90 seconds by a LaunchD job on one of my Mac mini servers. Since I'm also passing the `-i` option along with an installation ID to `pixlet push`, it also [shows up in the Tidbyt mobile app](https://tidbyt.dev/docs/integrate/pushing-apps#apps-and-installations), as seen below.

![Rat Man Tidbyt App Screenshot](/images/2023-05-24-custom-tidbyt-apps/rat_man_tidbyt_screenshot.jpeg "Rat Man Tidbyt App Screenshot")

Here's how I did it:

## Tidbyt App Source

```python
load("render.star", "render")
load("time.star", "time")
load("schema.star", "schema")
load("math.star", "math")
load("encoding/base64.star", "base64")
load("encoding/json.star", "json")

RAT_MAN_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABIAAAAeCAYAAAAhDE4sAAAAAXNSR0IArs4c6QAABJpJREFUSMeVk21MW2UUx5v48kU3FzPDB8Vk9JZSSoFC6e197i0rDt3UOBlw31regnELsGSB6RdfEjZjNMRMk20xbLpNyKZbNLjwIgNsKYVCX+hcHWYzMQOUxERcIPugX/B4nru2DCgRb3Jyn3vO//ye85znXJ0u8bSL5keHRGfD6ZfZvu9Fp123yTMi7uZOvmTvG1KdNT6X6+E1wXZ0TMhc1081AtyuFSCkcHcGRe7J9ZAB0fkUxn6lmhnUTkjc56IoPpQS+ERWuO4mMK1wcIO+VXK3XySFI+qejJ4K1w5qV1U245ooFGNs6YeEFtfgVQQ2BQoqXMtMDQ/XVQ2yMCAJr4QU0jXtJov4nqdVRFWyOKmQ830ivz+mkt+pluYEFeFgCjQu8x7qxGpWfBJfH5RJzy0sHxM0ODW6pj7c9LJX4hpR+89NzBlXeSkF6lVdO6cUbmFKIUG/JDTe9PAQxdLT2Y8Y88pcXUjmwiGZzG3opbea2zMskSo8xmj8P0BTMjdMtT5FcKW92oBE3qHHowmRahtERHsKQNfUR5uMzV4Zl7h300L8Ci/TSqgwIrEwc6wZ4m0Kru2axY+6Yaa9SYtRDe2PX+FeWwPpPFj8CPYnmjwS3X0xNgGzF09DuNKq2dzlTvgj7IewWKJp4m7tiPErOMgp0DWlNDOicPdiaqIXsgOitbsh6hFW+0PX1Edj+E21YYVb7hW5p9dMLIKWU6AkLJGU7puOQ0Qhf/Y0uHZokCFPGe9XBDfe1iy9dgqjos1uLabNFKcNI7bjF5o74HE5dMN15c8GZNKGzq/CConQKcbvjzBpZQNI5VYCKvkEe7OA2jDmXBpT+Fafx/WMrt9Tbpl0OxtGJb41oPCncKrnvBIvRWTu3rRCj2PXLIZrPP4SjU3KZH5M5k+OIoTm9smlJt0wgkI1pXVjMnk1gAOGu3zrlUlzRHFMxepfhGDTYQg2H4ZY/T4EOcaHZdKE/1w3Qpw+iasIuYW64dpyU9qZuoMNHCw3nYk37IWpliOa3Wh4AfrLjOduNfLbdFt5du40bjPmFz133KKf/47NhBDODbV+eyYcN+9aMBXanmcYZnva5PyMjMdysrLUHL3+EtqsNS8PjrUdhUBrC3RlPQFdu7bD2JFD8P4bb0KRxQKomUP70sgwHrPZ/HgKhM4zJoMBchgGzEYjkKIiEA9UweLSXxA9/wVEPjsHd5f/BkWUtFgeaqiW5mTr9RdWQQwzSgNGvV4TEJsNSHERTE5Mwdmrv8Gn38xDJBQFHv3UKCCpxSKCKRA6R5Kg7KwsKCkoALawAD7u6IAPu3+G9y7chlMnTgCLfhqjmiQI32ObgszZ2VCYmwtSxQEQ3/ZD1Vt+kCurocBk0o6+JVASlm/KAaedBZunG2w1F0FgHWDJWYVsGWTB3UttVmArPwC2qgNKS6wIN/0/UNLYgjzg974O/L5D4MD1+viWQFpV2A8nKYNSvmzDsTYDedNVpFVlLQSH1Zo2lsgZT4GyGaY3NzGQDxoV017R3qTm5gFLzNNgCmQwGEw5BkMnjvzXaFfWmF5/39b772vP5jKMmTL+BXjFSvulgFRbAAAAAElFTkSuQmCC
""")

def main(config):
    timezone = config.get("timezone") or "America/New_York"
    now = time.now().in_location(timezone)

    DEFAULT_TIME = time.now().in_location(timezone).format("2006-01-02T15:04:05Z07:00")

    future = time.parse_time(config.str("event_time", DEFAULT_TIME))
    dateDiff = future - time.now().in_location(timezone)
    days = math.floor(dateDiff.hours / 24)
    hours = math.floor(dateDiff.hours - days * 24)
    minutes = math.floor(dateDiff.minutes - (days * 24 * 60 + hours * 60))

    fadeList = []  # The list of the fading text near the bottom, or a static date if the event has passed
    dayString = "IS HERE!"  # The amount of days left, or a static message if the event has passed

    if (time.now() < future):
        # Create the lists that will make the fading text
        dayString = "{} {}".format(str(days), "day" if days == 1 else "days")
        fadeList = appendFadeList(fadeList, "{} {}".format(str(hours), "hr" if hours == 1 else "hrs"), 30)
        fadeList = appendFadeList(fadeList, "{} {}".format(str(minutes), "min" if minutes == 1 else "mins"), 20)
    else:
        # Event date has already passed, so show the date of the event
        fadeList.append(render.Text(future.format("01-02-2006"), font = "CG-pixel-4x5-mono", color = "#888888"))

    # Create event text widget based on text length
    eventText = config.str("event", "Event")

    if len(eventText) < 14:
        eventWidget = render.Text(content = eventText, font = "5x8", color = "#21631a")
    else:
        eventWidget = render.Marquee(
            child = render.Text(content = eventText, font = "5x8", color = "#21631a"),
            width = 64,
        )

    return render.Root(
        delay = 100,
        child = render.Box(
            render.Row(
                expanded=True,
                main_align="space_evenly",
                cross_align="center",
                children = [
                    render.Image(src=RAT_MAN_ICON),
                    render.Column(
                        expanded = True,
                        main_align = "center",
                        cross_align = "center",
                        children = [
                            eventWidget,
                            # render.Text(content = dayString, font = "5x8"),
                            render.Text(content = dayString, font = "tb-8"),
                            render.Box(width = 64, height = 1),
                            render.Animation(
                                children = fadeList,
                            ),
                        ],
                    ),
                ],
            ),
        ),
    )

# Create an fading animation
def appendFadeList(fadeList, text, cycles):
    for x in range(0, 10, 2):
        c = "#" + str(x) + str(x) + str(x) + str(x) + str(x) + str(x)
        fadeList.append(render.Text(text, font = "CG-pixel-4x5-mono", color = c))
    for x in range(cycles):
        fadeList.append(render.Text(text, font = "CG-pixel-4x5-mono", color = "#888888"))
    for x in range(8, 0, -2):
        c = "#" + str(x) + str(x) + str(x) + str(x) + str(x) + str(x)
        fadeList.append(render.Text(text, font = "CG-pixel-4x5-mono", color = c))
    return fadeList

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "event",
                name = "Event",
                desc = "The event text to display.",
                icon = "cog",
            ),
            schema.DateTime(
                id = "event_time",
                name = "Event Time",
                desc = "The time of the event.",
                icon = "cog",
            ),
        ],
    )
```

## LaunchD plist Source

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.everythingisgray.rat-man</string>
	<key>ProgramArguments</key>
	<array>
		<string>/Users/james/src/rat-man-tidbyt/run_rat_man.sh</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StartInterval</key>
	<integer>90</integer>
	<key>WorkingDirectory</key>
	<string>/Users/james/src/rat-man-tidbyt</string>
</dict>
</plist>
```

## Shell Script Source

```sh
#!/bin/bash

/opt/homebrew/bin/pixlet render rat_man.star event="Rat Man" event_time="2023-05-27T12:00:00Z"
/opt/homebrew/bin/pixlet push --installation-id RatManClock confidently-realistic-replete-alewife-bb3 rat_man.webp
```

Now I have an automatically updated, custom Tidbyt app without having to publish it as a community app. :)

![Rat Man In Action](/images/2023-05-24-custom-tidbyt-apps/rat_man_tidbyt_shelf.png "Rat Man In Action")

The [source code](https://github.com/futureimperfect/rat-man-tidbyt) and [instructions](https://github.com/futureimperfect/rat-man-tidbyt/blob/main/README.md) are available on my GitHub profile. It should go without saying that this will work on other platforms besides macOS, (e.g., with a cron job), but I was just trying to get something working. Hope this helps!
