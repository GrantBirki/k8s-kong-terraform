FROM python:3.9.2-alpine

# upgrade pip
RUN pip install --upgrade pip

# get curl for healthchecks
RUN apk add curl

# permissions and nonroot user for tightened security
RUN adduser -D nonroot
RUN mkdir /app/ && chown -R nonroot:nonroot /app
RUN mkdir -p /var/log/app && touch /var/log/app/app.err.log && touch /var/log/app/app.out.log
RUN chown -R nonroot:nonroot /var/log/app
WORKDIR /app
USER nonroot

# venv
ENV VIRTUAL_ENV=/app/venv

# python setup
COPY --chown=nonroot:nonroot requirements.txt requirements.txt
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN export APP=app.py
RUN pip install -r requirements.txt

# copy files
COPY --chown=nonroot:nonroot app.py wsgi.py ./

# define the port number the container should expose
EXPOSE 5000

CMD ["gunicorn", "-w", "3", "-t", "60", "-b", "0.0.0.0:5000", "app:app"]