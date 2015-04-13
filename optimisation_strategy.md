# Code optimisation strategy

## Running simulations fewer times unnecessarily

- [x] crossover between identical networks
  - **before** ~1260 seconds for 1pp no noise (mean of three runs)
  - **after** ~721 seconds for 1pp no noise (mean of three runs)
- [ ] mutated field in Network
  - [ ] path effect
    - [ ] do the two genes interact with genes 1 & 2 (directly/indirectly)?
  - [ ] envpath effect
    - [ ] does the gene interact with genes 1 & 2 (directly/indirectly)?
  - [ ] lag effect
    - [x] is the path active?
      - **before** ~1901 seconds for 1pp no noise (mean of three runs)
      - **after** ~578 seconds for 1pp no noise (mean of three runs)
  - [ ] envlag effect
    - [x] is the envpath active?
      - **before** envlag mutations are not currently switched on
      - **after** envlag mutations are not currently switched on
  - [ ] gate effect
    - [x] is there more than one incoming path?
    - [x] does the gene interact with genes 1 & 2 (directly/indirectly)?
    - **before** ~721 seconds for 1pp no noise (mean of three runs)
    - **after** ~641 seconds for 1pp no noise (mean of three runs)

## Speeding up current simulation

- [ ] updating concs only after the next lag happens (1 or 2 OM faster?)
- [ ] making path status boolean and encoding dechash as int in binary representation

## Reduce RAM

- [x] store path entries as Int8 rather than Int64
- [ ] delete concentration time series when they are no longer needed
