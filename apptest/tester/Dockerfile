FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.5

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
  ca-certificates \
  curl

COPY tests /tests
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
