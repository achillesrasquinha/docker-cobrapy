FROM alpine:latest

ENV GLPK_VERSION="4.65" \
	OPENBLAS_VERSION="0.3.7"

RUN set -o errexit -o nounset \
	\
	&& echo "Installing dependencies" \
	\
	&& apk add --no-cache \
		bash \
		gcc \
		g++ \
		make \
		linux-headers \
		musl-dev \
		python3-dev \
		py3-pip \
		swig \
		gfortran \
		perl \
	\
	&& echo "Fetching GLPK (Version "$GLPK_VERSION")" \
	\
	&& wget -O /glpk-"$GLPK_VERSION".tar.gz ftp://ftp.gnu.org/gnu/glpk/glpk-"$GLPK_VERSION".tar.gz \
	&& tar -xzvf /glpk-"$GLPK_VERSION".tar.gz -C / \
	&& cd /glpk-"$GLPK_VERSION" \
	&& ./configure \
	&& echo "Installing Constraint-Based-Modelling Parser" \
	&& make install \
	&& rm -rf /glpk-"$GLPK_VERSION"* \
	\
	echo "Fetching OpenBLAS (Version "$OPENBLAS_VERSION")" \
	\
	&& wget -O /OpenBLAS-"$OPENBLAS_VERSION".tar.gz https://github.com/xianyi/OpenBLAS/archive/v"$OPENBLAS_VERSION".tar.gz \
	&& tar -xzvf /OpenBLAS-"$OPENBLAS_VERSION".tar.gz -C / \
	&& cd /OpenBLAS-"$OPENBLAS_VERSION" \
	&& echo "Installing OpenBLAS" \
	&& make BINARY=64 FC=$(which gfortran) USE_THREAD=1 \
	&& make PREFIX=/usr/lib/openblas install \
	&& rm -rf /OpenBLAS-"$OPENBLAS_VERSION"*

# RUN export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib/openblas/lib/

# RUN pip3 install Cython numpy
# RUN ATLAS=/usr/lib/openblas/lib/libopenblas.so LAPACK=/usr/lib/openblas/lib/libopenblas.so pip3 install scipy

# RUN pip3 install scipy
RUN pip3 install Cython

RUN pip3 install cobra

COPY ./entrypoint /entrypoint
RUN sed -i 's/\r//' /entrypoint \
	&& chmod +x /entrypoint

COPY ./start /start
RUN sed -i 's/\r//' /start \
	&& chmod +x /start

ENTRYPOINT ["/entrypoint"]

CMD ["/start"]