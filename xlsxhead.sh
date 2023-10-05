#!/bin/bash

file=$1

python -c "import pandas as pd; print(pd.read_excel('"$1"').head())"
