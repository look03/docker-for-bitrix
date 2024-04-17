FROM nginx:1.21.4

RUN apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
  curl netcat

COPY ./rootfs/ /

HEALTHCHECK --interval=5s --timeout=3s \
  CMD curl -f http://localhost/status/ || exit 1
