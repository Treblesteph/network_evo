# Code optimisation strategy

## Running simulations fewer times unnecessarily

- [ ] mutated field in Network
  - [ ] path effect
    - [ ] do the two genes interact with genes 1 & 2 (directly/indirectly)?
  - [ ] envpath effect
    - [ ] does the gene interact with genes 1 & 2 (directly/indirectly)?
  - [ ] lag effect
    - [x] is the path active?
      - **before** ~1800 seconds for 1pp no noise
      - **after** ~540 seconds for 1pp no noise
  - [ ] envlag effect
    - [x] is the envpath active?
      - **before** envlag mutations are not currently switched on
      - **after** envlag mutations are not currently switched on
  - [ ] gate effect
    - [ ] is there more than one incoming path?
    - [ ] does the gene interact with genes 1 & 2 (directly/indirectly)?

## Speeding up current simulation

- [ ] updating concs only after the next lag happens (1 or 2 OM faster?)
- [ ] making path status boolean and encoding dechash as int in binary representation

## Reduce RAM

- [ ] store path entries as Int8 rather than Int64
