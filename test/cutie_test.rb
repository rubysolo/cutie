require File.expand_path('../../lib/cutie', __FILE__)
require 'test/unit'
require 'stringio'

# stub out the debug logging
Cutie::DEBUG = StringIO.new

class TestCutie < Test::Unit::TestCase

  def test_empty_movie
    video = Cutie.open(fixture_movie('empty.mov'))
    atom  = video.root

    assert_equal "moov", atom.format
    assert_equal 2, atom.children.length

    assert_equal "mvhd", atom.children[0].format
    assert_equal "WLOC", atom.children[1].format
  end

  def test_debug_flag
    video = Cutie.open(fixture_movie('empty.mov'), true)
    assert video.debug?
  end

  private

  def fixture_movie(filename)
    File.expand_path("../fixtures/#{ filename }", __FILE__)
  end

end
