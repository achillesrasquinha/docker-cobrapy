FROM python:3.7-alpine

ENV GLPK_VERSION="4.65"

RUN set -o errexit -o nounset \
	\
	&& echo "Installing dependencies" \
	\
	&& apk add --no-cache \
		bash \
		gcc \
		g++ \
		make \
		python3-dev \
		py3-pip \
		swig \
	\
	&& echo "Fetching GLPK (Version "$GLPK_VERSION")" \
	\
	&& wget -O /glpk-"$GLPK_VERSION".tar.gz ftp://ftp.gnu.org/gnu/glpk/glpk-"$GLPK_VERSION".tar.gz \
	&& tar -xzvf /glpk-"$GLPK_VERSION".tar.gz -C / \
	&& cd /glpk-"$GLPK_VERSION" \
	&& ./configure \
	&& echo "Installing Constraint-Based-Modelling Parser" \
	&& make install \
	&& rm -rf /glpk-"$GLPK_VERSION"*

COPY ./requirements.txt /requirements.txt

RUN pip install -r /requirements.txt

RUN pip install cobra

COPY ./entrypoint /entrypoint
RUN sed -i 's/\r//' /entrypoint \
	&& chmod +x /entrypoint

COPY ./start /start
RUN sed -i 's/\r//' /start \
	&& chmod +x /start

ENTRYPOINT ["/entrypoint"]

CMD ["/start"]
