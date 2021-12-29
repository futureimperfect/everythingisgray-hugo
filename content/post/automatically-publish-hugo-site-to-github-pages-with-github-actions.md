---
title: "Automatically Publish Hugo Site to GitHub Pages With GitHub Actions"
date: 2021-12-29T00:47:13-05:00
---

In [a previous post](/2020/11/03/migrating-from-octopress-to-hugo/) I described my process for migrating an existing Octopress site to Hugo, and at the end I said I wanted to figure out how to automatically publish the site to GitHub Pages with GitHub Actions next. I ended up finding a solution for this a while ago, but I wasn't particularly happy with the way it was set up. Before getting too far, though, it's worth mentioning that I ended up going with a multi-repository approach rather than using the same repo with a separate `gh-pages` orphan branch. I didn't necessarily have a good reason for picking one approach over the other, except that this was how I got it working initially and I just stuck with it. :) Anyway, the reason I wasn't happy with how it was setup before (and why I decided to change it recently) is that I had [a separate deploy script](https://github.com/futureimperfect/everythingisgray-hugo/blob/e43a6b290b978e86ac27dfe223920b0006d2b223/deploy.sh) for building the Hugo site and publishing the changes to the target repo, but I wanted to use available actions from the [GitHub Actions Marketplace](https://github.com/marketplace?type=actions) as much as possible, and to have a single YAML file to manage it all. Previously, I was using a GitHub Action called [`ssh-agent`](https://github.com/marketplace/actions/webfactory-ssh-agent) to load my SSH private key into the SSH agent on the GitHub Actions runners, which was then used for performing Git operations in the deploy script. It turns out that a simpler solution exists if all you want to do is build a Hugo site and deploy it to a separate GitHub Pages repo using GitHub Actions, though. This involves using the [`peaceiris/actions-hugo`](https://github.com/peaceiris/actions-hugo) and [`peaceiris/actions-gh-pages`](https://github.com/peaceiris/actions-gh-pages) actions. Next, I'll share how I set this up.

## How To: Automatically Publish a Hugo Site to GitHub Pages With GitHub Actions

First, I created a new SSH key pair to use as my GitHub Actions [deploy key](https://docs.github.com/en/developers/overview/managing-deploy-keys).

```sh
# NOTE: -N specifies a new passphrase and -C supplies a comment.
ssh-keygen -t ed25519 -a 100 -C "$(git config user.email)" -f ~/.ssh/id_ed25519_futureimperfect_github_io_deploy_key -N ""
```

Next, I added the private key as a [repository secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets) in the [source repo](https://github.com/futureimperfect/everythingisgray-hugo), (e.g., where my Hugo source files live). This must be named `ACTIONS_DEPLOY_KEY`.

```sh
# Copy private key and add it as a repository secret to the source (Hugo) repository.

# NOTE: pbcopy is a macOS-specific tool which provides copying and pasting to the pasteboard from the command line.
cat ~/.ssh/id_ed25519_futureimperfect_github_io_deploy_key |pbcopy
```

![Add SSH Private Key as a Repository Secret in Your Source Repo](/images/2021-12-29-automatically-publish-hugo-site-to-github-pages-with-github-actions/actions_secrets.png "Add SSH Private Key as a Repository Secret in Your Source Repo")

Then, I added the public key as a deploy key in the [target repo](https://github.com/futureimperfect/futureimperfect.github.io), (e.g., this is your `<username>.github.io` GitHub Pages repo where your static resources live).

```sh
# Create a deploy Key in the target GitHub Pages repository.
cat ~/.ssh/id_ed25519_futureimperfect_github_io_deploy_key.pub |pbcopy
```

![Add SSH Public Key as a Deploy Key in Your Target Repo](/images/2021-12-29-automatically-publish-hugo-site-to-github-pages-with-github-actions/add_deploy_key.png "Add SSH Public Key as a Deploy Key in Your Target Repo")

Finally, I setup my GitHub Actions YAML file in the source repo. This builds my Hugo site from source files and deploys it to a separate GitHub Pages repo. I have this configured to automatically deploy my site when changes are pushed to the `main` branch. My current (at the time of this writing) `gh-pages.yml` file is below:

```yaml
# Deploy site to GitHub Pages on commit to master branch.
name: github-pages-deploy

on:
  # Triggers the workflow on push events but only to the master branch.
  push:
    branches: [master]

  # Allows you to run this workflow manually from the Actions tab.
  workflow_dispatch:

jobs:
  build-deploy:
    runs-on: ubuntu-20.04
    steps:
      # Checks-out the repository under $GITHUB_WORKSPACE,
      # so the job can access it.
      - uses: actions/checkout@v2
        with:
          submodules: true  # Fetch Hugo themes (true OR recursive)
          fetch-depth: 0    # Fetch all history for .GitInfo and .Lastmod

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: '0.89.2'

      - name: Build
        run: hugo --minify -t cactus

      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        if: ${{ github.ref == 'refs/heads/master' }}
        with:
          cname: everythingisgray.com
          commit_message: ${{ github.event.head_commit.message }}
          deploy_key: ${{ secrets.ACTIONS_DEPLOY_KEY }}
          external_repository: futureimperfect/futureimperfect.github.io
          # Allows you to make your publish branch only
          # include the latest commit.
          force_orphan: true
          publish_branch: master
          publish_dir: ./public
          user_name: 'github-actions[bot]'
          user_email: 'github-actions[bot]@users.noreply.github.com'
```

With these changes I can now make a change to my Hugo source repository and sit back and relax as my Hugo site is automatically deployed to my target GitHub Pages repo. Voilà!

## Posting From iOS

I also mentioned in that post that I'd like to get posting from iOS working too. I haven't tried it, mostly because I don't really _do work_ on iOS devices much these days. However, I've tried [this approach](https://www.macstories.net/ios/my-markdown-writing-and-collaboration-workflow-powered-by-working-copy-3-6-icloud-drive-and-github/) in the past for working with Markdown files in a Git repo and it worked rather well, so if I ever feel so inclined I might try that here too.
