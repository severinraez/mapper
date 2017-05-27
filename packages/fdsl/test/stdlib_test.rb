require_relative '../../../test_helper.rb'

require_relative '../fdsl.rb'

describe FDSL::Stdlib do
  let(:lib) { FDSL::Stdlib }

  it '.map' do
    triple = proc { |p| p * 3 }

    assert_equal lib.map(triple, [1, 3]), [3, 9]
  end

  describe 'function composition' do
    let(:triple) { proc { |p| p * 3 } }
    let(:add_1) { proc { |p| p + 1 } }

    it '.compose' do
      triple_and_add_1 = lib.compose(add_1, triple)
      triple_and_add_2 = lib.compose(add_1, add_1, triple)
      assert_equal triple_and_add_1.call(3), 10
      assert_equal triple_and_add_2.call(3), 11
    end

    it '.arrow' do
      triple_and_add_1 = lib.arrow(triple, add_1)
      triple_and_add_2 = lib.arrow(triple, add_1, add_1)
      assert_equal triple_and_add_1.call(3), 10
      assert_equal triple_and_add_2.call(3), 11
    end
  end

  it '.curry' do
    add = proc { |a, b| a + b }

    one_adder = lib.curry(add, 1)

    assert_equal one_adder.call(2), 3
  end

  describe '.typed' do
    it 'single type' do
      strings_are_cool = lib.typed(
        String => proc { |p| "#{p} is cool" },
        :else => proc { |p| "Not cool" }
      )

      assert_equal "Foo is cool", strings_are_cool.call("Foo")
      assert_equal "Not cool", strings_are_cool.call(1)
    end

    it 'inherited types' do
      class Dummy
      end

      class InheritedDummy < Dummy
      end

      find_dummies = lib.typed(
        Dummy => proc { |p| "Found a dummy" },
        :else => proc { |p| "No dummy" }
      )

      assert_equal "Found a dummy", find_dummies.call(Dummy.new)
      assert_equal "Found a dummy", find_dummies.call(InheritedDummy.new)
      assert_equal "No dummy", find_dummies.call(1)
    end

    it 'multiple types' do
      decider = lib.typed(
        :else => proc { |p, q| "No string" },
        [String] => proc { |p, q| "One string" },
        [String, String] => proc { |p, q| "Two strings" })

      assert_equal "No string", decider.call(1,1)
      assert_equal "No string", decider.call(1,"This one does not start with a string")
      assert_equal "One string", decider.call("Hi", 1)
      assert_equal "Two strings", decider.call("Hi", "there")
    end
  end

  it '.reduce' do
    adder = proc { |a,b| a+b }

    assert_equal lib.reduce(adder, 1, [2, 3]), 6
  end
end
