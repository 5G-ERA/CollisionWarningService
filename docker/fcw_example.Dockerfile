FROM but5gera/netapp_base_gstreamer:0.1.1

#FROM nvidia/cuda:11.7.1-base-ubuntu20.04
FROM python:3.8-slim

RUN apt-get update \
    && apt-get install -y python3 python-is-python3 python3-pip git

RUN python3 -m pip install --upgrade pip

#RUN pip install torch===1.13.1+cu117 torchvision===0.14.1+cu117 torchaudio===0.13.1+cu117 --extra-index-url https://download.pytorch.org/whl/cu117

RUN mkdir -p /root/opencv

COPY --from=0 /root/opencv/*.whl /root/opencv/

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Prague

RUN apt-get update \
    && apt-get install -y \
    libgstreamer1.0-0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-tools \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev

RUN cd /root/opencv \
    && pip3 install *.whl

ENTRYPOINT ["/root/fcw_example_start.sh"]

COPY fcw/core/ /root/fcw/core

RUN cd /root/fcw/core \
    && pip3 install -r requirements.txt

COPY data /root/data
COPY config /root/config
COPY videos /root/videos

COPY pyproject.toml /root/
COPY README.md /root/

RUN pip3 install poetry

#export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring
RUN cd /root/ \
    && poetry config virtualenvs.create false \
    && poetry install

COPY docker/fcw_example_start.sh /root/fcw_example_start.sh

RUN chmod +x /root/fcw_example_start.sh

EXPOSE 5897
EXPOSE 5001 5002 5003