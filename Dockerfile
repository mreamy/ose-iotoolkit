FROM centos
RUN yum -y update 
RUN yum install -y epel-release
RUN yum install -y python-pip
RUN yum install -y make
RUN yum install -y mlocate
RUN yum install -y which
RUN yum install -y gnuplot
RUN yum install -y gcc
RUN yum install -y gcc-c++
RUN yum install -y git
RUN yum install -y libaio-devel
RUN yum install -y libaio
RUN yum install -y zlib
RUN yum install -y zlib-devel

RUN mkdir -p /iotest/work && chmod 777 /iotest/work && mkdir -p /iotest/jobs && chmod 777 /iotest/jobs
RUN pip install -U six

WORKDIR /tmp/build
RUN git clone https://github.com/axboe/fio.git
WORKDIR /tmp/build/fio
RUN ./configure && make && make install

WORKDIR /tmp/build
RUN git clone https://github.com/pyqtgraph/pyqtgraph.git
WORKDIR /tmp/build/pyqtgraph
RUN python setup.py install


WORKDIR /tmp/build
RUN git clone https://github.com/cython/cython.git
WORKDIR /tmp/build/cython
#RUN python setup.py install

WORKDIR /tmp/build
RUN git clone https://github.com/numpy/numpy.git
WORKDIR /tmp/build/numpy
RUN python setup.py build
RUN python setup.py install

WORKDIR /tmp/build
RUN git clone https://github.com/axboe/fio.git
WORKDIR /tmp/build/fio
RUN ./configure && make && make install

WORKDIR /tmp/build
RUN git clone https://github.com/01org/fiovisualizer
WORKDIR /tmp/build/fiovisualizer
RUN python setup.py install

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $VNC_PORT $NO_VNC_PORT

### Envrionment config
ENV HOME=/headless \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    NO_VNC_HOME=/headless/noVNC \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1920x1080 \
    VNC_PW=vnc \
    VNC_VIEW_ONLY=false
WORKDIR $HOME

### Add all install scripts for further steps
ADD ./src/common/install/ $INST_SCRIPTS/
ADD ./src/centos/install/ $INST_SCRIPTS/
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +

### Install some common tools
RUN $INST_SCRIPTS/tools.sh
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN $INST_SCRIPTS/tigervnc.sh
RUN $INST_SCRIPTS/no_vnc.sh

### Install firefox and chrome browser
RUN $INST_SCRIPTS/firefox.sh
# RUN $INST_SCRIPTS/chrome.sh

### Install xfce UI
RUN $INST_SCRIPTS/xfce_ui.sh
ADD ./src/common/xfce/ $HOME/

### configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD ./src/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

USER 1000

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]

WORKDIR /iotest
ADD jobs/* /iotest/jobs/
VOLUME /iotest/work
#CMD fio iometer-file-access-server.fio
#CMD ["/bin/bash"]
