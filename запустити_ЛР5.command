#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
echo '=== ЛР5 · Чернівці · варіант 6 · офлайн-знімок BBBike ==='
PYTHON=''
for candidate in python3.12 python3.13 python3.11 python3; do
  if command -v "$candidate" >/dev/null 2>&1 &&
     "$candidate" -c 'import sys; sys.exit(0 if (3, 11) <= sys.version_info[:2] < (3, 14) else 1)' 2>/dev/null; then
    PYTHON="$(command -v "$candidate")";break
  fi
done
if [ -z "$PYTHON" ];then
 echo 'Потрібен Python 3.11–3.13; наприклад brew install python@3.12';exit 1
fi
if [ -x .venv/bin/python ] && ! .venv/bin/python -c   'import sys; sys.exit(0 if (3, 11) <= sys.version_info[:2] < (3, 14) else 1)' 2>/dev/null;then
 echo 'Старе .venv несумісне; створюю нове.';rm -rf .venv
fi
if [ ! -x .venv/bin/python ];then "$PYTHON" -m venv .venv;fi
if ! .venv/bin/python -c 'import osmnx, geopandas, pyarrow, folium, h3, nbconvert, scipy, networkx' 2>/dev/null; then
  echo 'Неповні залежності — встановлюю з requirements_lr5.txt.'
  .venv/bin/python -m pip install -r requirements_lr5.txt
fi
.venv/bin/python підготувати_знімок_ЛР5.py
.venv/bin/python -m ipykernel install --prefix "$(pwd)/.venv" --name lr5-chernivtsi --display-name 'ЛР5 (Чернівці)'
.venv/bin/python -m jupyter nbconvert --execute --to notebook --inplace   --ExecutePreprocessor.timeout=3600 --ExecutePreprocessor.kernel_name=lr5-chernivtsi   'ЛР5_Єдинець_Євген_Чернівці.ipynb'
.venv/bin/python - <<'PY'
from pathlib import Path
import nbformat
p=Path('ЛР5_Єдинець_Євген_Чернівці.ipynb')
n=nbformat.read(p,as_version=4)
for i,c in enumerate(n.cells):
 if c.cell_type=='code':
  assert c.execution_count is not None, f'Не виконана комірка {i}'
  assert not any(o.output_type=='error' for o in c.outputs), f'Помилка в комірці {i}'
for name in ['lr5_результати.json','lr5_маршрут.html','lr5_h3_щільність.png','lr5_звіт.txt']:
 f=Path(name);assert f.is_file() and f.stat().st_size>0,name
 print('OK:',name)
print('ПРОЙДЕНО: усі комірки виконані, ключові файли є.')
PY
