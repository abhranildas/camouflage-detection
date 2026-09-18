% +tests  (package namespace: tests.*)
% Ad-hoc, un-asserted check scripts — no test runner and no pass/fail
% assertions; each just plots or prints something for the author to
% inspect by eye. The repo's real, assertion-based smoke test is not here
% but with the rest of the cleanup tooling: run it as
% >> addpath('tools'); smoke_test
% (S3.5 in docs/repo-cleanup.md).
%
% Call functions/scripts as tests.<name>. Requires the repo root on the
% MATLAB path (see setup.m).
%
%   tests.block_jumping   - script; checks whether recomputed edge
%     energies still respect the original per-block level ordering (BUG:
%     the recompute call passes lib.stimulus positional arguments against
%     a name-value-only signature, errors if run, new/B2)
%   tests.gabor_similarity   - plots gabor-pair similarity vs. a swept
%     property (phase, orientation, frequency, amplitude) (BUG: calls
%     stats.computeSceneSimilarityAmplitude, which does not exist under
%     that name — the backing file is `_`-prefixed — errors if run,
%     new/B2)
