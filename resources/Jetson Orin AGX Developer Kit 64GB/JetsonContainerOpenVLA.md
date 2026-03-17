# Jetson Container x OpenVLA Setup Guide

This document describes how we configured a Jetson container environment to run **OpenVLA** on a **Jetson AGX Orin 64GB**.

## 1. Clone and Install `jetson-containers`
If the `jetson-containers` repository is **not present** in the Jetson's main directory, clone and install it with:

```bash
git clone https://github.com/dusty-nv/jetson-containers
bash jetson-containers/install.sh
```

This installs the container tools and prepares the environment.

## 2. Pull the Specific `nano_llm` Image
We need a **specific** tagged version of the nano LLM image because `autotag` pulls an undesired one.
The Tag and the info are at the page : https://github.com/dusty-nv/jetson-containers/tree/master

The required image tag is:
```
dustynv/<Repository/Tag - arm64 >
```

Pull it using the following command:

```bash
docker pull dustynv/<Repository/Tag - arm64 >
```

## 3. Launch the Container
Run the container using:

```bash
jetson-containers run dustynv/<Repository/Tag - arm64 >
```

This will start the environment needed to run OpenVLA.

## 4. Adjust TIMM Version
Before running the model, it is necessary to downgrade TIMM. Version **0.9.16** is recommended because it is the last version before the major changes introduced in 1.0.

Install it with:

```bash
pip install timm==0.9.16 --index-url https://pypi.org/simple
```

Verify installation:

```bash
python3 -c "import timm; print(timm.__version__)"
```

## 5. Recommended Workflow
It is recommended to create a **personal folder** inside the `jetson-containers` repository to store your own files. This directory is automatically linked inside the container, meaning:
- Files edited **outside** the container are reflected **inside**, and vice‑versa.
- It simplifies development and avoids needing to rebuild or copy files repeatedly.

Example:
```
jetson-containers/
└── my_workspace/
    ├── your_scripts.py
    └── configs/
```

You can then access `my_workspace/` directly from inside the container.
