FROM debian

RUN apt update -y && \
  apt upgrade -y && \
  apt install curl -y

WORKDIR app

COPY gh-md-toc .

RUN chmod +x gh-md-toc

ENTRYPOINT ["./gh-md-toc"]
CMD []
