# Can alter these:
const ALLDAYS = 4
const POPSIZE = 100
const DAWNWINDOW = 3
const DUSKWINDOW = 3
DAWNROWS = []; DAWNS = zeros(ALLDAYS, DAWNWINDOW * 60)
DUSKROWS = []; DUSKS = zeros(ALLDAYS, DUSKWINDOW * 60)
for t = 1:ALLDAYS
  DAWNS[t, :] = (1+60*24*(t-1)):(60*(DAWNWINDOW+24*(t-1)))
  DUSKS[t, :] = (1+60*(12+24*(t-1))):(60*(12+DUSKWINDOW+24*(t-1)))
  DAWNROWS = [DAWNROWS, transpose(DAWNS[t, :])]
  DUSKROWS = [DUSKROWS, transpose(DUSKS[t, :])]
end
const MUTATEPATH = 0.05  # Percent of time path sign switched.
const MUTATETMAT = 0.1   # Percent of time transition matrix mutates.
const MUTATELAG = 0.1    # Percent of time lag duration mutates.
const MUTATEGATE = 0.09  # Percent of time gate type switches.
const TMAT_STD = 0.1     # Standard deviation of truc norm rng.
const LAG_STD = 8        # Standard deviation of truc norm rng.

# Don't change these unless altering framework.
const NNODES = 4
const MAXLAG = 60*24
const ALLHOURS = ALLDAYS * 24
const ALLMINS = ALLHOURS * 60
