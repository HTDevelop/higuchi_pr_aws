# 実行ステージ
FROM python:3.13-slim

RUN apt-get update && apt-get install -y nginx supervisor && rm -rf /var/lib/apt/lists/*

WORKDIR /app/

COPY app/higuchi_pr/ /app/
RUN pip install --no-cache-dir -r requirements.txt
RUN python manage.py collectstatic --noinput

COPY infra/nginx.conf /etc/nginx/sites-available/default
COPY infra/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/www/web/static

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n"]