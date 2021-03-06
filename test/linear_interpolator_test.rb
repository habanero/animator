# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'linear_interpolator'

class LinearInterpolatorTest < Test::Unit::TestCase

  def test_interpolate
    l = LinearInterpolator
    assert_equal(l.interpolate(0.0), 0.0)
    assert_equal(l.interpolate(0.5), 0.5)
    assert_equal(l.interpolate(1.0), 1.0)
  end
end
