FROM tsl0922/ttyd:1.8.0

# 1. Basis-Tools + Locales
RUN apt-get update && \
    apt-get install -y curl ca-certificates locales && \
    locale-gen de_DE.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=de_DE.UTF-8 \
    LC_ALL=de_DE.UTF-8

# 2. GitHub Copilot CLI installieren (offizielles Install-Script)
RUN curl -fsSL https://gh.io/copilot-install -o /tmp/copilot-install.sh && bash /tmp/copilot-install.sh

# 3. Arbeitsverzeichnis
WORKDIR /workspace
RUN mkdir -p /workspace

# 4. Port für ttyd (intern 8833)
EXPOSE 8833

# 5. ttyd starten: lauscht auf Port 8833 und startet eine Bash
CMD ["ttyd", "-W", "-p", "8833", "bash"]