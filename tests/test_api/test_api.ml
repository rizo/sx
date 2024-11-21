open Sx

module X (Sx : Sx__Types.S) = struct
  let s1 = Sx.[ mt 4; py 8 ]
  let s2 = Sx.[ mt 1; hover [ mt 2 ] ]
  let s3 = Sx.[ bt.m; bt.xl ]
end
