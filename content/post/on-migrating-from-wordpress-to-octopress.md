+++
title = "On Migrating From WordPress to Octopress"
date = "2013-06-15"
slug = "2013/06/15/on-migrating-from-wordpress-to-octopress"
Categories = ["Web Development", "Octopress", "WordPress"]
Tags = ["Web Development", "Octopress", "WordPress"]
+++

Having recently made the decision to migrate my blog from WordPress to [Octopress][10] I decided I would share my findings in hopes that someone else will benefit from them, and so I can refer back to this post should I need to do something similar in the future.

The primary reason I decided to move to a statically generated site is because I found myself spending more time worrying about whether my site was running and was secure than I did writing. My site was hacked last year because I was running an outdated version of WordPress, and since moving to a new host, (Amazon EC2), I have frequently had to restart MySQL and Apache just to keep the site up. This could be partially due to the fact that I was running the site on a [micro instance][11], but now that my blog is static I don't have to worry about that any longer. Another reason why I chose Octopress for my blogging platform is that I like to tinker, and being able to use tools that I'm already familiar with and use every day was a huge plus, (Vim, Git, and Markdown, specifically).

So, without further ado[^1], here are the steps I took to mirgrate from WordPress running on an Amazon EC2 instance to Octopress running on Heroku.

## Prepping Your Environment

I performed the migration using a fairly stock OS X 10.8 machine. If you're using a Mac, you should probably be using [Homebrew][1] to manage packages.

{% codeblock lang:bash %}
brew update
brew doctor
brew install rbenv
{% endcodeblock %}

The next thing you should do is add the following to your ~/.bash_profile.

{% codeblock lang:bash %}
# To use Homebrew's directories rather than ~/.rbenv add to your profile:
export RBENV_ROOT=/usr/local/var/rbenv

# To enable shims and autocompletion add to your profile:
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
{% endcodeblock %}

Then `source ~/.bash_profile`.

Now install Ruby 1.9.3 with rbenv.

{% codeblock lang:bash %}
brew install ruby-build
brew update
brew tap homebrew/dupes
brew install automake apple-gcc42
rbenv install 1.9.3-p194
rbenv rehash
rbenv global 1.9.3-p194
ruby --version # Should now return 1.9.3
{% endcodeblock %}

## Setting Up Your Local ~/Sites Directory and Installing Octopress

On OS X 10.8 the ~/Sites folder no longer exists in the home directory by default. No problem though, because we can create it, and we'll even get the correct permissions and pretty icon when we do so.

I also recommend checking out [Anvil][2] for Mac. This will allow you to easily manage your local site and give you a .dev domain for testing. Best of all, it's free.

{% codeblock lang:bash %}
mkdir ~/Sites
cd ~/Sites
git clone git://github.com/imathis/octopress.git <sitename>
cd <sitename>
gem install bundler
rbenv rehash
bundle install
rake install
{% endcodeblock %}

If you took my advice and installed [Anvil][2] for Mac, do the following to create a symlink to your site in the `~/.pow` directory.

{% codeblock lang:bash %}
cd ~/.pow
ln -s ~/Sites/<sitename> <sitename>
cd -
rake generate && rake watch
{% endcodeblock %}

## Use rack-rewrite for Redirects

This is useful for redirecting old URLs to your new Octopress site, especially if you used date-based permalinks for archives on WordPress, (something like example.com/2012/02/22), and you want those to redirect to /archives on your new site.

Add this to the end of your Gemfile.
{% codeblock lang:ruby Gemfile %}
gem 'rack-rewrite'
{% endcodeblock %}

Add this to config.ru.
{% codeblock lang:ruby config.ru %}
require 'rack-rewrite'
{% endcodeblock %}

Under `$root = ::File.dirname(__FILE__)` in config.ru add your redirects, (these are just some examples). Of particular interest are the regular expressions that redirect dates in yyyy-mm-dd format to /archives.

