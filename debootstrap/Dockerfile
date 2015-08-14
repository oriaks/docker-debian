FROM oriaks/debian:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV TERM=linux

VOLUME /debian

COPY entrypoint.sh /entrypoint.sh
RUN ["/entrypoint.sh","install"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["init"]
