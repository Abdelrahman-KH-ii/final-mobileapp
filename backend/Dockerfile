# ── HuggingFace Space Dockerfile ──────────────────────────────────────────────
# HuggingFace Spaces run containers as non-root user (UID 1000) on port 7860.
# ──────────────────────────────────────────────────────────────────────────────

FROM python:3.11-slim

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user (HuggingFace requirement)
RUN useradd -m -u 1000 appuser

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Fix permissions for non-root user
RUN chown -R appuser:appuser /app

USER appuser

# Collect static files
RUN python manage.py collectstatic --noinput --settings=config.settings 2>/dev/null || true

# Expose HuggingFace default port
EXPOSE 7860

# Entrypoint: run migrations then start gunicorn
CMD ["sh", "-c", "\
    python manage.py migrate --noinput && \
    gunicorn config.wsgi:application \
        --bind 0.0.0.0:7860 \
        --workers 2 \
        --timeout 120 \
        --log-level info \
"]
