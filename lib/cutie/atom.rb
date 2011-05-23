module Cutie
  # quicktime files are composed of atoms, which are nested containers
  # for different data types
  class Atom
    CONTAINER_TYPES = %w(
      dinf  edts  imag  imap  mdia  mdra  minf  moov
      rmra  stbl  trak  tref  udta  vnrp
    )

    attr_accessor :level, :size
    attr_reader :children, :format, :position

    def self.init(fh, position, size, format)
      klass = format == "mdhd" ? MediaHeader : Atom
      atom = klass.new(fh, position, size, format)
      atom.read
      atom
    end

    def initialize(fh, position, size, format)
      @fh       = fh
      @position = position
      @size     = size
      @format   = format
      @children = []
      @level    = 0
    end

    def read
      # if our atom type is a container, we're done -- filehandle
      # is in position to read the first child
      # otherwise, seek to the end of the data...
      return if container?
      @fh.pos += @size
    end

    def close
      @fh.pos += 4 if @format == "udta"
    end

    def container?
      CONTAINER_TYPES.include?(@format)
    end

    def <<(atom)
      atom.level = level + 1
      children << atom
    end

    def next_position
      @position + @size
    end

    def to_s
      "#{ @format } atom #{ container_label }#{ size_label }"
    end

    def size_label
      "[#{ @position }, #{ @size } bytes]"
    end

    def container_label
      container? ? '(C)' : ''
    end
  end
end
