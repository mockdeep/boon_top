# Smoke test of the PRODUCTION serving stack: puma booting config.ru, which
# serves the built static site (tmp/) via Rack::TryStatic. This is the exact
# path Heroku uses (Procfile: `puma -p $PORT -e $RACK_ENV`) -- distinct from
# server_test.rb, which tests the Middleman dev preview server.
#
# It exercises puma + rack + rack-contrib's Rack::TryStatic together, so it
# catches gem-compatibility breakage in the deploy path that the dev server
# never touches.
#
#   bundle exec ruby test/production_test.rb
#
require 'minitest/autorun'
require 'net/http'

# Build via the SAME command Heroku runs at deploy (rake assets:precompile),
# not `middleman build` directly -- so this test covers the real deploy build
# path (e.g. it fails if rake isn't bundled, which silently breaks the deploy).
BUILD_OK = system('bundle exec rake assets:precompile', out: File::NULL, err: File::NULL)

class ProductionTest < Minitest::Test
  PORT = 4569
  LOG  = '/tmp/mm_test_puma.log'

  def setup
    assert BUILD_OK, 'middleman build failed; cannot test the serving stack'

    # Boot puma exactly as the Procfile does (puma auto-loads ./config.ru).
    @pid = Process.spawn(
      'bundle', 'exec', 'puma', '-p', PORT.to_s,
      out: LOG, err: LOG, pgroup: true
    )
    wait_for_server
  end

  def teardown
    return unless @pid
    Process.kill('TERM', -@pid) # negative pid => whole process group
    Process.wait(@pid)
  rescue Errno::ESRCH, Errno::ECHILD
    # already gone
  end

  def test_serves_built_homepage
    res = get('/')
    assert_equal '200', res.code, "expected 200 from puma/config.ru, got #{res.code}"
    assert_includes res.body, '<h1>Boon.gl</h1>'
  end

  def test_serves_compiled_asset
    # asset_hash fingerprints the filename, so discover the real URL from the
    # page rather than assuming /stylesheets/all.css.
    css_path = get('/').body[%r{href="(/stylesheets/all-[^"]+\.css)"}, 1]
    refute_nil css_path, 'could not find the fingerprinted all.css link in the page'
    res = get(css_path)
    assert_equal '200', res.code, "expected the built CSS served at #{css_path}, got #{res.code}"
  end

  private

  def get(path)
    Net::HTTP.get_response(URI("http://localhost:#{PORT}#{path}"))
  end

  def wait_for_server
    30.times do
      begin
        return get('/')
      rescue Errno::ECONNREFUSED, EOFError
        sleep 1
      end
    end
    log = File.exist?(LOG) ? File.read(LOG) : '(no log)'
    flunk "puma did not come up on port #{PORT}:\n#{log}"
  end
end
