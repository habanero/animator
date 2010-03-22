# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'animator'

class AnimatorTest < Test::Unit::TestCase

  def setup
    @target_adapter = Object.new
    @target_adapter.extend TimingTargetAdapter
  end

  def test_running
    a = Animator.new(2000)
    assert(!a.running?)

    a.start()
    assert(a.running?)

    a.stop()
    sleep(0.3)
    assert(!a.running?)
  end

  def test_resolution
    a = Animator.new(2000)
    assert_equal(20, a.resolution)

    a.resolution = 200
    assert_equal(200, a.resolution)

    assert_raise(ExceptionIfRunning::IllegalStateException ){ a.resolution = -20 }

    a.start
    assert_raise(Animator::IllegalStateException ){ a.resolution = 20 }
    a.end
  end

  def test_start_delay
    a = Animator.new(2000)
    a.add_target{ 1 + 1 }

    assert_equal(0.0, a.start_delay)

    a.start_delay = 200
    assert_equal(200, a.start_delay)

    assert_raise(Animator::IllegalStateException){ a.start_delay = -1.0}

    a.start
    assert_raise(Animator::IllegalStateException){ a.start_delay = 0.5 }
    a.end
  end

  def test_interpolator
    a = Animator.new(2000)
    a.add_target{ 1 + 1}

    assert_equal(LinearInterpolator, a.interpolator)

    a.interpolator = LinearInterpolator
    assert_equal(LinearInterpolator, a.interpolator)

    a.start
    assert_raise(Animator::IllegalStateException){ a.interpolator = LinearInterpolator}
    a.end
  end

  def test_duration
    a = Animator.new(2000)
    a.add_target{ 1 + 1}

    assert_equal(2000, a.duration)

    a.duration = 3000
    assert_equal(3000, a.duration)

    a.start
    assert_raise(Animator::IllegalStateException){ a.duration = 2000}
    a.end
  end

  def test_repeat_count
    a = Animator.new(2000)
    a.add_target{ 1 + 1}

    assert_equal(1.0, a.repeat_count)

    a.repeat_count = 2.0
    assert_equal(2.0, a.repeat_count)

    a.start
    assert_raise(Animator::IllegalStateException){ a.repeat_count = 1.0}
    a.end
  end

  def test_start_fraction
    a = Animator.new(2000)
    a.add_target{ 1 + 1}

    assert_equal(0.0, a.start_fraction)

    a.start_fraction = 0.5
    assert_equal(0.5, a.start_fraction)

    assert_raise(Animator::IllegalStateException){ a.start_fraction = 2.0}
    assert_raise(Animator::IllegalStateException){ a.start_fraction = -1.0}

    a.start
    assert_raise(Animator::IllegalStateException){ a.start_fraction = 0.3}
    a.end
  end

  def test_begin
    v = 0
    target = @target_adapter.clone
    target.instance_variable_set(:@b, binding)
    def target.begin
      eval("v=1", @b)
    end

    a = Animator.new(2000, target)
    a.start
    sleep 0.3
    assert_equal(1, v)
  end
end
