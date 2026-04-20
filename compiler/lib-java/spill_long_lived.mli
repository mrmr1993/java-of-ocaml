(** Pre-split pass that relieves simultaneous liveness in wide
    blocks. For each block big enough to force [Method_split] to
    carve it up, finds vars whose live range spans most of the body
    but that are used only once or twice, allocates a single "spill"
    [Block] carrier up front, and:

    - at each qualifying var's def site, writes the value into the
      spill slot with [Set_field];
    - at each of its use sites, reads a fresh local from
      [Field(spill, i)] and substitutes that local in the use.

    The original var stays bound at its def (held alive only long
    enough for the immediately-following [Set_field]); all downstream
    references go through short-lived freshes. [Method_split]'s
    intra-block chunker then sees a much smaller live-at-cut set,
    so the helpers it emits have narrower param lists.

    The spill carrier is one long-lived [Var] in place of the [N]
    long-lived qualifying vars it subsumes. *)

val f : Code.program -> Code.program
