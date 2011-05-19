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
