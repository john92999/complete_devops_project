docker networking
########################################################################################################

`docker pull mongo:4.4.6`
`docker run -e MONGO_INITDB_ROOT_USERNAME=root -e MONGO_INITDB_ROOT_PASSWORD=password -p 27017:27017 -d mongo:4.4.6`

#Mongo express is web based to connect to Mongo DB
##########################################################################################################

`docker run -e ME_CONFIG_MONGODB_ADMINUSER=root -e ME_CONFIG_MONGODB_ADMINPASSWORD=password -e ME_CONFIG_MONGODB_SERVER=192.168.31.26 -p 9020:8081 -d --name mongo-web mongo-express`

but it won't connect to DB. To view the logs run `docker logs <container-id>`

if we try to use node ip address in MONGODB_SERVER it won't work, we need to use container ip address to view the ip address of container we need to run `docker inspect <container-id> | grep IPAddress`

`docker run -e ME_CONFIG_MONGODB_ADMINUSER=root -e ME_CONFIG_MONGODB_ADMINPASSWORD=password -e ME_CONFIG_MONGODB_SERVER=172.17.0.3 -p 9020:8081 -d --name mongo-web mongo-express`
