require File.expand_path('../../lib/cutie', __FILE__)
require 'test/unit'


class TestCutie < Test::Unit::TestCase

  def test_empty_movie
    video = Cutie.open(File.expand_path('../empty.mov', __FILE__))
    atom  = video.root

    assert_equal "moov", atom.format
  end

end
