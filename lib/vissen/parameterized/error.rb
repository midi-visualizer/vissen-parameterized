# frozen_string_literal: true

module Vissen
  module Parameterized
    # This is the top level output error class and should be subclassed by all
    # other custom error classes used in this library.
    class Error < StandardError
    end
  end
end
