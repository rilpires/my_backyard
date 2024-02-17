FROM node:20.10.0-bullseye-slim

RUN apt update
RUN apt install wget -y
RUN apt install unzip -y

ARG GODOT_VERSION=3.5
WORKDIR /app

COPY ./node_server/package.json /app/node_server/package.json
COPY ./node_server/package-lock.json /app/node_server/package-lock.json
COPY ./node_server/node_server.js /app/node_server/node_server.js

# Not building godot, built it outside docker...
# COPY ./Resources /app/Resources
# COPY ./Scenes /app/Scenes
# COPY ./Scripts /app/Scripts
# COPY [ "./Blender Files/", "/app/Blender Files/" ]
# COPY ./project.godot /app/project.godot
# COPY ./export_presets.cfg /app/export_presets.cfg
# COPY ./icon.png /app/icon.png
# COPY ./default_env.tres /app/default_env.tres
COPY ./dist /app/dist

WORKDIR /app/node_server
RUN npm install

WORKDIR /app


EXPOSE 80

CMD [ "node", "node_server/node_server.js" ]
