A Ruby docker image that create sockets for common mysql socket 
locations to TCP address `db:3306`.  

This means you must have this container on the same docker network
as your mysql/mariadb container, and that container is accessible
using the DNS hostname `db`.  
