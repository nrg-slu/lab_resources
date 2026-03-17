#!/bin/bash
# =============================================================================
# run_jetson_docker.sh — SLURM batch script for Jetson Nano Docker workflow
#
# This script:
#   1. Checks required dependencies (Docker, nvidia-container-toolkit, etc.)
#   2. Pulls (or verifies) the nvcr.io Jetson-compatible Docker image
#   3. Mounts your code and data into the container
#   4. Runs your inference / training code inside the container
#
# Usage:
#   sbatch run_jetson_docker.sh
#   sbatch --export=SCRIPT=infer.py,CHECKPOINT=model.pth run_jetson_docker.sh
# =============================================================================

#SBATCH --job-name=jetson_docker
#SBATCH --output=logs/%j_%x_out.txt
#SBATCH --error=logs/%j_%x_err.txt
#SBATCH --partition=gpu              # must be a node with GPU + Docker
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --gres=gpu:1
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=your@email.com

# =============================================================================
# Configuration — override with --export or edit here
# =============================================================================

# Docker image: use an L4T (Linux for Tegra) image compatible with Jetson Nano
DOCKER_IMAGE="${DOCKER_IMAGE:-nvcr.io/nvidia/l4t-pytorch:r32.7.1-pth1.10-py3}"
CONTAINER_NAME="jetson_job_${SLURM_JOB_ID}"

# Paths (adjust to your cluster layout)
CODE_DIR="${CODE_DIR:-$(pwd)}"                      # host path to your code
DATA_DIR="${DATA_DIR:-/scratch/$USER/data}"          # host path to datasets
OUTPUT_DIR="${OUTPUT_DIR:-$(pwd)/results/${SLURM_JOB_ID}}"

# Script to run inside the container
SCRIPT="${SCRIPT:-run_inference.py}"
CHECKPOINT="${CHECKPOINT:-checkpoints/best_model.pth}"
EXTRA_ARGS="${EXTRA_ARGS:-}"

# =============================================================================
# 0. Banner
# =============================================================================
echo "========================================"
echo " SLURM + Docker :: Jetson Nano Workflow"
echo "========================================"
echo "  Job ID     : $SLURM_JOB_ID"
echo "  Node       : $SLURM_NODELIST"
echo "  Start time : $(date)"
echo "  Image      : $DOCKER_IMAGE"
echo "  Code dir   : $CODE_DIR"
echo "  Data dir   : $DATA_DIR"
echo "  Output dir : $OUTPUT_DIR"
echo "========================================"

mkdir -p logs "$OUTPUT_DIR"

# =============================================================================
# 1. Dependency checks
# =============================================================================
echo ""
echo "--- [1/5] Checking dependencies ---"

check_cmd() {
    if ! command -v "$1" &>/dev/null; then
        echo "ERROR: '$1' not found. Please install it or load the correct module." >&2
        exit 1
    fi
    echo "  [OK] $1 ($(command -v "$1"))"
}

check_cmd docker
check_cmd nvidia-smi

# Check nvidia-container-toolkit is configured
if ! docker info 2>/dev/null | grep -q "Runtimes.*nvidia"; then
    echo "WARNING: nvidia runtime not found in Docker. Trying anyway..."
else
    echo "  [OK] nvidia container runtime detected"
fi

# Confirm at least one GPU is visible
GPU_COUNT=$(nvidia-smi --list-gpus 2>/dev/null | wc -l)
if [ "$GPU_COUNT" -eq 0 ]; then
    echo "ERROR: No GPUs detected by nvidia-smi." >&2
    exit 1
fi
echo "  [OK] $GPU_COUNT GPU(s) available"

# Check that code directory exists
if [ ! -d "$CODE_DIR" ]; then
    echo "ERROR: Code directory not found: $CODE_DIR" >&2
    exit 1
fi
echo "  [OK] Code directory: $CODE_DIR"

# Check that the main script exists
if [ ! -f "$CODE_DIR/$SCRIPT" ]; then
    echo "ERROR: Script not found: $CODE_DIR/$SCRIPT" >&2
    exit 1
fi
echo "  [OK] Script found: $SCRIPT"

