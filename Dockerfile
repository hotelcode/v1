# path: Dockerfile
# Build stage
FROM python:3.12.3-slim as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install poetry
ENV POETRY_VERSION=1.8.2
RUN pip install poetry==$POETRY_VERSION

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml poetry.lock* ./

# Install dependencies
RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi --no-root --only main

# Production stage
FROM python:3.12.3-slim as production

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy Python packages from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application code
COPY ./backend ./backend
COPY ./migrations ./migrations
COPY alembic.ini ./

# Create necessary directories
RUN mkdir -p /app/logs /tmp/prometheus && \
    chown -R appuser:appuser /app /tmp/prometheus

# Switch to non-root user
USER appuser

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV APP_HOST=0.0.0.0
ENV APP_PORT=8000

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/healthz || exit 1

# Run the application
CMD ["sh", "-c", "if [ \"$OFFLOAD_HEAVY\" = \"0\" ]; then alembic upgrade head; fi && uvicorn backend.main:app --host $APP_HOST --port $APP_PORT --workers 4"]

# Development stage
FROM production as development

# Switch back to root for development tools
USER root

# Copy dev dependencies
COPY --from=builder /app/pyproject.toml /app/poetry.lock* ./

# Install poetry and dev dependencies
RUN pip install poetry==$POETRY_VERSION && \
    poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi

# Install additional dev tools
RUN apt-get update && apt-get install -y \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Switch back to appuser
USER appuser

# Override CMD for development
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]