{% codeblock lang:ruby config.ru %}
use Rack::Rewrite do
    r301 /.*/,  Proc.new {|path, rack_env| "http://#{rack_env['SERVER_NAME'].     gsub(/www\./i, '') }#{path}" },
      :if => Proc.new {|rack_env| rack_env['SERVER_NAME'] =~ /www\./i}
    r301 %r{^/tag/art/?$}, '/category/art/'
    r301 %r{^/tag/design/?$}, '/category/design/'
    r301 %r{^/tag/os-x/?$}, '/category/os-x/'
    r301 %r{^/tag/science/?$}, '/category/science/'
    r301 %r{^/tag/technology/?$}, '/category/technology/'
    r301 %r{^/tag/uncategorized/?$}, '/category/uncategorized/'
    r301 %r{^/tag/web-design/?$}, '/category/web-design/'
    r301 %r{^/tag/web-development/?$}, '/category/web-development/'
    r301 %r{^/tag/wordpress/?$}, '/category/wordpress/'
    r301 %r{^/[0-9]{4}/(1[0-2]|0[1-9])/(3[01]|[12][0-9]|0[1-9])/?$}, '/archives/'
    r301 %r{^/[0-9]{4}/(1[0-2]|0[1-9])/?$}, '/archives/'
    r301 %r{^/[0-9]{4}/?$}, '/archives/'
end
{% endcodeblock %}

Install rack-rewrite.

{% codeblock lang:bash %}
bundle install
bundle
bundle show rack-rewrite
rake generate && rake watch
{% endcodeblock %}

Now restart your local server, (turn the slider on and off with Anvil).

## Create _heroku Directory for Deployment

I opted to keep the generated Heroku site in a separate repository so I can keep public in my .gitignore. This will help keep your commit history clean, as not (nearly) every file that Git is tracking will change every time you re-generate your site.

{% codeblock lang:bash %}
cd ~/Sites/<sitename>
mkdir _heroku
cp config.ru _heroku/
cp Gemfile _heroku/
cd _heroku
mkdir public
{% endcodeblock %}

Create an HTML file in _heroku/public so you can deploy to Heroku.

{% codeblock lang:bash %}
touch ~/Sites/<sitename>/_heroku/public/index.html
echo '<html><p>Hello world.</p></html>' > ~/Sites/<sitename>/_heroku/public/index.html
{% endcodeblock %}

Make the Gemfile in _heroku only include these lines.

{% codeblock lang:ruby %}
source "http://rubygems.org"

gem 'sinatra', '~> 1.4.2'
gem 'rack-rewrite'
{% endcodeblock %}

Add this task to your Rakefile. This will result in your site being deployed to Heroku when you type `rake deploy`. Don't run `rake deploy` at this time, though, because you haven't set up Heroku yet.

{% codeblock lang:ruby Rakefile %}
desc "Deploy a basic rack app to heroku"
multitask :heroku do
puts "## Deploying to Heroku"
    (Dir["#{deploy_dir}/public/*"]).each { |f| rm_rf(f) }
    system "cp config.ru #{deploy_dir}/"
    system "cp -R #{public_dir}/* #{deploy_dir}/public"
    puts "\n## Copying #{public_dir} to #{deploy_dir}/public"
    cd "#{deploy_dir}" do
        system "git add ."
        system "git add -u"
        puts "\n## Committing: Site updated at #{Time.now.utc}"
        message = "Site updated at #{Time.now.utc}"
        system "git commit -m '#{message}'"
        puts "\n## Pushing generated #{deploy_dir} website"
        system "git push heroku #{deploy_branch}"
        puts "\n## Heroku deploy complete"
    end 
end
{% endcodeblock %}

...then update these variables, (in your Rakefile).

{% codeblock lang:ruby %}
deploy_default = "heroku"
deploy_branch = "master"
deploy_dir = "_heroku"
{% endcodeblock %}

## Signing up for and Configuring Heroku

Now it's time to sign up for a free [Heroku][3] account. The Octopress documentation recommends installing the heroku gem, but that's deprecated so download and install the [Heroku Toolbelt][4] instead.

