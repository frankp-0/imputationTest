#!/usr/bin/env sh

#SBATCH --time=3-0
#SBATCH -o log/%j.out
#SBATCH -e log/%j.err

module load python
module load r
snakemake -j 10 --cluster "sbatch --cpus-per-task=50 --mem=150G --time=3-0 -o log/%j.out -e log/%j.err"
