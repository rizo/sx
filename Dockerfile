FROM ocaml/opam:alpine-ocaml-5.3 AS build
RUN sudo ln -f /usr/bin/opam-2.1 /usr/bin/opam
RUN cd ~/opam-repository \
  && git pull origin master \
  && git reset --hard 11a53009bd75423d805636ff9384bf7cce8b0a9a \
  && opam update

WORKDIR /mnt/build

# install deps
COPY ./onix.opam.locked /mnt/build/onix.opam
RUN opam install . --deps-only --yes

# copy the build context and build the app
COPY . /mnt/build/
RUN opam exec -- dune build --profile=static

# install all public targets
RUN mkdir -p /home/opam/export
RUN opam exec -- dune install --prefix=/home/opam/export


FROM alpine:3.19.1
WORKDIR /opt/sx
COPY --from=build /home/opam/export/bin /opt/sx/bin
ENV PATH="/opt/sx/bin:${PATH}"
