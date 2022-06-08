FROM quay.io/pypa/manylinux_2_24_x86_64

ENV PLAT manylinux_2_24_x86_64\
    PYTHONDONTWRITEBYTECODE=1

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
