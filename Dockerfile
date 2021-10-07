FROM cm2network/steamcmd:root

ENV STEAMAPPID 740 
ENV STEAMAPP csgo 
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated" 
ENV CUSTOM_CONFIG_DIR "${HOMEDIR}/custom-config" 
ENV SERVE_DIR "${HOMEDIR}/serve" 
ENV METAMOD_VERSION 1.11 
ENV SOURCEMOD_VERSION 1.11

ENV SRCDS_FPSMAX=300 \
	SRCDS_TICKRATE=128 \
	SRCDS_PORT=27015 \
	SRCDS_TV_PORT=27020 \
	SRCDS_CLIENT_PORT=27005 \
	SRCDS_NET_PUBLIC_ADDRESS="0" \
	SRCDS_IP="0" \
	SRCDS_MAXPLAYERS=14 \
	SRCDS_TOKEN=0 \
	SRCDS_STARTMAP="de_dust2" \
	SRCDS_REGION=3 \
	SRCDS_MAPGROUP="mg_active" \
	SRCDS_GAMETYPE=0 \
	SRCDS_GAMEMODE=1 \
	SRCDS_HOSTNAME="New \"${STEAMAPP}\" Server" \
	SRCDS_WORKSHOP_START_MAP=0 \
	SRCDS_HOST_WORKSHOP_COLLECTION=0 \
	SRCDS_WORKSHOP_AUTHKEY="" \
	ADDITIONAL_ARGS=""

COPY entry.sh "${HOMEDIR}/"

# set -x will print all commands to terminal
RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		wget=1.20.1-1.1 \
		ca-certificates=20200601~deb10u2 \
		lib32z1=1:1.2.11.dfsg-1 \
	&& mkdir -p "${STEAMAPPDIR}" \
	&& mkdir -p "${CUSTOM_CONFIG_DIR}" \
	&& mkdir -m 755 -p "${SERVE_DIR}" \
	&& { \
		echo '@ShutdownOnFailedCommand 1'; \
		echo '@NoPromptForPassword 1'; \
		echo 'login anonymous'; \
		echo 'force_install_dir '"${STEAMAPPDIR}"''; \
		echo 'app_update '"${STEAMAPPID}"''; \
		echo 'quit'; \
	   } > "${HOMEDIR}/${STEAMAPP}_update.txt" \
	&& chmod +x "${HOMEDIR}/entry.sh" \
	&& chown -R "${USER}:${USER}" "${HOMEDIR}/entry.sh" "${STEAMAPPDIR}" "${HOMEDIR}/${STEAMAPP}_update.txt" \	
	&& rm -rf /var/lib/apt/lists/* 

USER ${USER}

VOLUME ${STEAMAPPDIR}
VOLUME ${CUSTOM_CONFIG_DIR}

WORKDIR ${HOMEDIR}

CMD ["bash", "entry.sh"]
# Expose ports
EXPOSE 27015/tcp \
	27015/udp \
	27020/udp