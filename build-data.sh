#!/usr/bin/bash

set -e

#curl "https://opendata.agenceore.fr/api/explore/v2.1/catalog/datasets/reseau-souterrain-basse-tension-bt/exports/geojson?lang=fr&timezone=Europe%2FBerlin" | gzip > bt-souterraines.geojson.gz
#curl "https://opendata.agenceore.fr/api/explore/v2.1/catalog/datasets/reseau-aerien-basse-tension-bt/exports/geojson?lang=fr&timezone=Europe%2FBerlin" | gzip > bt-aeriennes.geojson.gz
#curl "https://opendata.agenceore.fr/api/explore/v2.1/catalog/datasets/reseau-aerien-moyenne-tension-hta/exports/geojson?lang=fr&timezone=Europe%2FBerlin" | gzip > ht-aeriennes.geojson.gz
#curl "https://opendata.agenceore.fr/api/explore/v2.1/catalog/datasets/reseau-souterrain-moyenne-tension-hta/exports/geojson?lang=fr&timezone=Europe%2FBerlin" | gzip > ht-souterraines.geojson.gz
#curl "https://opendata.agenceore.fr/api/explore/v2.1/catalog/datasets/postes-source/exports/geojson?lang=fr&timezone=Europe%2FBerlin" | gzip > poste-repartition.geojson.gz
#curl "https://opendata.agenceore.fr/api/explore/v2.1/catalog/datasets/postes-de-distribution-publique-postes-htabt/exports/geojson?lang=fr&timezone=Europe%2FBerlin" | gzip > poste-distribution.geojson.gz

#zcat ht-aeriennes.geojson.gz | jq -c '.features[] | {type: .type, geometry: .geometry, properties: {nom_grd: .properties.nom_grd}}' | gzip > ht-aeriennes.geojsonnld.gz
#zcat ht-souterraines.geojson.gz | cut -c 41- | head -c-3 | sed "s/},{/}\n{/g" |  jq -c '{type: .type, geometry: .geometry, properties: {nom_grd: .properties.nom_grd}}' | gzip > ht-souterraines.geojsonnld.gz
#zcat bt-souterraines.geojson.gz | cut -c 41- | head -c-3 | tr '"' "\n" | sed "s/},{/}#{/g" | tr "\n" '"' | tr "#" "\n" | jq -c '{type: .type, geometry: .geometry, properties: {nom_grd: .properties.nom_grd}}' | gzip > bt-souterraines.geojsonnld.gz
#zcat bt-aeriennes.geojson.gz | cut -c 41- | head -c-3 | tr '"' "\n" | sed "s/},{/}#{/g" | tr "\n" '"' | tr "#" "\n" | jq -c '{type: .type, geometry: .geometry, properties: {nom_grd: .properties.nom_grd}}' | gzip > bt-aeriennes.geojsonnld.gz
#zcat poste-repartition.geojson.gz | jq -c '.features[] | {type: .type, geometry: .geometry, properties: {nom_grd: .properties.nom_grd, nom_ps: .properties.nom_ps}}' | gzip > poste-repartition.geojsonnld.gz
#zcat poste-distribution.geojson.gz | jq -c '.features[] | {type: .type, geometry: .geometry, properties: {nom_grd: .properties.nom_grd, nom_ps: .properties.nom_ps}}' | gzip > poste-distribution.geojsonnld.gz

docker run --rm -it -v `pwd`:/data --entrypoint /bin/sh morlov/tippecanoe:latest -c '
cd /data
tippecanoe -o ht-aeriennes.mbtiles -Z8 -z13 --read-parallel --coalesce-densest-as-needed --coalesce --layer=hta ht-aeriennes.geojsonnld.gz
tippecanoe -o ht-souterraines.mbtiles -Z8 -z13 --read-parallel --coalesce-densest-as-needed --coalesce --layer=hts ht-souterraines.geojsonnld.gz
tippecanoe -o bt-aeriennes.mbtiles -Z13 -z13 --read-parallel --coalesce-densest-as-needed --coalesce --layer=bta bt-aeriennes.geojsonnld.gz
tippecanoe -o bt-souterraines.mbtiles -Z13 -z13 --read-parallel --coalesce-densest-as-needed --coalesce --layer=bts bt-souterraines.geojsonnld.gz
tippecanoe -o poste-repartition.mbtiles -Z5 -z13 --read-parallel --coalesce-densest-as-needed --layer=poste-repartition poste-repartition.geojsonnld.gz
tippecanoe -o poste-distribution.mbtiles -Z8 -z13 --read-parallel --coalesce-densest-as-needed --layer=poste-distribution poste-distribution.geojsonnld.gz
tile-join -o ampere.mbtiles --name="Ampère" --attribution="INSEE IGN NaturalEarth DGCL - BANATIC MEFR MAA, INSEE IGN OFGL, INSEE I GN NaturalEarth DGGL, INSEE IGN NaturalEarth" *-*.mbtiles
'
