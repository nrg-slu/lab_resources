FROM dustynv/pytorch:2.1-r36.2.0

RUN apt-get update && apt-get install -y \
    git \
    libopenjp2-7-dev \
    libjpeg-dev \
    zlib1g-dev \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir "numpy==1.24.4" && \
    pip3 install --no-cache-dir \
    scipy \
    tqdm \
    Pillow \
    matplotlib && \
    pip3 install --no-cache-dir --no-deps "torchvision==0.16.0"
    
RUN pip3 install --no-cache-dir \
    scipy \
    numpy \
    tqdm \
    Pillow \
    matplotlib

# Build torchvision from source - SM 8.7 = Jetson Orin
RUN git clone --branch v0.16.0 --depth 1 https://github.com/pytorch/vision.git /tmp/vision && \
    cd /tmp/vision && \
    FORCE_CUDA=1 \
    TORCH_CUDA_ARCH_LIST="8.7" \
    python3 setup.py install && \
    rm -rf /tmp/vision

WORKDIR /workspace