class Xurrency

  def initialize(key)
    @key = key
  end

  def rate(base, target)
    exchange(base, target)
  end

  def exchange(base, target, value=1.0)
    # make_call
    # Return "result"
  end

 private

  def make_call(base, target, value)
    # Build URL
    # Do GET
    # Return value
  end

end
