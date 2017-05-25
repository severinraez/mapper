require_relative '../../../test_helper.rb'

require_relative '../fdsl.rb'

describe FDSL do
  describe 'simple defined functions' do
    Simple = FDSL.create do |f|
      f.identity { |p| p }
      f.default_1 { |p=1| p }
      f.double_identity { |p| identity(p) * 2 }
    end

    it 'have params' do
      assert_equal Simple.identity(1), 1
    end

    it 'have params with defaults' do
      assert_equal Simple.default_1, 1
      assert_equal Simple.default_1(2), 2
    end

    it 'can call its own functions' do
      assert_equal Simple.double_identity(1), 2
    end
  end

  describe 'higher order functions and naming' do
    HigherOrder = FDSL.create do |f|
      f.identity { |p| p }
      f.doubler { |func| proc { |p| func.call(p) * 2 } }
      f.double_identity = doubler(identity_)
    end

    it 'assigns returned functions their name' do
      assert_equal HigherOrder.double_identity(1), 2
    end
  end

  describe 'with_libs' do
    A = FDSL.create do |f|
      f.a_func { 'a' }
      f.overridden_func { 'base' }
    end

    B = FDSL.create do |f|
      f.b_func { 'b' }
      f.overridden_func { 'overridden' }
    end

    it 'includes a lib' do
      FDSL.with_libs A do
        assert_equal a_func, 'a'
        assert_equal overridden_func, 'base'
      end
    end

    it 'correctly overrides' do
      FDSL.with_libs B, A do
        assert_equal a_func, 'a'
        assert_equal b_func, 'b'
        assert_equal overridden_func, 'overridden'
      end
    end

    it 'includes the stdlib' do
      FDSL.with_libs A do
        assert_equal map(proc { |p| p*2 }, [1,2]), [2,4]
      end
    end
  end
end
