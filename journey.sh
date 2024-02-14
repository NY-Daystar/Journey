#!/bin/bash

# Nom du dépôt sur Docker Hub
REPOSITORY="castimaging"

# TODO faire une lecture du repository
# TODO faire un fichier de config
# TODO proposer une option pour pull si besoin + retag
# TODO commentaire en anglais
# TODO dans la liste des tags prendre le plus recent qui n'est pas latest
#    - Mettre en option si on veut que le dernier ou tous les autres
# TODO ajouter les fonctions par defaut (log, option etc...)

function main() {
    # Récupérer les dernières images
    images=$(get_repository_images)
    echo "${images}"

    echo "Les derniers tags des images Docker (hors 'latest') du dépôt ${REPOSITORY} :"

    for image in $images; do
        echo "Tags pour l'image ${REPOSITORY}:${image} :"
        first_tag=$(get_image_tags "${image}")
        echo "Premier tag pour l'image ${REPOSITORY}:${image} : ${first_tag}"
    done

}

get_repository_images() {
    curl -sS "https://hub.docker.com/v2/repositories/${REPOSITORY}?page_size=25&ordering=last_updated" |
        grep -Po '"name":.*?[^\\]",' |
        awk -F'"' '$2 != "latest" {print $4}'
}

# Fonction pour récupérer le dernier tag d'une image
function get_image_tags() {
    image="$1"
    echo "Tags pour l'image ${REPOSITORY}:${image} :"
    curl -sS "https://registry.hub.docker.com/v2/repositories/${REPOSITORY}/${image}/tags/?page_size=10" |
        grep -Po '"name":.*?[^\\]",' |
        awk -F'"' '{print $4}'
    echo "--------------"
}

function pull() {
    echo test
}

function retag() {
    echo test
}

main $@
