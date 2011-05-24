module Cutie
  class Movie
    attr_reader :root, :atoms

    def initialize(fh)
      @filehandle = fh
      @atoms      = []
    end

    class << self
      def open(filepath)
        new(File.open(filepath, 'rb')).parse
      end
    end

    def parse
      @root = next_atom
      @atoms << @root

      @stack = [@root]
      while atom = next_atom
        @atoms << atom

        @stack.last << atom

        if atom.container?
          @stack << atom
        elsif @filehandle.pos == @stack.last.next_position
          @stack.pop.close
        end
      end

      self
    end

    def dump_atoms
      @atoms.each do |atom|
        print "  " * atom.level
        puts atom.to_s
      end
    end

    private

    def next_atom
      if bytes = @filehandle.read(8)
        raise "Expected 8 bytes, got #{ bytes.length }" unless bytes.length == 8

        size, format = *bytes.unpack('NA4')
        atom = Atom.build(
          :filehandle => @filehandle,
          :size       => size,
          :format     => format
        )

        # check for extended or invalid atom size
        if atom.size == 1
          atom.size = @filehandle.read(8).unpack('Q').first # TODO : force big-endian?
        end

        raise "invalid atom size #{ atom.size }" if atom.size < 0

        atom
      end
    end
  end
end
