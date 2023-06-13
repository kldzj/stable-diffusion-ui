FROM ubuntu:latest
WORKDIR /app

RUN apt-get update && \
    apt-get install -y git curl unzip tar bzip2 libgl1 libglib2.0-0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN LATEST_RELEASE=$(curl --silent "https://api.github.com/repos/easydiffusion/easydiffusion/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    curl -L -O https://github.com/easydiffusion/easydiffusion/releases/download/${LATEST_RELEASE}/Easy-Diffusion-Linux.zip && \
    unzip Easy-Diffusion-Linux.zip && \
    rm Easy-Diffusion-Linux.zip

WORKDIR /app/easy-diffusion
RUN echo "{\"force_save_path\":\"/app/easy-diffusion/output\",\"render_devices\":\"auto\",\"ui\":{\"open_browser_on_start\":false}}" > ./scripts/config.json && \
    if [ -e "installer" ]; then export PATH="$(pwd)/installer/bin:$PATH"; fi && \
    ./scripts/bootstrap.sh && \
    cp ./scripts/on_env_start.sh ./scripts/on_env_prep.sh && \
    sed -i '/exec \.\/scripts\/on_sd_start\.sh/d' ./scripts/on_env_prep.sh && \
    if [ -e "installer_files/env" ]; then export PATH="$(pwd)/installer_files/env/bin:$PATH"; fi && \
    ./scripts/on_env_prep.sh && \
    cp ./scripts/on_sd_start.sh ./scripts/on_sd_prep.sh && \
    sed -i '/^uvicorn/d' ./scripts/on_sd_prep.sh && \
    sed -i '/^read/d' ./scripts/on_sd_prep.sh && \
    sed -i '/^read/d' ./scripts/on_sd_start.sh && \
    ./scripts/on_sd_prep.sh && \
    mkdir -p /app/easy-diffusion/output

EXPOSE 9000
ENTRYPOINT ["./start.sh"]
