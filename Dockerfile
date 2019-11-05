FROM artifactory.int.8451.com:1338/agatha/feature-registry/base-flask:1.0.5
 
USER root
ARG SPMID=3900
LABEL com.kroger.gcp.spmid=${SPMID}
ARG DEBUG=0
ARG IMAGE_VERSION=0.0.1
ENV IMAGE_VERSION=${IMAGE_VERSION}
ARG KIND=master
ENV KIND=${KIND}
ARG REDIS_URL=redis://:admin123@ds-redis:6380/0
ENV REDIS_URL=${REDIS_URL}
ARG REDIS_WORK_QUEUE=feature-registry
ENV REDIS_WORK_QUEUE=${REDIS_WORK_QUEUE}
ARG APP_GIT_HASH
ENV APP_GIT_HASH=${APP_GIT_HASH}
ENV GU_WORKER_CLASS="tornado"
ENV GU_WORKER_COUNT=1
ENV GU_BIND_PORT=5000
ENV GU_BIND_ADDRESS="0.0.0.0"
ARG GU_APP_PATH="${APP_PATH}/frapp"
ENV GU_APP_PATH="${GU_APP_PATH}"
ENV FLASK_APP="run:frapp"
ENV PYTHONPATH="${PYTHONPATH}:${GU_APP_PATH}:/"
RUN mkdir -p ${APP_PATH} \
&& chown ${AGATHA_USER}:${AGATHA_GROUP} ${APP_PATH}
RUN if [ ${DEBUG} -eq 1 ]; then echo "#### OS VERSION ####\n$(cat /etc/os-release)"; fi
RUN if [ ${DEBUG} -eq 1 ]; then echo ${APP_PATH}; fi
COPY . ${APP_PATH}
# Deploy utility files for app management
COPY docker_files/*.py ${GU_APP_PATH}/
COPY docker_files/*.sh ${GU_APP_PATH}/
RUN chmod +x ${GU_APP_PATH}/*.sh ${GU_APP_PATH}/*.py
RUN if [ ${DEBUG} -eq 1 ]; then echo $(ls ${GU_APP_PATH}); fi
# Install app python dependencies
RUN pip install --no-cache-dir -r ${APP_PATH}/requirements.txt
RUN chown -R ${AGATHA_USER}:${AGATHA_GROUP} ${GU_APP_PATH}
USER ${AGATHA_USER}
WORKDIR ${GU_APP_PATH}
ENTRYPOINT ["./entrypoint.sh"]
