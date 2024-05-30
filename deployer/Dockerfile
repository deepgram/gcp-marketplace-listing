FROM marketplace.gcr.io/google/c2d-debian11 AS build

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends gettext

ADD chart/deepgram-self-hosted-starter /tmp/chart
RUN cd /tmp && tar -czvf /tmp/deepgram-self-hosted-starter.tar.gz chart

ADD apptest/deployer/deepgram-self-hosted-starter /tmp/test/chart
RUN cd /tmp/test \
  && tar -czvf /tmp/test/deepgram-self-hosted-starter.tar.gz chart/

ADD schema.yaml /tmp/schema.yaml

ARG REGISTRY
ARG TAG

RUN cat /tmp/schema.yaml > /tmp/schema.yaml.new \
  && mv /tmp/schema.yaml.new /tmp/schema.yaml

ADD apptest/deployer/schema.yaml /tmp/apptest/schema.yaml
RUN cat /tmp/apptest/schema.yaml > /tmp/apptest/schema.yaml.new \
  && mv /tmp/apptest/schema.yaml.new /tmp/apptest/schema.yaml

FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm:latest
COPY --from=build /tmp/deepgram-self-hosted-starter.tar.gz /data/chart/
COPY --from=build /tmp/test/deepgram-self-hosted-starter.tar.gz /data-test/chart/
COPY --from=build /tmp/apptest/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/

ENV WAIT_FOR_READY_TIMEOUT 300
ENV TESTER_TIMEOUT 60
