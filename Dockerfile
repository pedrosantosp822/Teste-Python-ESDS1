FROM python:3.10-slim

# Desinstalar ferramentas que permitem acesso à internet
RUN apt-get update && apt-get remove -y curl wget && \
    rm -rf /var/lib/apt/lists/*

# Instalar pacotes Python necessários (pré-definidos)
RUN pip install numpy pandas matplotlib

# Criar utilizador não privilegiado
RUN useradd -ms /bin/bash aluno
USER aluno
WORKDIR /home/aluno
