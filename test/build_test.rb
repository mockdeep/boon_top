# End-to-end test of the static build output.
#
# Runs the real `middleman build` once (verifying the render/asset gem stack
# is compatible and loads), then asserts the generated artifact looks right.
#
#   bundle exec ruby test/build_test.rb
#
require 'minitest/autorun'

# Mirrors `set :build_dir, 'tmp'` in config.rb.
BUILD_DIR = File.expand_path('../../tmp', __FILE__)

# Build once at load time rather than per-test, so we run middleman once.
BUILD_OUTPUT = `bundle exec middleman build 2>&1`
BUILD_STATUS = $?.exitstatus

class BuildTest < Minitest::Test
  def test_build_exits_successfully
    assert_equal 0, BUILD_STATUS, "middleman build failed:\n#{BUILD_OUTPUT}"
  end

  def test_index_has_expected_content
    index = File.join(BUILD_DIR, 'index.html')
    assert File.exist?(index), "expected #{index} to be generated"

    html = File.read(index)
    assert_includes html, '<title>Welcome to Boon.gl</title>'
    assert_includes html, '<h1>Boon.gl</h1>'
    assert_includes html, 'Robert Fletcher'
    assert_includes html, 'blog.boon.gl'
  end

  def test_assets_compiled
    css = File.join(BUILD_DIR, 'stylesheets', 'all.css')
    js  = File.join(BUILD_DIR, 'javascripts', 'all.js')
    assert File.exist?(css), 'expected stylesheets/all.css to compile'
    assert File.exist?(js),  'expected javascripts/all.js to be built'
  end

  def test_social_icons_are_inline_svg
    html = File.read(File.join(BUILD_DIR, 'index.html'))
    assert_includes html, '<svg', 'expected inline SVG icons in the page'
    refute_includes html, 'font-awesome', 'Font Awesome should no longer be referenced anywhere'
    assert_includes html, 'github.com/mockdeep', 'expected the GitHub icon link'
    assert_includes html, 'mailto:lobatifricha', 'expected the email icon link'
  end
end
