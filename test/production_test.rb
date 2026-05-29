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

# Build the static site once so puma/config.ru has something to serve.
BUILD_OK = system('bundle exec middleman build', out: File::NULL, err: File::NULL)

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
    res = get('/stylesheets/all.css')
    assert_equal '200', res.code, "expected the built all.css to be served, got #{res.code}"
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
