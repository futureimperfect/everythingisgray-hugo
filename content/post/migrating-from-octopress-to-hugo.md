---
title: "Migrating From Octopress to Hugo"
date: 2020-11-03T20:09:25-05:00
draft: true
---

![Hugo](/images/hugo-logo-wide.svg "Hugo Logo")

I recently migrated my blog from [Octopress](http://octopress.org/) to [Hugo](https://gohugo.io/). I did this for a few reasons:

1. I know next to nothing about Ruby, so troubleshooting toolchain and dependency issues in order to deploy my static site was a huge pain.
2. Octopress hasn't been updated in _years_. Hugo, on the other hand, is _very_ actively maintained.
3. Hugo is written in Go, which I'm more familiar with. It's also fast and fairly customizable.

I initially looked into migrating to [Pelican](https://blog.getpelican.com/), which is a static site generator written in Python, (which I also love). Pelican has been around for a while and seems to have a great community surrounding it, but ultimately I chose Hugo because I'm writing more Go than Python these days, and the handful of times I used Hugo at my last job I was impressed with its speed and ease of use. Another reason I ended up going with Hugo is because I found a migration tool called [Octohug](https://github.com/codebrane/octohug) and was able to stand up a local version of my existing site _very_ quickly, (albeit with a few issues at first). Next, I'll walk through some of the steps I took to migrate this blog.

## Getting Started

To get started, take a look at the wonderful [Hugo Quick Start](https://gohugo.io/getting-started/quick-start/) instructions. These will get you up-and-running with a new Hugo site really quickly.

```sh
$ brew install hugo  # on macOS
$ hugo new site <site_name>
$ cd <site_name>
```

Once you've created your site, take a look at `config.yml` and fill in the details. Now might also be a good time to dig in to the excellent [Hugo docs](https://gohugo.io/documentation/) and check out the [themes directory](https://themes.gohugo.io/).

## Migrating Posts With Octohug

Both Octopress and Hugo use Markdown files as the source for content, so migrating from one to the other isn't particularly burdensome. For the most part, you can just copy the files from one repo to another and things will _just work_. However, there are some minor differences betweeen the [Octopress](https://jekyllrb.com/docs/front-matter/) and [Hugo front matter](https://gohugo.io/content-management/front-matter/), and having a conversion tool may prove useful, especially if you've got more than a handful of posts. Fortunately, there's a simple project for this exact purpose called [Octohug](https://github.com/codebrane/octohug). It converts posts from an Octopress repo so that they can be copied into a Hugo `content` directory.

```sh
$ cd ~/src && git clone https://github.com/codebrane/octohug.git
$ cd octohug
$ go build octohug.go
$ cp octohug /path/to/octopress_site
$ cd /path/to/octopress_site
$ ./octohug
```

Once you run the `octohug` binary in your Octopress repo, it will output a new `content` directory that can be copied over to your new Hugo repo.

```sh
$ cp -R /path/to/octopress_site/content/post /path/to/hugo_site/content
```

I initially ran into a couple issues with the posts as converted by Octohug. In particular, the categories and tags didn't convert properly, and post titles were all lower case. However, I was able to address this pretty easily and submitted [a PR to fix it](https://github.com/codebrane/octohug/pull/9), which has since been merged.

## Fine Tuning Things

Once posts were moved over, I had to manually copy over some other pages, (and therefore manually update their front matter). I also moved all images from the old to the new repo.

```sh
$ cp -R /path/to/octopress_repo/source/images/* /path/to/hugo_repo/static/images/
```

I also had to move over my static `downloads` folder, which currently just contains [my résumé](/downloads/resume.pdf).

```sh
$ mkdir -p <hugo_repo>/static/downloads
$ cp source/downloads/resume.pdf ~/src/everythingisgray-hugo/everythingisgray/static/
```

## Shortcodes

I used [YouTube](https://github.com/erossignon/jekyll-youtube-lazyloading) and Gist plugins for Octopress, which allowed me to insert a shortcode to embed those types of content into my posts. Fortunately, both [YouTube](https://gohugo.io/content-management/shortcodes/#youtube) and [Gist](https://gohugo.io/content-management/shortcodes/#gist) shortcodes are built right into Hugo, so it was only a matter of updating the shortcode syntax.

For example, the `youtube` shortcode needed to change from this:

```html
{% youtube 12345 %}
```

...to this:

```html
{{\< youtube 12345 \>}}  <!-- Don't include backslashes in your shortcodes. -->
```

And the `gist` shortcode needed to change from this:

```html
{% gist 12345 %}
```

...to this:

```html
{{\< gist 12345 6789 \>}}  <!-- Don't include backslashes in your shortcodes. -->
```

## Comments

I previously used [Disqus](https://disqus.com/) for comments, and have done the same with this Hugo site. Again, this was pretty easy to get working, since [the Hugo theme I'm using](https://themes.gohugo.io/hugo-theme-cactus/) supports this, as well as Hugo itself. The only trouble I ran into was that some posts had slightly different slugs after the imprort, and therefore Disqus wouldn't work since it associates comments with the URL of posts. The fix is either to update the slug or URL in the post's front matter, or simply add an [alias](https://gohugo.io/content-management/urls/#aliases), which will result in Hugo [generating an HTML page that will redirect that page to the actual URL](https://gohugo.io/content-management/urls/#how-hugo-aliases-work).

Also, because I wasn't using HTTPS before (:shame:), I had to change the site URL in my Disqus settings to start with `https://`.

## Trying It Out

You can run your site locally very easily with the `hugo` CLI. Assuming everything works as expected you should be able to visit your site at http://localhost:1313 in your browser.

```sh
$ hugo server -D
```

## Troubleshooting

For whatever reason, I had some posts that were previously published on my Octopress site not showing up on my new Hugo site. After researching this for a bit, I discovered that they were [drafts](https://gohugo.io/getting-started/usage/#draft-future-and-expired-content). To confirm that this was the issue, I built the site with the `--buildDrafts` flag, and sure enough the posts were visible. The fix was just to remove the `draft: true` front matter from those posts.

```sh
$ hugo --buildDrafts
```

## Deploying to GitHub Pages

I was using [Heroku](https://www.heroku.com/) to host my Octopress site, which seemed like overkill for serving static HTML and CSS files. I also had no other experience with Heroku outside of using it to host my blog, so it was always a chore any time I needed to interact with the CLI tools or visit the admin console. GitHub, on the other hand, I use almost daily, and I've used it to host static files for other projects in the past, so deploying to GitHub Pages seemed like an obvious choice: plus, it's free. :)

Once again, there's [a great tutorial on hosting Hugo sites on GitHub Pages](https://gohugo.io/hosting-and-deployment/hosting-on-github/). I mostly just followed these instructions. The only (minor) hiccup I ran into was that I had to make sure that the GitHub Pages repo had something in it, (e.g., a `README.md`), before I could add it as a submodule to my Hugo repo, (this is obvious in retrospect). Once that was all set up my workflow for writing new posts is the following:

```sh
$ hugo new post/my-new-post.md  # Write stuff.
$ ./deploy.sh  # This will create a new commit in submodule.
$ git add .
$ git commit -m "Added new post about..."
$ git push -u origin master
```

I could also automate publishing the site on new commits to the `master` branch with [GitHub Actions](https://github.com/features/actions) or similar, but I haven't gotten there yet.

## Updating DNS

[GitHub Pages supports custom domains](https://docs.github.com/en/free-pro-team@latest/github/working-with-github-pages/managing-a-custom-domain-for-your-github-pages-site), and setting this up is really easy. Just create a `CNAME` record that points your subdomain to your GitHub Pages domain, (e.g., `username.github.io` or `organization.github.io`). If you also want www.yoursite.com to work, create a `CNAME` record for that which points to `username/organization.github.io` as well. You can also just check a box to enforce HTTPS, which is pretty slick tbh.

```txt
CNAME @ futureimperfect.github.io
CNAME www futureimperfect.github.io
```

## Conclusion

Hopefully this post is useful to others that find themselves in a similar situation and want to try out Hugo. The next things I'd like to get working with this setup are iOS posting and automating the GitHub Pages deployment, so if I get to that I'll write another post about those experiences. If you have any questions or suggestions feel free to leave them in the comments!
