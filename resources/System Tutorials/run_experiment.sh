#!/bin/bash
# =============================================================================
# run_experiment.sh — SLURM batch script for launching ML experiments
#
# Usage:
#   sbatch run_experiment.sh
#   sbatch --export=MODEL=resnet50,LR=0.001 run_experiment.sh
#
# Submit a job array (runs with TASK IDs 0..4):
#   sbatch --array=0-4 run_experiment.sh
# =============================================================================

#SBATCH --job-name=ml_experiment
#SBATCH --output=logs/%j_%x_out.txt     # %j = JOBID, %x = job name
#SBATCH --error=logs/%j_%x_err.txt
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --gres=gpu:1
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your@email.com

# -----------------------------------------------------------------------------
# 0. Useful SLURM environment variables (auto-set by SLURM)
# -----------------------------------------------------------------------------
echo "========================================"
echo " SLURM Job Info"
echo "========================================"
echo "  Job ID        : $SLURM_JOB_ID"
echo "  Job Name      : $SLURM_JOB_NAME"
echo "  Node          : $SLURM_NODELIST"
echo "  Partition     : $SLURM_JOB_PARTITION"
echo "  CPUs/task     : $SLURM_CPUS_PER_TASK"
echo "  Array Task ID : ${SLURM_ARRAY_TASK_ID:-N/A}"
echo "  Start time    : $(date)"
echo "========================================"

# -----------------------------------------------------------------------------
# 1. Create output / log directories
# -----------------------------------------------------------------------------
mkdir -p logs results

# -----------------------------------------------------------------------------
# 2. Load required modules (adjust to your cluster's module system)
# -----------------------------------------------------------------------------
module purge
module load cuda/12.1
module load cudnn/8.9
module load python/3.11

# -----------------------------------------------------------------------------
# 3. Activate virtual environment (or conda)
# -----------------------------------------------------------------------------
# Option A — venv
source /path/to/your/venv/bin/activate

# Option B — conda (uncomment if using conda)
# source $(conda info --base)/etc/profile.d/conda.sh
# conda activate my_env

# -----------------------------------------------------------------------------
# 4. Configurable hyperparameters
#    Override via: sbatch --export=MODEL=vgg16,LR=0.0001 run_experiment.sh
#    Or via job array index (SLURM_ARRAY_TASK_ID)
# -----------------------------------------------------------------------------
MODEL="${MODEL:-resnet50}"
LR="${LR:-0.001}"
BATCH_SIZE="${BATCH_SIZE:-64}"
EPOCHS="${EPOCHS:-100}"
SEED="${SEED:-42}"
DATASET="${DATASET:-imagenet}"
DATA_DIR="${DATA_DIR:-/scratch/$USER/data}"
OUT_DIR="results/${SLURM_JOB_ID}_${MODEL}_lr${LR}"

# If running as a job array, use the task ID to pick a config
if [ -n "$SLURM_ARRAY_TASK_ID" ]; then
    CONFIGS=("resnet18" "resnet50" "vgg16" "densenet121" "efficientnet_b0")
    MODEL="${CONFIGS[$SLURM_ARRAY_TASK_ID]}"
    OUT_DIR="results/array_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}_${MODEL}"
fi

mkdir -p "$OUT_DIR"

echo ""
echo "--- Experiment Config ---"
echo "  Model      : $MODEL"
echo "  LR         : $LR"
echo "  Batch Size : $BATCH_SIZE"
echo "  Epochs     : $EPOCHS"
echo "  Seed       : $SEED"
echo "  Dataset    : $DATASET"
echo "  Data dir   : $DATA_DIR"
echo "  Output dir : $OUT_DIR"
echo "-------------------------"
echo ""

# -----------------------------------------------------------------------------
# 5. Check GPU availability
# -----------------------------------------------------------------------------
echo "--- GPU Status ---"
nvidia-smi
echo ""

# -----------------------------------------------------------------------------
# 6. Run the experiment
# -----------------------------------------------------------------------------
echo "--- Starting Training ---"
python train.py \
    --model       "$MODEL" \
    --lr          "$LR" \
    --batch-size  "$BATCH_SIZE" \
    --epochs      "$EPOCHS" \
    --seed        "$SEED" \
    --dataset     "$DATASET" \
    --data-dir    "$DATA_DIR" \
    --output-dir  "$OUT_DIR" \
    --workers     "$SLURM_CPUS_PER_TASK"

EXIT_CODE=$?

# -----------------------------------------------------------------------------
# 7. Report outcome
# -----------------------------------------------------------------------------
echo ""
echo "========================================"
echo "  End time  : $(date)"
echo "  Exit code : $EXIT_CODE"
echo "========================================"

if [ $EXIT_CODE -ne 0 ]; then
    echo "ERROR: Training script exited with code $EXIT_CODE" >&2
    exit $EXIT_CODE
fi

echo "Training completed successfully."
echo "Results saved to: $OUT_DIR"
