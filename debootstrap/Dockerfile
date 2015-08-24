FROM oriaks/debian:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

VOLUME /debian

COPY entrypoint.sh /entrypoint.sh
COPY klish_2.0.4_amd64.deb /klish_2.0.4_amd64.deb
RUN ["/entrypoint.sh","install"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["init"]
