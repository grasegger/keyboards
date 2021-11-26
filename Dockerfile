FROM productize/kicad-automation-base:latest

COPY bin/* /usr/local/bin
RUN mkdir -p ~/.kicad/scripting/plugins \
    cd ~/.kicad/scripting/plugins \
    git clone https://github.com/asukiaaa/gerber_to_order.git

RUN chmod -R +x /usr/local/bin; mkdir -p /src
WORKDIR /src
CMD true