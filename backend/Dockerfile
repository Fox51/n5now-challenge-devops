FROM python:3.8-slim

WORKDIR /app

COPY app.py /app

RUN pip install Flask==3.0.3

ENV DEPLOYMENT_ENV=Unknown

CMD ["python", "app.py"]
