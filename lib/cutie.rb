class Cutie
  attr_accessor :filehandle, :root

  # quicktime files are composed of atoms, which are nested containers
  # for different data types
  class Atom
    CONTAINER_TYPES = %w(
      dinf  edts  imag  imap  mdia  mdra  minf  moov
      rmra  stbl  trak  tref  udta  vnrp
    )

    attr_accessor :size, :format, :position, :children

    def self.init(fh, position, size, format)
      klass = format == "mdhd" ? MediaHeader : Atom
      atom = klass.new(position, size, format)
      atom.read(fh) if atom.respond_to?(:read)
      atom
    end

    def initialize(position, size, format)
      @position = position
      @size     = size
      @format   = format
      @children = []
    end

    def read(fh)
      # if our atom type is a container, we're done -- filehandle
      # is in position to read the first child
      # otherwise, seek to the end of the data...
      return if container?
      fh.pos += size
    end

    def container?
      CONTAINER_TYPES.include?(format)
    end

    def next_position
      position + size
    end

    def to_s
      "#{ format } atom #{ container? ? '(C) ' : '' }[#{ position }, #{ size } bytes]"
    end
  end

  # a MediaHeader (mdhd) is a specific type of atom that has metadata
  # about a media atom
  class MediaHeader < Atom
    attr_accessor :version, :flags, :ctime, :mtime, :tscale, :duration, :language, :quality

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
        @duration = read_uint16(fh)
      else
        @duration = fh.read(8).unpack('N')
      end

      @language = read_uint8(fh)
      @quality  = read_uint8(fh)
    end

    def to_s
      "MediaHeader v#{ version } [#{ position }, #{ size } bytes] [#{ tscale } @ #{ duration } sec]"
    end

    private

    def read_uint16(s)
      s.read(4).unpack('N').first
    end

    def read_uint8(s)
      s.read(2).unpack('n').first
    end

  end



  def initialize(fh)
    self.filehandle = fh
  end

  class << self
    def open(filepath)
      new(File.open filepath, 'rb').parse
    end
  end

  def parse
    @root = next_atom

    @stack = [@root]
    while atom = next_atom
      @stack.last.children << atom

      if atom.container?
        @stack << atom
      elsif filehandle.pos == @stack.last.next_position
        @stack.pop
      end
    end

    self
  end

  def dump_atoms
    indent = 0
    filehandle.rewind

    while atom = next_atom
      print "  " * indent rescue nil
      puts atom.to_s

      if atom.container?
        indent += 1
      elsif filehandle.pos == atom.next_position
        indent -= 1
      end
    end
  end


  def next_atom
    start_position = filehandle.pos

    if bytes = filehandle.read(8)
      raise "Expected 8 bytes, got #{ bytes.length }" unless bytes.length == 8

      size, format = *bytes.unpack('NA4')
      atom = Atom.init(filehandle, start_position, size, format)

      # check for extended or invalid atom size
      if atom.size == 1
        atom.size = filehandle.read(8).unpack('Q') # TODO : force big-endian?
      end

      raise "invalid atom size #{ atom.size }" if atom.size < 0

      atom
    end
  end
end
