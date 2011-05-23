require File.expand_path('../../lib/cutie', __FILE__)
require 'test/unit'
require 'stringio'

class TestAtom < Test::Unit::TestCase

  def setup
    @stub_fh = StringIO.new
  end

  def test_nesting_level_tracking
    root = Cutie::Atom.new(@stub_fh, 0, 0, "root")
    assert_equal 0, root.level
    assert_equal 0, root.children.count

    child_one = Cutie::Atom.new(@stub_fh, 0, 0, "chld")
    assert_equal 0, child_one.level
    assert_equal 0, child_one.children.count

    root.add_child(child_one)
    assert_equal 1, child_one.level
    assert_equal 1, root.children.count
  end

end
