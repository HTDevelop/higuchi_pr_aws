FROM python:3.13-slim

# 必要パッケージのインストール（nginx とビルドツール）
RUN apt-get update && apt-get install -y \
    build-essential libpq-dev nginx supervisor \
    && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリ
WORKDIR /app/

# アプリケーションコードをコピー
COPY app/higuchi_pr/ /app/

RUN pip install --no-cache-dir -r requirements.txt

# 静的ファイル用ディレクトリ作成
RUN mkdir -p /var/www/web/static

# Djangoの静的ファイル収集
RUN python manage.py collectstatic --noinput

# nginx 設定ファイルをコンテナ内にコピー
COPY infra/nginx.conf /etc/nginx/sites-available/default

# ポート開放
EXPOSE 80

# supervisor設定ファイルをコピー
COPY infra/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# コンテナ起動時に supervisor を使って nginx と gunicorn を起動
CMD ["/usr/bin/supervisord", "-n"]