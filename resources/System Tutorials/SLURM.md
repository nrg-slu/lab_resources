# SLURM Quick Reference Guide

A practical guide to using SLURM (Simple Linux Utility for Resource Management) for job scheduling on HPC clusters.

---

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Basic Commands](#basic-commands)
   - [srun — Run a command interactively](#srun)
   - [sbatch — Submit a batch job](#sbatch)
   - [scancel — Cancel a job](#scancel)
   - [squeue — View the job queue](#squeue)
   - [sinfo — View cluster status](#sinfo)
   - [sacct — View job accounting](#sacct)
3. [Common sbatch Directives](#common-sbatch-directives)
4. [Example Scripts](#example-scripts)
5. [Tips & Tricks](#tips--tricks)

---

## Core Concepts

| Term | Description |
|------|-------------|
| **Job** | A unit of work submitted to the scheduler |
| **Node** | A physical machine in the cluster |
| **Partition** | A logical group of nodes (a.k.a. queue) |
| **Task** | A single process within a job |
| **Step** | A set of (possibly parallel) tasks within a job |
| **JOBID** | Unique integer identifier assigned to each submitted job |

---

## Basic Commands

### `srun`

Run a command **interactively** or as a job step. Blocks until the job completes.

```bash
# Run a single command on 1 node, 4 CPUs
srun --nodes=1 --ntasks=4 hostname

# Open an interactive shell on a compute node
srun --nodes=1 --ntasks=1 --time=01:00:00 --pty bash

# Request a GPU node interactively
srun --nodes=1 --gres=gpu:1 --pty bash
```

---

### `sbatch`

Submit a **batch script** to the scheduler. Returns immediately with a JOBID.

```bash
# Submit a script
sbatch my_job.sh

# Submit with overridden parameters
sbatch --job-name=mytest --partition=gpu my_job.sh

# Submit and hold (won't start until manually released)
sbatch --hold my_job.sh

# Release a held job
scontrol release <JOBID>
```

---

### `scancel`

Cancel one or more jobs.

```bash
# Cancel a specific job by ID
scancel 12345

# Cancel all your jobs
scancel -u $USER

# Cancel all your jobs in a specific partition
scancel -u $USER -p gpu

# Cancel a specific job step
scancel 12345.0
```

---

### `squeue`

View the **job queue** and currently running jobs.

```bash
# Show all jobs in the queue
squeue

# Show only your jobs
squeue -u $USER

# Show jobs in a specific partition
squeue -p gpu

# Show detailed info (start time, reason for pending, etc.)
squeue -u $USER --long

# Custom format: JOBID, name, user, state, time, nodes
squeue -u $USER -o "%.10i %.20j %.8u %.8T %.10M %.6D"

# Watch the queue live (refresh every 5 seconds)
watch -n 5 squeue -u $USER
```

Common job **states**:

| State | Meaning |
|-------|---------|
| `PD` | Pending (waiting for resources) |
| `R`  | Running |
| `CG` | Completing |
| `CD` | Completed |
| `F`  | Failed |
| `CA` | Cancelled |

---

### `sinfo`

View cluster **node and partition status**.

```bash
# Show all partitions and their state
sinfo

# Show a specific partition
sinfo -p gpu

# Show detailed node info
sinfo -N -l
```

---

### `sacct`

View **accounting data** for past and current jobs.

```bash
# Show your jobs from today
sacct -u $USER

# Show jobs in a date range
sacct -u $USER --starttime=2024-01-01 --endtime=2024-12-31

# Show specific fields
sacct -u $USER --format=JobID,JobName,Partition,State,Elapsed,MaxRSS

# Show all steps of a specific job
sacct -j 12345 --format=JobID,JobName,State,Elapsed
```

---

## Common `sbatch` Directives

Place these at the top of your `.sh` script, after `#!/bin/bash`, prefixed with `#SBATCH`.

```bash
#SBATCH --job-name=my_job          # Job name
#SBATCH --output=logs/%j_out.txt   # Stdout log (%j = JOBID)
#SBATCH --error=logs/%j_err.txt    # Stderr log
#SBATCH --partition=gpu            # Partition/queue name
#SBATCH --nodes=1                  # Number of nodes
#SBATCH --ntasks=1                 # Number of tasks (processes)
#SBATCH --cpus-per-task=4          # CPUs per task
#SBATCH --mem=16G                  # Total memory per node
#SBATCH --time=02:00:00            # Wall time limit (HH:MM:SS)
#SBATCH --gres=gpu:1               # Generic resources (e.g. 1 GPU)
#SBATCH --mail-type=END,FAIL       # Email on job end or failure
#SBATCH --mail-user=you@mail.com   # Email address
#SBATCH --array=0-9                # Job array (10 jobs, indices 0–9)
```

---

## Example Scripts

| File | Description |
|------|-------------|
| [`run_experiment.sh`](./run_experiment.sh) | Standard ML experiment launcher with logging, environment setup, and parameter passing |
| [`run_jetson_docker.sh`](./run_jetson_docker.sh) | Launches a Docker container for Jetson Nano, checks dependencies, and runs inference code |

---

## Tips & Tricks

```bash
# Get detailed info on a running or pending job
scontrol show job <JOBID>

# Check estimated start time of a pending job
squeue --start -j <JOBID>

# Show available GPUs on each node
sinfo -p gpu -o "%N %G"

# Check your resource usage limits
sacctmgr show user $USER withassoc format=user,account,maxjobs,maxcpus,maxmem

# Requeue (restart) a failed job
scontrol requeue <JOBID>
```

---

> **Tip:** Always test your script with a short `--time` limit and `--nodes=1` before scaling up.  
> **Tip:** Use `$SLURM_JOB_ID`, `$SLURM_ARRAY_TASK_ID`, and `$SLURM_NODELIST` environment variables inside your scripts for dynamic logging and coordination.
