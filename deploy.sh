mkdir -p data/cloud-connector data/inde-self config/cloud-connector config/inde-self
chown -R 993:993 data/cloud-connector data/inde-self config/cloud-connector config/inde-self
docker-compose up -d 

#docker volume create portainer_data
#docker run -d -p 8000:8000 -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
