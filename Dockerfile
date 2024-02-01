FROM busybox:uclibc

WORKDIR /

COPY --chmod=0755 sedsubst.sh /bin/sedsubst

RUN ln -s /bin/sedsubst /bin/envsubst
