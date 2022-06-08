FROM quay.io/pypa/manylinux2014_s390x

ENV PLAT manylinux2014_s390x\
    PYTHONDONTWRITEBYTECODE=1

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
