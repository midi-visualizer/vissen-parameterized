# frozen_string_literal: true

module Vissen
  module Parameterized
    # The Value module implements the basic functionallity of a value type.
    # Class implementations are encouraged to override #write to provide type
    # checking or coercion.
    #
    # === Usage
    # The following example implements an integer type by calling #to_i on
    # objects before they are written.
    #
    #   class Int
    #     include Value
    #     DEFAULT = 0
    #
    #     def write(new_value)
    #       super new_value.to_i
    #     end
    #   end
    #
    module Value
      # @return [Object] the internal value object.
      attr_reader :value

      # @return [Object] the default value that will be used when `.new` is
      #   called without arguments, or with nil.
      DEFAULT = nil

      TRANSACTION_ID_MASK = 0x7FFF

      # @param  value [Object] the initial value to use. Ignored if nil.
      def initialize(value = nil)
        @value   = nil
        @tainted = -1

        write(value.nil? ? self.class::DEFAULT : value)
      end

      # Updates the internally stored value. The object will be marked as
      # tainted if the new value differs from the previous.
      #
      # @param  new_value [Object] the new value to write.
      # @return [nil]
      def write(new_value)
        return false if new_value == @value
        @value = new_value
        taint!
        true
      end

      # @return [true] if the value has been written to since the last call to
      #   `#untaint!`.
      # @return [false] otherwise.
      def tainted?(transaction_id)
        return true if @tainted.negative? && -@tainted == transaction_id

        @tainted = transaction_id
        false
      end

      def tested?(transaction_id)
        @tainted == transaction_id || @tainted == -transaction_id
      end

      def next_transaction_id(current_id = 0)
        ((current_id + 1) & TRANSACTION_ID_MASK).tap do |v|
          break v + 1 if v.zero?
        end
      end

      module_function :next_transaction_id

      protected

      def taint!
        @tainted = -@tainted unless @tainted.negative?
      end
    end
  end
end
