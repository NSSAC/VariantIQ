# VariantIQ Repository Summary

VariantIQ is a bioinformatics toolkit repository focused on evaluating variant-caller performance. It is organized around containerized workflows for Minos, Varifier, and Simutator, plus pipeline orchestration and benchmarking/reporting scripts.

## Repository structure

- `src/`: early wrapper scripts (`snp_pipeline.py`, `run_snp_pipeline*.sh`, `run_simutator.sh`).
- `variantiq-pipelines/`: pipeline runner (`src/run_pipelines.py`) and standardized pipeline scripts:
  - `variantiq-bwa-bcftools.pipeline.sh`
  - `variantiq-bwa-freebayes.pipeline.sh`
  - `variantiq-snippy-snippy.pipeline.sh`
- `variantiq-benchmark/`: benchmark dataset builder and report generation (`build_benchmark_data.py`, `benchmark.py`, report scripts).
- `test/`: manual test instructions rather than automated test suites.

## Execution model

- The project relies heavily on `scif run ...` commands to invoke bioinformatics tooling (e.g., `bwa`, `bcftools`, `freebayes`, `snippy`, `minos`, `varifier`).
- Typical workflow:
  1. Build/download benchmark inputs.
  2. Run pipelines per sample.
  3. Normalize and evaluate VCF outputs.
  4. Generate summary artifacts (CSV/HTML/plots).
- CI includes Docker image build/publish configuration targeting `ghcr.io/nssac/variantiq`.

## Stack and current maturity

- Primary implementation: Python + Bash.
- CLI frameworks present: `click` (legacy wrapper) and `cyclopts` (pipeline/benchmark CLIs).
- Conda environment definitions are provided in submodules.
- The codebase appears functional but still maturing in places, with manual test docs, limited top-level documentation, and some `NotImplemented` paths in dataset-building utilities.
