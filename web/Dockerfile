FROM python:3.6

ENV PYTHONUNBUFFERED 1
RUN mkdir -p /web

COPY Pipfile Pipfile.lock /web/
WORKDIR /web
RUN pip install pipenv && pipenv install --system

COPY . /web

EXPOSE 8000
CMD ["gunicorn", "-c", "gunicorn.py", "--bind", ":8000", "website.wsgi:application"]
