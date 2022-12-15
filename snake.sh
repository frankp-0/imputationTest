#!/usr/bin/env sh

#SBATCH --time=1-0

module load python
module load r
snakemake -j 10 --cluster "sbatch --cpus-per-task=10 --mem=30G --time=1-0"
