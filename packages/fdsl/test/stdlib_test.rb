require_relative '../../../test_helper.rb'

require_relative '../fdsl.rb'

describe FDSL::Stdlib do
  let(:lib) { FDSL::Stdlib }

  it '.curry' do
    add = proc { |a, b| a + b }

    one_adder = lib.curry(add, 1)

    assert_equal one_adder.call(2), 3
  end

  it '.typed' do
    strings_are_cool = lib.typed(
      String => proc { |p| "#{p} is cool" },
      :default => proc { |p| "Not cool" }
    )

    assert_equal "Foo is cool", strings_are_cool.call("Foo")
    assert_equal "Not cool", strings_are_cool.call(1)
  end

  it '.reduce' do
    adder = proc { |a,b| a+b }

    assert_equal lib.reduce(adder, 1, [2, 3]), 6
  end
end
