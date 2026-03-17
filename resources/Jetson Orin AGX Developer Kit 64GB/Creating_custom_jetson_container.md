# Jetson PyTorch + Torchvision Custom Docker

This repository provides a custom Docker image for NVIDIA Jetson devices (tested with Jetson Orin, SM 8.7) built on top of `dustynv/pytorch:2.1-r36.2.0`.

It installs compatible Python dependencies and builds `torchvision` from source to ensure CUDA support aligned with the Jetson architecture.

---

## 📦 Base Image

* `dustynv/pytorch:2.1-r36.2.0`

  * Preconfigured for JetPack 6 (L4T R36.2)
  * Includes CUDA, cuDNN, and PyTorch optimized for Jetson

---

## ⚙️ Features

* Fixed `numpy==1.24.4` for compatibility
* System libraries for image processing:

  * `libjpeg`
  * `libopenjp2`
  * `zlib`
* Python packages:

  * `scipy`, `tqdm`, `Pillow`, `matplotlib`
* Custom-built `torchvision==0.16.0` with CUDA support
* Optimized for:

  * Jetson Orin (SM 8.7)

---

## 🏗️ Build the Docker Image

Run this from the directory containing your `Dockerfile`:

```bash
docker build -t jetson-pytorch:torchvision .
```

---

## 🚀 Run the Container

On Jetson devices, use NVIDIA runtime:

```bash
docker run -it --rm \
  --runtime nvidia \
  --network host \
  -v $(pwd):/workspace \
  jetson-pytorch:torchvision
```

Optional (for GUI apps like matplotlib):

```bash
-e DISPLAY=$DISPLAY \
-v /tmp/.X11-unix:/tmp/.X11-unix
```

---

## 🧠 Important Notes

### 1. Torchvision Build (CUDA Enabled)

`torchvision` is compiled from source with:

```bash
FORCE_CUDA=1
TORCH_CUDA_ARCH_LIST="8.7"
```

* `8.7` corresponds to Jetson Orin GPU architecture
* Ensures CUDA kernels are properly compiled

---

### 2. Duplicate pip Installs

There is a redundant install block:

```dockerfile
RUN pip3 install --no-cache-dir \
    scipy \
    numpy \
    tqdm \
    Pillow \
    matplotlib
```

This duplicates earlier installs and can be safely removed to:

* Reduce image size
* Speed up build time

---

### 3. Version Compatibility

| Component   | Version          |
| ----------- | ---------------- |
| PyTorch     | 2.1 (base image) |
| Torchvision | 0.16.0           |
| NumPy       | 1.24.4           |

These versions are aligned for Jetson + CUDA compatibility.

---

## 📁 Working Directory

Default working directory inside the container:

```bash
/workspace
```

Bind mount your project there:

```bash
-v $(pwd):/workspace
```

---

## 🧪 Verify Installation

Inside the container:

```python
import torch
import torchvision

print(torch.__version__)
print(torch.cuda.is_available())
print(torchvision.__version__)
```

Expected:

* CUDA available → `True`
* Torchvision loads without errors

---

## 🔧 Customization

### Change CUDA Architecture

If using a different Jetson:

| Device   | SM Version |
| -------- | ---------- |
| Xavier   | 7.2        |
| Nano/TX2 | 5.3 / 6.2  |

Update:

```bash
TORCH_CUDA_ARCH_LIST="7.2"
```

---

### Add More Dependencies

Modify the Dockerfile:

```dockerfile
RUN pip3 install <your-package>
```

---

## ⚠️ Troubleshooting

### Torchvision import fails

* Ensure it was built against the same PyTorch version
* Rebuild image without cache:

```bash
docker build --no-cache -t jetson-pytorch:torchvision .
```

---

### CUDA not available

* Check runtime flag:

  ```bash
  --runtime nvidia
  ```
* Verify JetPack installation:

  ```bash
  nvcc --version
  ```

---

### Build takes too long

* Torchvision compilation is expected to take several minutes on Jetson
* Consider using swap memory if builds fail due to RAM limits

---

## 📌 Summary

This Docker image provides a reproducible, CUDA-enabled PyTorch + Torchvision environment tailored for Jetson devices, avoiding common compatibility issues by building critical components from source.

---
`