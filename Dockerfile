FROM quay.io/pypa/manylinux2010_x86_64

ENV PLAT=manylinux2010_x86_64\
    PYTHONDONTWRITEBYTECODE=1

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
