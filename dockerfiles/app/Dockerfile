FROM centos:7

# centos update
# RUN yum update -y
# RUN yum install -y net-tools whtich crontabs vim locales tzdata gdb

RUN  useradd -m -s /bin/bash sunje 
# usradd --help | egrep "m|s"
##   -m, --create-home             create the user's home directory
##   -s, --shell SHELL             login shell of the new account

#COPY .bashrc /home/sunje
#COPY .odbc.ini /home/sunje
COPY *.sh /home/sunje/
COPY ./goldilocks/goldilocks_home /home/sunje/goldilocks_home
COPY ./goldilocks/goldilocks_standard_v1.2 /home/sunje/goldilocks_standard_v1.2
COPY ./bashrc-init /home/sunje/.bashrc

RUN chown -R sunje:sunje /home/sunje/ \
    && mkdir -p /home/sunje/goldilocks_data \
    && chown -R sunje:sunje /home/sunje/goldilocks_home \
    && chown -R sunje:sunje /home/sunje/goldilocks_standard_v1.2 \
    && chown -R sunje:sunje /home/sunje/.bashrc \
    && chmod 777 -R /home/sunje

USER root
RUN echo "root:root" | chpasswd

USER sunje

WORKDIR /home/sunje

ENV GOLDILOCKS_HOST1 192.168.0.72
ENV GOLDILOCKS_HOST2 192.168.0.90
ENV GOLDILOCKS_HOST3 192.168.0.94
ENV GOLDILOCKS_HOST4 192.168.0.93
ENV GOLDILOCKS_HOST5 192.168.0.76
ENV GOLDILOCKS_HOST6 192.168.0.71
ENV GOLDILOCKS_HOST7 192.168.0.78
ENV GOLDILOCKS_HOST8 192.168.0.74




#ENTRYPOINT ["/bin/bash"]
CMD ["./entrypoint.sh"]
