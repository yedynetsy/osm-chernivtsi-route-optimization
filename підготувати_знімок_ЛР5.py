#!/usr/bin/env python3
"""Convert the bundled BBBike GeoPackage layers to GeoParquet for this notebook.
Offline operation; all input layers were derived from user-supplied OSM XML.
"""
import json
from pathlib import Path
import geopandas as gpd

root=Path(__file__).resolve().parent
out=root/'osm_чернівці';out.mkdir(exist_ok=True)
src=root/'знімок_BBBike'
for layer in ['boundary','heritage','stations','amenities','road_nodes','road_edges']:
    source=src/(layer+'.gpkg');assert source.is_file(), f'Не знайдено {source}'
    g=gpd.read_file(source,layer=layer)
    assert len(g)>0 and g.crs is not None,layer
    if layer=='road_nodes':assert {'osmid','x','y'}.issubset(g.columns)
    if layer=='road_edges':assert {'u','v','length'}.issubset(g.columns)
    dest=out/(layer+'.parquet');g.to_parquet(dest,index=False)
    check=gpd.read_parquet(dest)
    assert len(check)==len(g) and check.crs==g.crs,(layer,len(g),len(check))
    print(f'{layer:12s}: {len(g):>7} записів; {dest.stat().st_size/1e6:.2f} МБ',flush=True)
manifest=json.loads((src/'manifest_джерела.json').read_text('utf8'))
(out/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf8')
print('Готово. Дані взяті з локального OSM-знімка, запитів Overpass не було.')
