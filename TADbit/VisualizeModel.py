# -*- coding: utf-8 -*-
import os
from pytadbit import Chromosome
from pytadbit import load_chromosome
from pytadbit.modelling.structuralmodels import load_structuralmodels

pwd=os.path.dirname(os.path.abspath(__file__))

# load data
models = load_structuralmodels('TADbit/tutorial.k562.models')

models.view_models(stress='centroid', tool='plot', figsize=(10,10), azimuth=-60, elevation=100)

# TADなし
models.view_models(highlight='centroid', show='highlighted', tool='plot', figsize=(10,10), azimuth=-60, elevation=100)

# TADあり
models.view_models(highlight='centroid', show='highlighted', tool='plot', figsize=(10,10), azimuth=-60, elevation=100, color='tad')
models.view_models(highlight='centroid', show='highlighted', tool='plot', figsize=(10,10), azimuth=-60, elevation=100, color='border')

# Generate the image using Chimera in batch mode. That takes some time, wait a bit before running next command.
# You can check in your home directory whether this has finished.
#models.view_models(models=[0], tool='chimera_nogui', savefig='/tmp/image_model_1.png')

models.view_models(models=[0], tool = '/home/rnakato/.local/UCSF-Chimera64-1.11.2/bin/chimera --nogui --silent',
                   savefig = pwd + '/TADbit/image_model_1.png')

models.view_models(models=[0], tool = '/home/rnakato/.local/UCSF-Chimera64-1.11.2/bin/chimera',
                   savefig = pwd + '/TADbit/image_model_1.webm')
