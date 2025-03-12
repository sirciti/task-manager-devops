# task-manager-devops

### Étape 0 : Installation de Terraform

#### Objectifs atteints :
- Installation réussie de Terraform sur Windows.
- Configuration du PATH pour exécuter Terraform depuis n'importe quel répertoire.

#### Difficultés rencontrées :
- Problème avec les permissions administratives lors de l'installation manuelle.
- Solution : Utilisation de Chocolatey pour simplifier le processus.

#### Résultats :
- Terraform installé et fonctionnel : `terraform --version` retourne v1.11.1(de nos jours)


étape suivante : 
Activer le volume pour la persistance
Décommentez la section volumes dans votre configuration main.tf

Problème rencontré et solution :
Lors de la mise en place d'une infrastructure Docker avec Terraform, plusieurs erreurs ont été rencontrées :

Erreur de syntaxe dans le fichier main.tf :

Une virgule manquante ou mal placée dans la liste des variables d'environnement.

Message d'erreur :

text
Error: Missing item separator
Conflit de port avec PostgreSQL :

Le port 5432 était déjà utilisé par un autre processus ou conteneur.

Message d'erreur :

text
Bind for 0.0.0.0:5432 failed: port is already allocated
Problème avec le provider Docker :

La version verrouillée du provider ne correspondait pas à la version spécifiée dans provider.tf.

Message d'erreur :

text
Failed to query available provider packages
Étapes de résolution :
1. Correction de la syntaxe dans main.tf
Problème : Une virgule manquante dans la liste des variables d'environnement.

Solution : Ajout de la virgule manquante après "POSTGRES_DB=mydatabase".

Commandes utilisées pour diagnostiquer et appliquer les corrections :

bash
terraform validate  # Vérifie la syntaxe du fichier Terraform
terraform apply     # Applique les modifications
2. Résolution du conflit de port
Problème : Le port 5432 était déjà utilisé.

Solution : Libération du port en identifiant et supprimant le processus ou conteneur bloquant.

Commandes utilisées :

bash
docker ps -a                     # Liste tous les conteneurs
docker stop postgres_test        # Arrête le conteneur problématique
docker rm postgres_test          # Supprime le conteneur problématique
netstat -ano | findstr :5432     # Identifie les processus utilisant le port
taskkill /PID <PID> /F           # Termine le processus bloquant (Windows)
3. Mise à jour du provider Docker
Problème : Version verrouillée incompatible avec la configuration.

Solution : Mise à jour du provider avec la commande suivante :

bash
terraform init -upgrade          # Met à jour les providers Terraform
terraform apply                  # Applique les modifications
Commandes utilisées pour vérifier le bon fonctionnement
Vérification des conteneurs actifs :

bash
docker ps                       # Liste les conteneurs actifs
Connexion à PostgreSQL :

bash
docker exec -it postgres_server psql -U admin -d mydatabase
Test de Nginx :
Ouvrez http://localhost:8080 dans votre navigateur.

Leçons apprises
Toujours lire attentivement les messages d'erreur pour identifier rapidement la source du problème.

Utiliser des commandes comme terraform validate, docker ps, et netstat pour diagnostiquer efficacement.

Documenter chaque étape pour faciliter la résolution future.

***

## Redémarrage des conteneurs

Pour redémarrer proprement les conteneurs et libérer les ports, exécutez le script suivant :

./restart_containers.sh

Cela garantit que les conteneurs sont arrêtés proprement avant d'être relancés.
Avantages :
Automatisation simple et efficace.

Évite les conflits de ports.

Préserve la persistance des données grâce aux volumes Docker.

pour la phase de mise en place et de test, ce script est pratique et adapté.

Mise à jour du README.md pour documenter la vérification de PostgreSQL :

## Vérification des données PostgreSQL

Pour vérifier que les données sont bien persistées après le redémarrage des conteneurs :

1. Connectez-vous à PostgreSQL :
docker exec -it task-manager-devops-postgres-1 psql -U admin -d mydatabase


2. Exécutez la commande SQL suivante pour afficher les données de la table `test_table` :
SELECT * FROM test_table;


Vous devriez voir les données suivantes si tout fonctionne correctement :
id | name
----+---------
1 | Alice
2 | Bob
3 | Charlie
(3 rows)

Étapes de test pour confirmer que tout fonctionne avec la nouvelle commande down && up et la persistance des données :
Redémarrer les conteneurs avec la commande :


./restart_containers.sh
Vérifier l'état des conteneurs :


docker ps
Assurez-vous que les conteneurs PostgreSQL et Nginx sont actifs et que les ports sont correctement mappés.

Tester la persistance des données PostgreSQL :

Connectez-vous à PostgreSQL :


docker exec -it task-manager-devops-postgres-1 psql -U admin -d mydatabase
Exécutez la commande SQL pour vérifier les données :


SELECT * FROM test_table;
Vous devriez voir les données précédemment insérées (Alice, Bob, Charlie).

Tester l'accès à Nginx :

Accédez à http://localhost:8080 dans votre navigateur.

Vérifiez que la page personnalisée s'affiche correctement.

Confirmer les logs et erreurs (optionnel) :

Vérifiez les logs de PostgreSQL et Nginx pour vous assurer qu'il n'y a pas d'erreurs :


docker logs task-manager-devops-postgres-1
docker logs task-manager-devops-nginx-1
Résultat attendu :
Les données dans PostgreSQL sont persistantes après le redémarrage.

La page Nginx est accessible sans erreur.

à ce niveau 
Si tout est correct, vous pouvez considérer votre configuration comme validée !


Documentation des étapes et résolution des problèmes
1. Mise en place initiale
Configuration des services Docker avec docker-compose.yml :

Nginx : Pour servir du contenu statique.

PostgreSQL : Pour la base de données.

Création des volumes pour la persistance des données.

2. Problèmes rencontrés
Problème 1 : Permissions sur le volume PostgreSQL sous Windows
Message d'erreur :

chmod: changing permissions of '/var/lib/postgresql/data/pgdata': Operation not permitted
Cause : Conflit de permissions entre le système de fichiers Windows et Docker.

Solution :

Remplacement du montage local par un volume nommé dans docker-compose.yml :


volumes:
  - postgres_data:/var/lib/postgresql/data
Problème 2 : Table manquante dans PostgreSQL
Message d'erreur :


ERROR: relation "test_table" does not exist
Cause : La table test_table n'avait pas encore été créée.

Solution : Création manuelle de la table et insertion des données :


docker exec -it task-manager-devops-postgres-1 psql -U admin -d mydatabase
Dans la console PostgreSQL :


CREATE TABLE test_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);
INSERT INTO test_table (name) VALUES ('Alice'), ('Bob'), ('Charlie');
3. Commandes utilisées pour diagnostiquer et résoudre les problèmes
Vérification des conteneurs actifs :

docker ps
Logs des conteneurs pour identifier les erreurs :

docker logs <container_name>
Accès à PostgreSQL pour exécuter des commandes SQL :

docker exec -it task-manager-devops-postgres-1 psql -U admin -d mydatabase
Suppression des volumes problématiques :

rm -rf ./data/postgres/*
docker-compose down -v && docker-compose up -d
4. Automatisation et sécurisation
Ajout d'un pipeline CI/CD avec GitHub Actions pour automatiser les tests et le déploiement.

Sécurisation des variables sensibles avec un fichier .env :


POSTGRES_USER=admin
POSTGRES_PASSWORD=admin123
POSTGRES_DB=mydatabase