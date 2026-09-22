FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim
LABEL authors="mbstockm"

WORKDIR /app

ENV UV_NO_CACHE=1

COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-install-project

COPY *.py .
COPY sql ./sql

ENTRYPOINT ["uv", "run"]