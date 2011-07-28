require "minitest/autorun"
require "set"

FIXTURE_DIR = File.expand_path(
                File.dirname(__FILE__)+"/fixtures/")

# adopted from: https://gist.github.com/839034
def context(*args, &block)
  return super unless (name = args.first) && block

  context_class = Class.new(MiniTest::Unit::TestCase) do
    class << self
      def test(name, &block)
        test_method_name = "test_#{name.gsub(/\W/,'_')}".to_sym
        block ||= lambda { skip(name) }
        if instance_methods.include?(test_method_name)
          raise ArgumentError, "A test '#{name}' already exists"
        end
        define_method(test_method_name, &block)
      end

      def setup(&block)
        define_method(:setup, &block)
      end

      def teardown(&block)
        define_method(:teardown, &block)
      end
    end
    
    def assert_set_equal(setlike_a, setlike_b)
      assert setlike_a.to_set == setlike_b.to_set,
        "#{setlike_a.inspect} is not set equal to #{setlike_b.inspect}"
    end

    def read_fixture(name)
      File.read("#{FIXTURE_DIR}/#{name}")
    end
  end

  context_class.singleton_class.instance_eval do
    define_method(:name) { name.gsub(/\W/,'_') }
  end

  context_class.class_eval(&block)
end

