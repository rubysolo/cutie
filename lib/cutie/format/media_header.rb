# a MediaHeader (mdhd) is a specific type of atom that has metadata
# about a media atom
class MediaHeader < Atom
  attr_accessor :version, :flags, :ctime, :mtime, :tscale, :ticks, :language, :quality

  def read(fh)
    @version = "\x00#{ fh.read(1) }".unpack('n').first

    @flags    = fh.read(3).unpack('C3')

    if @version == 0
      @ctime  = read_uint16(fh)
      @mtime  = read_uint16(fh)
    else
      @ctime  = fh.read(8).unpack('N')
      @mtime  = fh.read(8).unpack('N')
    end

    @tscale   = read_uint16(fh)

    if @version == 0
      @ticks  = read_uint16(fh)
    else
      @ticks  = fh.read(8).unpack('N')
    end

    @language = read_uint8(fh)
    @quality  = read_uint8(fh)
  end

  def to_s
    "MediaHeader v#{ version } [#{ position }, #{ size } bytes] [#{ duration } sec]"
  end

  def duration
    ticks.to_f / tscale.to_f
  end

  private

  def read_uint16(s)
    s.read(4).unpack('N').first
  end

  def read_uint8(s)
    s.read(2).unpack('n').first
  end

end
