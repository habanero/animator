

module ExceptionIfRunning
  class IllegalStateException < StandardError; end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def exception_if_running(*method_names)
      method_names.each do |method_name|
        escaped_equal = method_name.to_s.gsub(/=/, "_equal_") # メソッド名に=があると、module_evalが失敗する
        alias_method_name = "#{escaped_equal}_not_raise_runnig_exception".to_sym
        alias_method alias_method_name, method_name
        module_eval <<-END
          def #{method_name}(*args, &block)
            raise IllegalStateException.new(self.to_s + "is running. but <" + (__method__.to_s) + "> was called") if running?
            #{alias_method_name}(*args, &block)
          end
        END
      end
    end
  end

  def running?
    @running
  end
end

