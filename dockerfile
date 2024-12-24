FROM python:3.11-slim
WORKDIR web_app

COPY ./app/requirements.txt .
RUN pip install -r requirements.txt

COPY ./app .
EXPOSE 5000
CMD [ "gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app" ]
