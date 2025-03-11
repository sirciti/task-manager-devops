#!/bin/bash

echo "Arrêt des conteneurs existants..."
docker-compose down

echo "Redémarrage des conteneurs..."
docker-compose up -d

echo "Vérification des conteneurs actifs..."
docker ps
