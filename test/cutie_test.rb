require File.expand_path('../../lib/cutie', __FILE__)
require 'test/unit'
require 'stringio'

# stub out the debug logging
Cutie::DEBUG = StringIO.new

class TestCutie < Test::Unit::TestCase

  def test_empty_movie
    video = Cutie.open(File.expand_path('../empty.mov', __FILE__))
    atom  = video.root

    assert_equal "moov", atom.format
    assert_equal 2, atom.children.length

    assert_equal "mvhd", atom.children[0].format
    assert_equal "WLOC", atom.children[1].format
  end

  def test_debug_flag
    video = Cutie.open(File.expand_path('../empty.mov', __FILE__), true)
    assert video.debug?
  end

end
