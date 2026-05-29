source 'https://rubygems.org'

ruby '2.7.8'

gem 'middleman', '~> 4.5.1'
gem 'middleman-sprockets', '~> 4.1'
gem 'middleman-livereload', '~> 3.4.0' # 3.5.0 requires Ruby >= 2.7

gem 'rack-contrib'
gem 'puma'

# concurrent-ruby 1.3.5+ stopped requiring 'logger', which breaks activesupport
# < 7.1 (middleman caps it at < 7.1) with an uninitialized-constant Logger error.
gem 'concurrent-ruby', '1.3.4'

# Sass toolchain held at the last Ruby-Sass versions so the existing SCSS needs
# no rewrite (Bourbon 5+/Neat 2+ dropped these mixins). 'sass' pins Ruby Sass
# (not libsass), which Bourbon 4 / Neat 1 require.
gem 'sass'
gem 'haml', '~> 5.2' # 6+ / 7+ require newer Ruby than 2.6
gem 'bitters'
gem 'bourbon', '~> 4.0'
gem 'neat', '~> 1.7'

# font-awesome-middleman is pinned to middleman ~> 3.0, so it can't move to MM4.
# Font Awesome 4.7 is loaded via CDN in the layout (see layouts/layout.erb).
# TODO: revisit self-hosting (font-awesome-sass) when modernizing the toolchain.