# Check checkpoint (warning only — may be generated at runtime)
if [ ! -f "$CODE_DIR/$CHECKPOINT" ]; then
    echo "WARNING: Checkpoint not found: $CODE_DIR/$CHECKPOINT (continuing anyway)"
else
    echo "  [OK] Checkpoint: $CHECKPOINT"
fi

echo ""

# =============================================================================
# 2. GPU info
# =============================================================================
echo "--- [2/5] GPU Status ---"
nvidia-smi
echo ""

# =============================================================================
# 3. Pull / verify Docker image
# =============================================================================
echo "--- [3/5] Verifying Docker image ---"

if docker image inspect "$DOCKER_IMAGE" &>/dev/null; then
    echo "  [OK] Image already present locally: $DOCKER_IMAGE"
else
    echo "  Pulling image (this may take a while): $DOCKER_IMAGE"
    docker pull "$DOCKER_IMAGE"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to pull Docker image: $DOCKER_IMAGE" >&2
        exit 1
    fi
    echo "  [OK] Image pulled successfully."
fi
echo ""

# =============================================================================
# 4. Check Python dependencies inside the container
# =============================================================================
echo "--- [4/5] Checking Python dependencies inside container ---"

# requirements.txt is optional; create a minimal one if missing
REQ_FILE="$CODE_DIR/requirements.txt"
if [ -f "$REQ_FILE" ]; then
    echo "  Found requirements.txt — installing missing packages..."
    INSTALL_CMD="pip install --quiet -r /workspace/requirements.txt"
else
    echo "  No requirements.txt found — skipping pip install."
    INSTALL_CMD="echo 'No requirements.txt — skipping install.'"
fi

docker run --rm \
    --gpus all \
    --name "${CONTAINER_NAME}_depcheck" \
    -v "$CODE_DIR":/workspace \
    -w /workspace \
    "$DOCKER_IMAGE" \
    bash -c "
        set -e
        echo 'Python version:' && python3 --version
        echo 'PyTorch version:' && python3 -c 'import torch; print(torch.__version__)'
        echo 'CUDA available:' && python3 -c 'import torch; print(torch.cuda.is_available())'
        $INSTALL_CMD
        echo 'Dependency check passed.'
    "

if [ $? -ne 0 ]; then
    echo "ERROR: Dependency check failed." >&2
    exit 1
fi
echo "  [OK] All dependencies satisfied."
echo ""

# =============================================================================
# 5. Run the code inside the container
# =============================================================================
echo "--- [5/5] Launching container and running code ---"
echo "  Container name : $CONTAINER_NAME"
echo "  Running        : python3 $SCRIPT --checkpoint $CHECKPOINT $EXTRA_ARGS"
echo ""

docker run --rm \
    --gpus all \
    --name "$CONTAINER_NAME" \
    --shm-size=8g \
    -v "$CODE_DIR":/workspace \
    -v "$DATA_DIR":/data:ro \
    -v "$OUTPUT_DIR":/output \
    -e PYTHONUNBUFFERED=1 \
    -e CUDA_VISIBLE_DEVICES="$CUDA_VISIBLE_DEVICES" \
    -w /workspace \
    "$DOCKER_IMAGE" \
    bash -c "
        set -e
        echo '=== Container started at \$(date) ==='
        echo 'GPU inside container:'
        nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader
        echo ''

        # Run the actual script
        python3 $SCRIPT \
            --checkpoint $CHECKPOINT \
            --data-dir   /data \
            --output-dir /output \
            $EXTRA_ARGS

        echo ''
        echo '=== Container finished at \$(date) ==='
    "

EXIT_CODE=$?

# =============================================================================
# Done
# =============================================================================
echo ""
echo "========================================"
echo "  End time  : $(date)"
echo "  Exit code : $EXIT_CODE"
echo "  Results   : $OUTPUT_DIR"
echo "========================================"

if [ $EXIT_CODE -ne 0 ]; then
    echo "ERROR: Docker run exited with code $EXIT_CODE" >&2
    exit $EXIT_CODE
fi

echo "Job completed successfully."
