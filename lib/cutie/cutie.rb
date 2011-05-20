class Cutie
  DEBUG = $stdout
  attr_accessor :filehandle, :root

  def initialize(fh, debug=false)
    @debug      = debug
    @filehandle = fh
  end

  class << self
    def open(filepath, debug=false)
      new(File.open(filepath, 'rb'), debug).parse
    end
  end

  def debug?
    @debug
  end

  def debug(msg)
    DEBUG.puts msg if debug?
  end

  def parse
    @root = next_atom
    debug "loaded root atom: #{ @root }"

    @stack = [@root]
    while atom = next_atom
      debug "loaded child atom: #{ atom }"
      @stack.last.children << atom
      debug "stack now contains #{ @stack.length } atoms"

      if atom.container?
        debug "pushing container atom onto the stack"
        @stack << atom
      elsif filehandle.pos == @stack.last.next_position
        debug "popping last container from the stack"
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
