#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM --platform=$BUILDPLATFORM golang:1.23 AS build

# https://github.com/moby/buildkit/releases
ENV BUILDKIT_VERSION 0.23.2

COPY \
	argsescaped.patch \
	containerd-arm64-v8.patch \
	git-no-submodules.patch \
	mips64le.patch \
	noclip.patch \
	nolint.patch \
	/tmp/buildkit-patches/

WORKDIR /app

RUN set -eux; \
	git clone --branch "v$BUILDKIT_VERSION" --depth 1 --config advice.detachedHead=false 'https://github.com/moby/buildkit.git' .; \
	for patch in /tmp/buildkit-patches/*.patch; do \
		git apply --verbose "$patch"; \
	done; \
	git diff --color

ENV CGO_ENABLED 0

ARG TARGETOS TARGETARCH TARGETVARIANT
ENV GOOS=$TARGETOS GOARCH=$TARGETARCH VARIANT=$TARGETVARIANT

RUN set -eux; \
	case "$GOARCH/$VARIANT" in \
		amd64/*) export GOAMD64="$VARIANT" ;; \
		arm/*) export GOARM="${VARIANT#v}" ;; \
		arm64/v8) ;; \
		*) [ -z "$VARIANT" ] ;; \
	esac; \
	go env | grep -E 'OS=|ARCH=|AMD64=|ARM64=|ARM='; \
	\
# https://github.com/moby/buildkit/blob/v0.13.2/Dockerfile#L93
	pkg='github.com/moby/buildkit'; \
	ldflags=" \
		-d -w \
		-X '$pkg/version.Version=$BUILDKIT_VERSION-tianon' \
		-X '$pkg/version.Revision=v$BUILDKIT_VERSION+tianon-patches' \
		-X '$pkg/version.Package=$pkg' \
	"; \
	go build -o /buildkitd -trimpath -ldflags "$ldflags" ./cmd/buildkitd; \
	go build -o /buildctl -trimpath -ldflags "$ldflags" ./cmd/buildctl; \
	\
# https://github.com/moby/buildkit/blob/v0.14.0/frontend/dockerfile/cmd/dockerfile-frontend/Dockerfile#L21
	pkg='github.com/moby/buildkit/frontend/dockerfile/cmd/dockerfile-frontend'; \
	ldflags=" \
		-d -w \
		-X '$pkg/version.Version=buildkit-$BUILDKIT_VERSION-tianon' \
		-X '$pkg/version.Revision=v$BUILDKIT_VERSION+tianon-patches' \
		-X '$pkg/version.Package=$pkg' \
	"; \
	go build -o /dockerfile-frontend -trimpath -ldflags "$ldflags" ./frontend/dockerfile/cmd/dockerfile-frontend

FROM --platform=$TARGETPLATFORM infosiftr/moby

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends git; \
	rm -rf /var/lib/apt/lists/*

COPY --from=build --link /buildkitd /buildctl /dockerfile-frontend /usr/local/bin/
COPY buildkitd-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/buildkit

# https://github.com/docker/buildx/issues/484#issuecomment-749352728
ENV BUILDKIT_STEP_LOG_MAX_SIZE -1
ENV BUILDKIT_STEP_LOG_MAX_SPEED -1

# https://github.com/moby/buildkit/blob/v0.14.0/frontend/gateway/gateway.go#L309
# https://github.com/moby/buildkit/blob/v0.14.0/frontend/dockerfile/cmd/dockerfile-frontend/Dockerfile#L35-L36
LABEL moby.buildkit.frontend.network.none="true"
LABEL moby.buildkit.frontend.caps="moby.buildkit.frontend.inputs,moby.buildkit.frontend.subrequests,moby.buildkit.frontend.contexts"

ENTRYPOINT ["buildkitd-entrypoint.sh"]
CMD []
