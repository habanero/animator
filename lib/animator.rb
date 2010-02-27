
include Java

require 'thread'
require 'swing_timing_source'
require 'linear_interpolator'
require 'timing_target_adapter'

class Animator

  def initialize(duration, target=nil)
    @duration = duration.to_f
    @resolution = 20

    @targets = []
    @targets << target if target
    @targets_mutex = Mutex.new

    @timer = SwingTimingSource.new(@resolution) do
      timing_event(timing_fraction())
    end

    @start_time = 0.0
    @current_start_time = 0.0

    @current_cycle = 0.0
    @repeat_count = 1.0

    @begun = false
    @pause_begin_time = 0.0
    @running = false

    @time_to_stop = false

    @start_delay = 0.0
    @start_fraction = 0.0

    @interpolator = LinearInterpolator
  end

  def running?
    @running
  end

  class IllegalStateException < StandardError; end
  def exception_if_running
    raise IllegalStateException if running?
  end

  def interpolator=(i)
    exception_if_running
    @interpolator = i
  end
  attr_reader :interpolator

  def duration=(n)
    exception_if_running
    @duration = n.to_f
  end
  attr_reader :duration

  def repeat_count=(n)
    exception_if_running
    @repeat_count = n.to_f
  end
  attr_reader :repeat_count

  def resolution=(n)
    raise IllegalStateException if n < 0
    exception_if_running
    @resolution = n
    @timer.resolution=(n)
  end
  attr_reader :resolution

  def start_delay=(n)
    raise IllegalStateException if n < 0
    exception_if_running
    @start_delay = n
    @timer.start_delay = n
  end
  attr_reader :start_delay

  def start_fraction=(n)
    raise IllegalStateException if n < 0.0 || n > 1.0
    exception_if_running
    @start_fraction = n
  end
  attr_reader :start_fraction

  def add_target(target=nil, &block)
    target = ProcTargetAdapter.new(block) unless target
    @targets_mutex.synchronize{
      @targets << target
    }
  end

  def remove_target(target)
    @targets_mutex.synchronize{
      @targets.delete(target)
    }
  end

  def start
    exception_if_running
    @begun = false
    @running = true

    @start_time = (current_time() / 1000000) + @start_delay
    @current_start_time = @start_time
    @timer.start
  end

  def stop
    @timer.stop
    self.end()
    @time_to_stop = false
    @running = false
    @pause_begin_time = 0
  end

  def cancel
    @timer.stop
    @time_to_stop = false
    @pause_begin_time = 0
  end

  def pause
    if running?
      @pause_begin_time = current_time()
      @running = false
      @timer.stop
    end
  end

  def resume
    if @pause_begin_time > 0
      delta = (current_time() - @pause_begin_time) / 1000000
      @start_time += delta
      @current_start_time += delta
      @timer.start
      @pause_begin_time = 0
      @running = true
    end
  end

  def begin
    @targets_mutex.synchronize {
      @targets.each{|t| t.begin }
    }
  end

  def end
    @targets_mutex.synchronize {
      @targets.each{|t| t.end }
    }
  end

  def repeat
    @targets_mutex.synchronize {
      @targets.each{|t| t.repeat }
    }
  end

  def timing_event(fraction)
    @targets_mutex.synchronize {
      @targets.each{|t| t.timing_event(fraction) }
    }
    stop() if @time_to_stop
  end

  def timing_fraction()
    time = current_time() / 1000000
    unless @begun
      self.begin
      @begun = true
    end

    if current_cycle(time) > @repeat_count
      fraction = [1.0 , cycle_elapsed_time(time) / @duration].min
      @time_to_stop = true
    elsif cycle_elapsed_time(time) > @duration
      actual_cycle_time = cycle_elapsed_time(time) % @duration
      fraction = actual_cycle_time / @duration
      @current_start_time = time - actual_cycle_time
      repeat()
    else
      fraction = cycle_elapsed_time(time) / @duration
      fraction = [fraction, 1.0].min
      fraction = [fraction, 0.0].max
    end
    timing_event_preprocessor(fraction)
  end

  def timing_event_preprocessor(fraction)
    @interpolator.interpolate(fraction)
  end

  def current_time
    java.lang.System.nanoTime()
  end

  def total_elapsed_time(time)
    time - @start_time
  end

  def cycle_elapsed_time(time)
    time - @current_start_time
  end

  # 既にアニメーションを繰り返した回数(小数点つき)
  def current_cycle(time)
    total_elapsed_time(time) / @duration
  end

  class ProcTargetAdapter
    include TimingTargetAdapter

    def initialize(proc)
      @proc = proc
    end

    def timing_event(fraction)
      @proc.call(fraction)
    end
  end
end
