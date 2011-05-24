module Cutie
  # a MediaHeader (mdhd) is a specific type of atom that has metadata
  # about a media atom
  class MediaHeader < Atom
    attr_reader :version, :flags, :ctime, :mtime, :tscale, :ticks,
                :language, :quality

    def read(fh)
      @version = "\x00#{ fh.read(1) }".unpack('n').first

      @flags    = fh.read(3).unpack('C3')

      if @version == 0
        @ctime  = read_uint16(fh)
        @mtime  = read_uint16(fh)
      else
        @ctime  = read_uint32(fh)
        @mtime  = read_uint32(fh)
      end

      @tscale   = read_uint16(fh)

      if @version == 0
        @ticks  = read_uint16(fh)
      else
        @ticks  = read_uint32(fh)
      end

      @language = read_uint8(fh)
      @quality  = read_uint8(fh)
    end

    def to_s
      "MediaHeader v#{ version } #{ size_label } #{ duration_label }"
    end

    def duration_label
      "[#{ duration } sec]"
    end

    def duration
      @ticks.to_f / @tscale.to_f
    end

    private

    def read_uint32(s)
			# TODO : this has potential endian-ness issues
      s.read(8).unpack('Q').first
    end

    def read_uint16(s)
      s.read(4).unpack('N').first
    end

    def read_uint8(s)
      s.read(2).unpack('n').first
    end

  end
end
