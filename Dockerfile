FROM quay.io/pypa/manylinux2010_i686

ENV PLAT=manylinux2010_i686\
    PYTHONDONTWRITEBYTECODE=1

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
