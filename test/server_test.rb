# End-to-end smoke test of the running server.
#
# Boots the real `middleman server` (verifying the serving gem stack -- puma,
# rack, celluloid, listen, livereload -- loads and runs), hits it over HTTP,
# then shuts it down.
#
#   bundle exec ruby test/server_test.rb
#
require 'minitest/autorun'
require 'net/http'

class ServerTest < Minitest::Test
  PORT = 4568
  LOG  = '/tmp/mm_test_server.log'

  def setup
    # Own process group so we can reliably kill puma and any children.
    @pid = Process.spawn(
      'bundle', 'exec', 'middleman', 'server', '-p', PORT.to_s,
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

  def test_serves_homepage
    res = get('/')
    assert_equal '200', res.code, "expected 200, got #{res.code}"
    assert_includes res.body, '<h1>Boon.gl</h1>'
    assert_includes res.body, 'Robert Fletcher'
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
    flunk "middleman server did not come up on port #{PORT}:\n#{log}"
  end
end
