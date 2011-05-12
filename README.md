# CUTIE

Cutie is a MOV parsing library for Ruby

## EXAMPLE

The following example demonstrates parsing a .mov file:

    >> video = Cutie.open("some.mov")
    => #<Cutie:0x100338960>
    >> video.duration
    => 85.5

