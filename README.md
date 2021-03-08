# myresourcespace

Esecuzione della docker image :

	docker run -d -p 8000:80 -p 2022:22 -v /<folder backup>:/backupdb -v /<folder dati resourcespace>:/var/www/html/filestore myresourcespace
 
