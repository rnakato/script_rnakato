#! /usr/bin/env python
# -*- coding: utf-8 -*- 
import numpy as np

#自分で定義したカラーマップを返す
# https://qiita.com/kenmatsu4/items/fe8a2f1c34c8d5676df8
def generate_cmap(colors):
    from matplotlib.colors import LinearSegmentedColormap
    values = range(len(colors))

    vmax = np.ceil(np.max(values))
    color_list = []
    for v, c in zip(values, colors):
        color_list.append( ( v/ vmax, c) )
    return LinearSegmentedColormap.from_list('custom_cmap', color_list)
