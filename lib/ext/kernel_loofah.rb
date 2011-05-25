# Add Loofah helpers everywhere.
module Kernel
  def strip_tags(markup)
    return Loofah::Helpers.strip_tags(markup)
  end

  def sanitize(markup)
    return Loofah::Helpers.sanitize(markup)
  end
end
