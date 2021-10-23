FROM alpine:edge

RUN apk add --no-cache git build-base python3-dev py3-pip openjdk11 linux-headers wget unzip x11vnc py3-numpy py3-lxml imagemagick-libs py3-yaml subversion py3-psutil xvfb recordmydesktop xdotool gnome xdpyinfo npm openssh
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing kicad py3-pybars3
RUN pip install --no-compile kibot kiauto pcbdraw svg2mod
RUN svn co svn://svn.repo.hu/freerouting_cli/trunk && cd trunk && make && make install && cd .. && rm -rf trunk
RUN mkdir -p ~/.kicad/scripting/plugins && \
    cd ~/.kicad/scripting/plugins && \
    git clone https://github.com/asukiaaa/gerber_to_order.git

CMD cd mount \
    && make export
