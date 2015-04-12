# Multicellular clocks

- what environmental inputs are required to evolve coupled interactions, rather than a colony of autonomous oscillators?
  - evolve under normal light/dark, then with different noise for each cell, with cost function requiring that the cells are on according to the mean dawn/dusk
  - grid of cells with identical networks
  - to start with, for a specific interaction (say A -> B), then for each interaction (A -> B):
    - add an additional parameter that determines whether its origin node (A) effects the 'B' genes in neighbouring networks
  - to start with, use majority rule as is coded currently (i.e. more activation than repression => activation and vice versa), then if too simple, can set threshold for how much external/internal A is necessary for switching B on/off,
  - then boolean decision for B according to inputs


- can we evolve quorum sensing - evolving the ability to sense when you have many neighbours
  - if there are only a few then gene A stays off
  - if there are many then gene A turns on
