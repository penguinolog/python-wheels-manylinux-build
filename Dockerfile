FROM quay.io/pypa/manylinux1_x86_64

ENV PLAT manylinux1_x86_64\
    PYTHONDONTWRITEBYTECODE=1

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
