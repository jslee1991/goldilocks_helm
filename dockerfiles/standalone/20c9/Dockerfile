FROM centos:7

# centos update
RUN yum update -y
RUN yum install -y net-tools whtich crontabs vim locales tzdata gdb

RUN  useradd -m -s /bin/bash sunje 
# usradd --help | egrep "m|s"
##   -m, --create-home             create the user's home directory
##   -s, --shell SHELL             login shell of the new account

#COPY .bashrc /home/sunje
#COPY .odbc.ini /home/sunje
COPY *.sh /home/sunje/
COPY ./goldilocks/goldilocks_home /home/sunje/goldilocks_home
COPY ./goldilocks/goldilocks_data /home/sunje/goldilocks_data_create

RUN chown -R sunje:sunje /home/sunje/ \
    && mkdir -p /home/sunje/nfs_volumn \
    && mkdir -p /home/sunje/goldilocks_data \
    && chown -R sunje:sunje /home/sunje/nfs_volumn \
    && chown -R sunje:sunje /home/sunje/goldilocks_home \
    && chown -R sunje:sunje /home/sunje/goldilocks_data \
    && chmod 777 -R /home/sunje

USER root
RUN echo "root:root" | chpasswd

USER sunje

WORKDIR /home/sunje

#ENV SERVICE_ACCOUNT=edu
#ENV SERVICE_ACCOUNT_PASSWD=ktedu
#ENV CREATE_TABLE_QUERY="CREATE TABLE TEST (C1 INT PRIMARY KEY)"

ENTRYPOINT ["/bin/bash"]
CMD ["./entrypoint.sh"]
