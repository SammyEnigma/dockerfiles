FROM alpine:3.14

# https://www.speedtest.net/apps/cli#download
ENV SPEEDTEST_VERSION 1.0.0

RUN set -eux; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64 | aarch64 | armhf) ooklaArch="$apkArch" ;; \
		x86) ooklaArch='i386' ;; \
# Ookla's "armhf" is armv6 (just like Alpine's), which is fair game for ARMv7 devices
		armv7) ooklaArch='armhf' ;; \
# Ookla's bare "arm" arch is armv5, which Alpine doesn't support :(
		*) echo >&2 "error: unknown/unsupported architecture: $apkArch (see https://www.speedtest.net/apps/cli#download)"; exit 1 ;; \
	esac; \
	wget -O speedtest.tgz "https://install.speedtest.net/app/cli/ookla-speedtest-$SPEEDTEST_VERSION-$ooklaArch-linux.tgz"; \
	tar -xvf speedtest.tgz -C /usr/local/bin speedtest; \
	rm speedtest.tgz; \
	speedtest --version

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["speedtest"]
