FROM elixir:1.14-alpine as builder

ARG PLEROMA_VERSION=stable
ARG PLEROMA_REPO=https://git.pleroma.social/pleroma/pleroma.git
ENV MIX_ENV=prod

# Install build dependencies
RUN apk add --no-cache git gcc g++ musl-dev make cmake file-dev ncurses postgresql-client imagemagick libmagic ffmpeg exiftool

WORKDIR /app
RUN git clone --filter=blob:none --no-checkout ${PLEROMA_REPO} . \
  && git checkout ${PLEROMA_VERSION}


RUN echo "import Mix.Config" > config/prod.secret.exs \
  && mix local.hex --force \
  && mix local.rebar --force \
  && mix deps.get --only prod \
  && mix deps.compile

FROM elixir:1.14-alpine as runner
ENV MIX_ENV=prod
ARG EXTRA_PKGS="imagemagick libmagic ffmpeg"

# Install runtime dependencies
RUN apk add --no-cache shadow su-exec git postgresql-client exiftool ${EXTRA_PKGS}
WORKDIR /app

ADD start.sh /app/start.sh
RUN  chmod +x /app/start.sh \
  && groupmod -g 1000 users \
  && useradd -u 1000 -U -d /home/pleroma -s /bin/false pleroma \
  && usermod -G users pleroma \
  && mkdir -p \ /data/uploads /data/static \
  && chown -R pleroma:users /data

COPY --from=builder --chown=pleroma /root/.mix /home/pleroma/.mix
COPY --from=builder --chown=pleroma /app .

ADD base-config.exs /app/config/prod.secret.exs

EXPOSE 4000
ENTRYPOINT ["/app/start.sh"]