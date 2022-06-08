FROM quay.io/pypa/manylinux_2_24_ppc64le

ENV PLAT manylinux_2_24_ppc64le\
    PYTHONDONTWRITEBYTECODE=1

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
