class Cutie
  attr_accessor :filehandle

  # quicktime files are composed of atoms, which are nested containers
  # for different data types
  class Atom
    CONTAINER_TYPES = %w(
      dinf  edts  imag  imap  mdia  mdra  minf  moov  
      rmra  stbl  trak  tref  udta  vnrp  
    )

    attr_accessor :size, :format, :position

    def initialize(position)
      @position = position
    end

    def container?
      CONTAINER_TYPES.include?(format)
    end

    def next_position
      position + size
    end

    def to_s
      "#{ format } atom #{ container? ? '(C) ' : '' }[#{ size } bytes]"
    end
  end



  def initialize(fh)
    self.filehandle = fh
  end

  class << self
    def open(filepath)
      new(File.open filepath, 'rb')
    end
  end

  def dump_atoms
    indent = 0
    filehandle.rewind

    while atom = next_atom
      print "  " * indent
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

      atom = Atom.new(filehandle.pos - 8)
      atom.size, atom.format = *bytes.unpack('NA4')

      # check for extended or invalid atom size
      if atom.size == 1
        atom.size = filehandle.read(8).unpack('Q') # TODO : force big-endian?
      end

      raise "invalid atom size #{ atom.size }" if atom.size < 0

      # if our atom type is a container, we're done -- filehandle
      # is in position to read the first child
      # otherwise, seek to the end of the data...
      filehandle.pos += atom.size unless atom.container?

      atom
    end
  end
end
