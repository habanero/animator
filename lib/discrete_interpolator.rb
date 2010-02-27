

module DiscreteInterpolator
  def interpolate(fraction)
    return 0.0 if fraction < 1.0
    1.0
  end
  module_function :interpolate
end
