module Twterm
  module Tab
    module Dumpable
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      def dump
        [self.class, title, dump_data]
      end

      def dump_data
        fail NotImplementedError 'dump_data method must be implemented'
      end

      module ClassMethods
        def recover(title, arg)
          new(arg).tap { |t| t.title = title }
        end
      end
    end
  end
end
