#!/usr/bin/env sh

#SBATCH --time=3-0

module load python
module load r
snakemake -j 10 --cluster "sbatch --cpus-per-task=50 --mem=150G --time=3-0"
