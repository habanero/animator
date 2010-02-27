include Java

class SwingTimingSource
  def initialize(resolution, target=nil, &block)
    target = block unless target
    @timer = javax.swing.Timer.new(resolution, target)
    @timer.setInitialDelay(0)
  end

  def start
    @timer.start
  end

  def stop
    @timer.stop
  end

  def resolution=(delay)
    @timer.setDelay(delay)
  end

  def start_delay=(delay)
    @timer.setInitialDelay(delay)
  end
end
