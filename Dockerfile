# Builder stage for Copilot CLI installation
FROM tsl0922/ttyd:1.8.0 AS builder

# 1. Basis-Tools + Locales
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates locales && \
    locale-gen de_DE.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=de_DE.UTF-8 \
    LC_ALL=de_DE.UTF-8

# 2. GitHub Copilot CLI installieren (offizielles Install-Script)
RUN curl -fsSL https://gh.io/copilot-install -o /tmp/copilot-install.sh && bash /tmp/copilot-install.sh

# Runtime stage
FROM tsl0922/ttyd:1.8.0

# Copy Copilot CLI binary from builder stage
COPY --from=builder /usr/local/bin/copilot /usr/local/bin/copilot

# 1. Basis-Tools + Locales (minimal, only what ttyd needs)
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates locales && \
    locale-gen de_DE.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=de_DE.UTF-8 \
    LC_ALL=de_DE.UTF-8

# 3. Arbeitsverzeichnis
WORKDIR /workspace
RUN mkdir -p /workspace

# 4. Port für ttyd (intern 8833)
EXPOSE 8833

# 5. ttyd starten: lauscht auf Port 8833 und startet eine Bash
CMD ["ttyd", "-W", "-p", "8833", "bash"]