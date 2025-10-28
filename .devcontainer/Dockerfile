FROM python:3.10-slim

RUN apt-get update && apt-get install -y build-essential && \
    pip install --no-cache-dir numpy pandas matplotlib && \
    apt-get remove -y curl wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash aluno
USER aluno
WORKDIR /home/aluno
