FROM centos:7
RUN yum -y update 
RUN yum install -y \
  epel-release \
  make \
  mlocate \
  which \
  gnuplot \
  gcc \
  gcc-c++ \
  git \
  libaio-devel \
  libaio \
  eog \
  python-devel
RUN yum install -y  python-pip 

#RUN mkdir -p /iotest/work && chmod 777 /iotest/work && mkdir -p /iotest/jobs && chmod 777 /iotest/jobs && mkdir -p /iotest/fio && chmod 777 /iotest/fio
WORKDIR /iotest
ADD iotest.tar /
RUN chmod -R 777 /iotest
#RUN mkdir /nfs1/job_output && chmod 777 /nfs1/job_output

RUN pip install -U six

WORKDIR /tmp/build
RUN git clone https://github.com/axboe/fio.git
WORKDIR /tmp/build/fio
RUN ./configure && make && make install

RUN pip install -U cython

RUN pip install -U QtGui

RUN yum install -y python-qt4

WORKDIR /tmp/build
RUN git clone https://github.com/pyqtgraph/pyqtgraph.git
WORKDIR /tmp/build/pyqtgraph
RUN python setup.py build
RUN python setup.py install



RUN mkdir -p /fio_visualizer && chmod 777 /fio_visualizer
WORKDIR /fio_visualizer
RUN git clone https://github.com/01org/fiovisualizer

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vnc
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

### Install firefox
RUN $INST_SCRIPTS/firefox.sh

### Install xfce UI
RUN $INST_SCRIPTS/xfce_ui.sh
ADD ./src/common/xfce/ $HOME/

### configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD ./src/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

#WORKDIR /iotest
#ADD jobs/* /iotest/jobs/ 
#ADD fio/* /iotest/fio/

#USER 0

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]

