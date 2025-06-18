FROM ubuntu:24.04@sha256:6015f66923d7afbc53558d7ccffd325d43b4e249f41a6e93eef074c9505d2233

# Install required dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    git wget tar \
    build-essential cmake \
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

RUN echo "Installing python version 3.10..3.13"
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
COPY scripts/uv-install-pythons.sh /uv-install-pythons.sh
RUN chmod +x /uv-install-pythons.sh
RUN /uv-install-pythons.sh

RUN echo "Downloading Boost 1.88.0"
RUN wget https://archives.boost.io/release/1.88.0/source/boost_1_88_0.tar.gz
RUN tar -xzf boost_1_88_0.tar.gz
WORKDIR /home/appuser/oct/boost_1_88_0
RUN echo "Run Boost Bootstrap Script"
RUN chmod +x /home/appuser/oct/boost_1_88_0/bootstrap.sh
RUN /home/appuser/oct/boost_1_88_0/bootstrap.sh

RUN echo "For user-config.jam"
ENV Python310_ROOT_DIR=/root/.local/share/uv/python/cpython-3.10.17-linux-x86_64-gnu
ENV Python311_ROOT_DIR=/root/.local/share/uv/python/cpython-3.11.12-linux-x86_64-gnu
ENV Python312_ROOT_DIR=/root/.local/share/uv/python/cpython-3.12.10-linux-x86_64-gnu
ENV Python313_ROOT_DIR=/root/.local/share/uv/python/cpython-3.13.4-linux-x86_64-gnu

WORKDIR /home/appuser/oct

RUN echo "Cloning required repositories"
RUN git clone https://github.com/kaygdev/oct_cpp_framework.git
RUN git clone https://github.com/fzhem/LibE2E.git
RUN git clone https://github.com/fzhem/LibOctData.git
RUN git clone https://github.com/fzhem/octdata4python.git

RUN echo "Boost will look in the following directory for user-config.jam"
ENV BOOST_BUILD_PATH=/home/appuser/oct/octdata4python

RUN echo "Build and Install Boost Libraries"
WORKDIR /home/appuser/oct/boost_1_88_0
RUN ./b2 -j$(nproc) \
    python=3.10,3.11,3.12,3.13 \
    --with-iostreams --with-locale --with-log --with-python --with-program_options --with-serialization \
    --debug-configuration install

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
RUN for PYVER in 3.10 3.11 3.12 3.13; do \
    uv sync --python=$PYVER && \
    export CMAKE_ARGS="-DPython3_VERSION=$PYVER" && \
    .venv/bin/python3 -m build --installer=uv && \
    CLEANVER=$(echo $PYVER | tr -d '.') && \
    .venv/bin/python3 -m auditwheel repair dist/octdata4python-*-cp${CLEANVER}*.whl --plat manylinux_2_39_x86_64; \
done
