source 'https://rubygems.org'

ruby '3.3.11'

gem 'middleman', '~> 4.6'
gem 'middleman-sprockets', '~> 4.1'
gem 'middleman-livereload', '~> 3.4.0' # 3.5.0 requires Ruby >= 2.7

gem 'rack-contrib'
gem 'puma'
gem 'rake'

# Sass toolchain held at the last Ruby-Sass versions so the existing SCSS needs
# no rewrite (Bourbon 5+/Neat 2+ dropped these mixins). 'sass' pins Ruby Sass
# (not libsass), which Bourbon 4 / Neat 1 require.
gem 'sass'
gem 'bitters'
gem 'bourbon', '~> 4.0'
gem 'neat', '~> 1.7'

# font-awesome-middleman is pinned to middleman ~> 3.0, so it can't move to MM4.
# Font Awesome 4.7 is loaded via CDN in the layout (see layouts/layout.erb).
# TODO: revisit self-hosting (font-awesome-sass) when modernizing the toolchain.
