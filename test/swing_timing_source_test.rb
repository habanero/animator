# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'swing_timing_source'

class SwingTimingSourceTest < Test::Unit::TestCase

  def setup
    @timer = SwingTimingSource.new(10){ sleep 0.1}
    @timer.start
  end

  def test_interface
    [:start, :stop, :resolution=,:start_delay=].each do |m|
      assert_respond_to(@timer, m)
    end
  end

  def teardown
    @timer.stop
  end
end