{% codeblock lang:bash %}
ssh-keygen # Generate a public/private key pair
heroku create # Enter your Heroku credentials
<number_for_public_key> <ENTER>` # Use the public key that was created when you ran `ssh-keygen`
heroku rename <sitename> # Also make sure that `url:` in _config.yml matches http://<sitename>.herokuapp.com
{% endcodeblock %}

Now you can do your first deploy to Heroku!

{% codeblock lang:bash %}
cd ~/Sites/<sitename>/_heroku
git init .
git add .
git config branch.master.remote heroku
git commit -am "Initial commit."
rake generate && rake watch
rake deploy
{% endcodeblock %}

## Exporting your WordPress Posts and Comments

Log on to your WordPress Admin and export your content in XML format. You can find this under Tools > Export. Keep this data handy because we'll be using it in the next step.

The next steps I took were to sign up for a free [Disqus][12] account, install the (Disqus) WordPress plugin, and export my comments to Disqus from the plugin options. This will ensure that your comments are preserved after migrating to Octopress, (as long as your permalinks don't change). Also be sure to add your Disqus shortname to _config.yml.

## Importing your WordPress data into your Octopress Site

There are a number of tools available for importing your WordPress posts into Octopress as Markdown files, but the one I ended up using was [exitwp][5]. You can follow these steps to import your WordPress site with exitwp.

{% codeblock lang:bash %}
brew install python
printf '\nexport PATH=/usr/local/share/python:$PATH' >> ~/.bash_profile
source ~/.bash_profile
pip install virtualenv
pip install virtualenvwrapper
source /usr/local/share/python/virtualenvwrapper.sh
mkvirtualenv --no-site-packages octopress # Don't symlink site packages so your environment is more isolated
brew install libyaml
pip install pyyaml
pip install BeautifulSoup4
pip install html2text
cd ~/Documents
git clone https://github.com/thomasf/exitwp
{% endcodeblock %}

Now, copy your WordPress XML files to ~/Documents/exitwp/wordpress-xml, then run `xmllint` on your export file and address any errors you encounter. You should also customize what you want exported in ~/Documents/exitwp/config.yaml, (e.g., whether or not you want images to be downloaded and included in your build directory). To run the tool type `python exitwp.py` in the terminal from within the ~/Documents/exitwp directory.

You should now see your converted site in ~/Documents/exitwp/build, which you can copy to your source directory.

## Remove /blog/ from Octopress URL

Follow these steps if you don't want /blog/ to appear in your Octopress URL.

Update the permalink setting in _config.yml.
{% codeblock lang:ruby _config.yml %}
permalink: /:year/:month/:day/:title/
{% endcodeblock %}

Move the contents of the blog directory.

{% codeblock lang:bash %}
mv ~/Sites/<sitename>/source/blog/archives ~/Sites/<sitename>/source/archives
mv ~/Sites/<sitename>/source/blog/articles/index.html ~/Sites/<sitename>/source/articles/index.html
rm -rf ~/Sites/<sitename/source/blog
{% endcodeblock %}

Update the navigation in source/_includes/custom/navigation.hmtl.

{% codeblock lang:html %}
# Change this
<li><a href="{{ root_url }}/blog/archives">Archives</a></li>
# to this
<li><a href="{{ root_url }}/archives">Archives</a></li>
# ...and this:
<li><a href="{{ root_url }}/">Blog</a></li>
# to this:
<li><a href="{{ root_url }}/">Home</a></li>
{% endcodeblock %}

Update the Archives link in source/index.html.

{% codeblock lang:html %}
# Change this:
<a href="/blog/archives">Blog Archives</a>
# to this:
<a href="/archives">Archives</a>
{% endcodeblock %}

Update the category base URL in _config.yml.

{% codeblock lang:ruby %}
# Change this:
category_dir: blog/categories
# to this:
category_dir: category
# ...and this:
pagination_dir: blog
# to this:
pagination_dir:
{% endcodeblock %}

Update the Archives page title in source/archives/index.html.

{% codeblock lang:ruby %}
# Change this:
title = "On Migrating From Wordpress to Octopress"
# to this:
title = "On Migrating From Wordpress to Octopress"
{% endcodeblock %}

## Change Author Name After Importing from WordPress

Another thing that bothered me for a while about my WordPress blog was that the author metadata for posts and pages reflected the 'admin' shortname. This is because I left the default username when initally setting up WordPress years ago. I'm sure there's an easy way to change this, but now that my blog consists of plain text files I have the freedom to use whatever tools I choose to make changes. Here's a perfect example of that using find and sed.

{% codeblock lang:bash %}
cd ~/Sites/<sitename>/source && find . -name "*.markdown" -print0 | xargs -0 sed -i '' -e 's/author:\ admin/author:\ Forename\ Surname/g'
{% endcodeblock %}

## Using Google Fonts

If you love Google Fonts add this to the top of `source/_includes/custom/head.html`, (just be sure to use your own favorite fonts!).

{% codeblock lang:html %}
<link href='http://fonts.googleapis.com/css?family=Archivo+Narrow:400,700' rel='stylesheet'  type='text/css'>
{% endcodeblock %}

## Prevent Comment Text from Wrapping on Small Screens

One of the first things I noticed with the default Octopress theme is that the Disqus comments text that appears above posts was wrapping on smaller screens, which caused it to overlap with the post title. To fix this, I added the following to sass/custom/_styles.scss.

{% codeblock lang:css _styles.scss %}
article { 
    header {
        p {   
            &.meta {
                font-size: .7em;
            }     
        }       
    }
}

@media only screen and (min-width: 480px) {
    article {
        header {
            p {
                &.meta {
                    font-size: .9em;
                }
            }
        }   
    }   
}
{% endcodeblock %}

## 404

You might also want a custom 404 page. Fortunately, that's pretty easy too.

{% codeblock lang:bash %}
cd ~/Sites/<sitename> && rake new_page[404]
cd source/404
mv index.markdown 404.markdown
mv 404.markdown ../
cd ../
rm -rf 404
{% endcodeblock %}

Then update the yaml front matter in 404.markdown.

## Fancybox

I followed a post on [Ewal.net][6] to get Fancybox working with Octopress. The only difference is that I didn't add a reference to jQuery in the head because it's already present in the default installation of Octopress.

To add Fancybox support to an image simply add this to your post.
{% codeblock lang:ruby %}
{% img fancybox /dir/foo.jpg Title %}
{% endcodeblock %}

{% codeblock lang:javascript source/javascripts/anchor.js %}
$(function() {
    $('.entry-content').each(function(i){
        var _i = i;
            $(this).find('img.fancybox').each(function(){
            var img = $(this);
            var title = img.attr("title");
            var classes = img.attr("class");
            img.removeAttr("class");
            img.wrap('<a href="'+this.src+'" class="' + classes + '" rel="gallery'+_i+'" /   >');
            if (title != "")
            {
                img.parent().attr("title", title);
            }
        });
    });
    $('.fancybox').fancybox();
});
{% endcodeblock %}

## Open Vim when running rake new_post and make new posts un-published by default

Add the following to your Rakefile if you want `rake new_post` to open in your editor and new posts to be un-published by default. Replace Vim with your favorite editor if you dare. :)

{% codeblock lang:ruby Rakefile %}
desc "Begin a new post in #{source_dir}/#{posts_dir}"
task :new_post, :title do |t, args|
    if args.title
        title = args.title
    else
        title = get_stdin("Enter a title for your post: ")
    end 
    raise "### You haven't set anything up yet. First run `rake install` to set up an    Octopress theme. "
    unless File.directory?(source_dir)
    mkdir_p "#{source_dir}/#{posts_dir}"
    filename = "#{source_dir}/#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.     to_url}. #{new_post_ext}"
    if File.exist?(filename)
        abort("rake aborted!") if ask("#{filename} already exists. Do you want to        overwrite?", ['y', 'n']) == 'n' 
    end 
    puts "Creating new post: #{filename}"
    open(filename, 'w') do |post|
        post.puts "---"
title = "On Migrating From Wordpress to Octopress"
date = ""
slug = "/on-migrating-from-wordpress-to-octopress"
published = false
Categories = [
