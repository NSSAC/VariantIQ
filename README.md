# VariantIQ

Evaluate variant callers against a known answer.

A **caller** takes sequencing **reads** and a species **reference** genome and writes a VCF: claimed differences between that isolate and the reference. VariantIQ grades each VCF against a **truth** genome (a high-quality assembly of the same isolate). Callers never see the truth.

| Input | Role |
|---|---|
| `reference_genome.fasta` | Species coordinate system (here, TB H37Rv). Callers report diffs from this. |
| `read_1.fastq` (+ `read_2.fastq` if paired) | Shotgun reads from one isolate. Only evidence the caller may use. |
| `truth_genome.fasta` | Independent assembly of that isolate. Answer key for scoring. |

## Design

Two containers share a directory of sample folders. They do not call each other.

**Benchmark image** (`variantiq-benchmark/`) — setup, scoring, reporting.

- Assemble each isolate’s reads, reference, and truth into a standard folder.
- After callers have written VCFs: normalize, run Varifier, write CSV/plots/HTML.

**Pipeline image** (`variantiq-pipelines/`) — callers, run the same way.

- Encapsulate each caller as a SCIF app.
- Orchestrate them over the sample folders. Add a caller by adding a pipeline script (and a SCIF app if the tool is new).

Current callers: `variantiq-bwa-bcftools`, `variantiq-bwa-freebayes`, `variantiq-snippy-snippy`. Minos is in the image for adjudication; Clockwork is present but its pipeline is disabled.

```
benchmark image                    pipeline image                 benchmark image
build_benchmark_data    →     run every *.pipeline.sh    →     benchmark (Varifier + report)
reads + ref + truth                 one VCF per caller              precision / recall / F1
```

Both images are SCIF (entrypoint `scif --quiet`). `config.json` is the SciDuct-facing app list.

## Sample folder contract

```
/output/
  benchmark_samples.csv
  <sample_name>/
    read_1.fastq
    read_2.fastq              # omit for single-end
    reference_genome.fasta
    truth_genome.fasta
    <pipeline_name>.vcf       # written by the pipeline image
```

## Usage

Build (SciDucTainer install needs a GitHub token):

```bash
docker build --secret id=gh_token,env=GH_TOKEN -t variantiq-benchmark variantiq-benchmark
docker build --secret id=gh_token,env=GH_TOKEN -t variantiq-pipelines variantiq-pipelines
```

Mount a host directory at `/output`. Apps default to that path.

**1. Build a dataset** (benchmark image)

```bash
docker run --rm -v "$PWD/data:/output" variantiq-benchmark \
  run build_benchmark_data --dataset minos --pipeline-inputs-only
```

| Dataset | Reads |
|---|---|
| `minos` | Illumina paired-end TB isolates (Minos paper) |
| `minos-single` | PacBio single-end, same isolates |

`--pipeline-inputs-only` skips pre-run comparison VCFs. `--comparison-vcf-only` fetches only those VCFs.

**2. Run callers** (pipeline image)

```bash
docker run --rm -v "$PWD/data:/output" variantiq-pipelines \
  run pipeline list

docker run --rm -v "$PWD/data:/output" variantiq-pipelines \
  run pipeline run-benchmark-pipelines --nthread 4
```

Each `*.pipeline.sh` writes `<sample>/<pipeline_name>.vcf`. Pass `--debug` to keep intermediate dirs.

**3. Score** (benchmark image)

```bash
docker run --rm -v "$PWD/data:/output" variantiq-benchmark \
  run benchmark
```

Writes `/output/benchmark/` (`benchmark_results.csv`, plots, HTML).

## Adding a caller

1. If the tool is not already a SCIF app, add `<tool>.scif` (and its conda env) under `variantiq-pipelines/` and install it in that Dockerfile.
2. Add `variantiq-pipelines/src/pipelines/<name>.pipeline.sh`. It is invoked as:

   ```text
   <name>.pipeline.sh  <sample_folder>  <nthread>  [debug]
   ```

   Read the standard FASTQ/FASTA names above. Write `<sample_folder>/<name>.vcf`.
3. The orchestrator picks up every `*.pipeline.sh` automatically.

## Repo layout

| Path | What |
|---|---|
| `variantiq-benchmark/` | Dataset builder, Varifier, Simutator, reports |
| `variantiq-pipelines/` | Caller apps and `run_pipelines.py` |
| `src/` | Early one-shot scripts; not the current interface |
| `test/` | Manual `docker run` notes |

---

The two images exist because the caller stack and the Varifier/Simutator stack do not install cleanly together.
