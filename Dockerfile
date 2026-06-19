
FROM node:19.5.0-alpine
#

# Craer el directorio de la app
WORKDIR /usr/src/app
#

# Instalación de las dependencias
COPY ./src/package*.json ./
#

# Instalar las dpeendencias 
RUN npm install
#

# Ahora instalar el fuente (copia lo del directorio actual al direcetorio actual (el app))
COPY ./src .
#

EXPOSE 3000
#

CMD [ "npm", "start" ]