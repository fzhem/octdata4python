FROM ubuntu:24.04@sha256:6015f66923d7afbc53558d7ccffd325d43b4e249f41a6e93eef074c9505d2233

# Install required dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    git \
    build-essential cmake \
    # liboctdata needs boost
    libboost-iostreams-dev libboost-locale-dev libboost-log-dev libboost-numpy-dev libboost-program-options-dev libboost-python-dev libboost-serialization-dev \
    # opencv is a core lib for libe2e/liboctdata
    libopencv-dev libopenjp2-7-dev \
    # liboctdata dicom support
    libdcmtk-dev \
    # for auditwheels
    patchelf \
    libnsl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set the working directory
WORKDIR /home/appuser
RUN mkdir -p /home/appuser/oct

WORKDIR /home/appuser/oct

RUN git clone https://github.com/kaygdev/oct_cpp_framework.git
RUN git clone https://github.com/fzhem/LibE2E.git
RUN git clone https://github.com/fzhem/LibOctData.git
RUN git clone https://github.com/fzhem/octdata4python.git

RUN echo "🛠 Building oct_cpp_framework..."
RUN mkdir /home/appuser/oct/oct_cpp_framework/build
WORKDIR /home/appuser/oct/oct_cpp_framework/build
RUN cmake -DCMAKE_BUILD_TYPE=Release ..
RUN make -j$(nproc)

RUN echo "🛠 Building LibE2E..."
RUN mkdir /home/appuser/oct/LibE2E/build
WORKDIR /home/appuser/oct/LibE2E/build
RUN cmake -DCMAKE_BUILD_TYPE=Release ..
RUN make -j$(nproc)

RUN echo "🛠 Building LibOctData..."
RUN mkdir /home/appuser/oct/LibOctData/build
WORKDIR /home/appuser/oct/LibOctData/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_WITH_SUPPORT_DICOM=ON ..
RUN make -j$(nproc)
RUN make install

RUN echo "🛠 Building octdata4python..."
WORKDIR /home/appuser/oct/octdata4python
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
RUN for PYVER in 3.10 3.11 3.12; do \
    uv sync --python=$PYVER && \
    .venv/bin/python3 -m build --installer=uv && \
    CLEANVER=$(echo $PYVER | tr -d '.') && \
    .venv/bin/python3 -m auditwheel repair dist/octdata4python-*-cp${CLEANVER}*.whl --plat manylinux_2_39_x86_64; \
done
