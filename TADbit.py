from pytadbit import Chromosome

# initiate a chromosome object that will store all Hi-C data and analysis
my_chrom = Chromosome(name='chr19', centromere_search=True,
                      species='Homo sapiens', assembly='NCBI36')

# load Hi-C data
my_chrom.add_experiment('k562', cell_type='wild type', exp_type='Hi-C', identifier='k562',
                        project='TADbit tutorial',
                        hic_data="scripts/sample_data/HIC_k562_chr19_chr19_100000_obs.txt", resolution=100000)
my_chrom.add_experiment('gm06690',  cell_type='cancer', exp_type='Hi-C', identifier='gm06690',
                        project='TADbit tutorial',
                        hic_data="scripts/sample_data/HIC_gm06690_chr19_chr19_100000_obs.txt", resolution=100000)

my_chrom.experiments

my_chrom.experiments[0] == my_chrom.experiments["k562"]

exp = my_chrom.experiments["k562"] + my_chrom.experiments["gm06690"]
print exp

my_chrom.add_experiment(exp)
print my_chrom.experiments


# Hi-C matric visualization

exp.view()

my_chrom.visualize([('k562', 'gm06690'), 'k562+gm06690'])


# Find Topologically wAssociating Domains

my_chrom.find_tad('k562', n_cpus=8)
my_chrom.find_tad('gm06690', n_cpus=8)

exp = my_chrom.experiments["k562"]
exp.tads
#exp.normalize_hic


# TADs to text

exp.write_tad_borders()

# TADs in interaction matrices

my_chrom.visualize(exp.name, paint_tads=True)
#my_chrom.visualize([('k562', 'gm06690')], paint_tads=True, focus=(490,620), normalized=True)
my_chrom.visualize([('k562', 'gm06690')], paint_tads=True, focus=(490,620))

# TADs in density plots

my_chrom.tad_density_plot('k562')

# Finding TADs in related Hi-C experiments

my_chrom.find_tad(['k562', 'gm06690'], batch_mode=True, n_cpus=8)
print my_chrom.experiments

# limit max TAD size
my_chrom.set_max_tad_size(3000000)
my_chrom.visualize('k562', paint_tads=True)

#Saving and restoring data
my_chrom.save_chromosome("some_path.tdb", force=True)
# restore data
from pytadbit import load_chromosome
my_chrom = load_chromosome("some_path.tdb")

print my_chrom.experiments

# My data

my_chrom = Chromosome(name='mm10', centromere_search=True,
                      species='Mus musculus', assembly='NCBI36')

my_chrom.add_experiment('Tcell', cell_type='wild type', exp_type='Hi-C', identifier='Tcell',
                        project='Seitan',
                        hic_data="/work/Hi-C/GSE48763_Seitan/HiCproResults/hic_results/matrix/Tcell_Rad21KO_R1/iced/100000/Tcell_Rad21KO_R1_100000_iced_chr10_dense.matrix", resolution=100000)

exp = my_chrom.experiments["Tcell"] 
exp.view()


my_chrom.find_tad('Tcell', n_cpus=8)

exp = my_chrom.experiments["Tcell"]
exp.tads

my_chrom.visualize(exp.name, paint_tads=True)


# Alignment of TAD boundaries
from pytadbit import Chromosome

# initiate a chromosome object that will store all Hi-C data and analysis
my_chrom = Chromosome(name='My fisrt chromosome', centromere_search=True)

# load Hi-C data
my_chrom.add_experiment('First Hi-C experiment', hic_data="scripts/sample_data/HIC_k562_chr19_chr19_100000_obs.txt", resolution=100000)
my_chrom.add_experiment('Second Hi-C experiment', hic_data="scripts/sample_data/HIC_gm06690_chr19_chr19_100000_obs.txt", resolution=100000)

# Filter and normalize Hi-C matrices
my_chrom.experiments['First Hi-C experiment'].filter_columns()
my_chrom.experiments['Second Hi-C experiment'].filter_columns()
my_chrom.experiments['First Hi-C experiment'].normalize_hic(iterations=30, max_dev=0.1)
my_chrom.experiments['Second Hi-C experiment'].normalize_hic(iterations=30, max_dev=0.1)

# run core tadbit function to find TADs, on each experiment
my_chrom.find_tad('First Hi-C experiment', ncpus=4)
my_chrom.find_tad('Second Hi-C experiment', ncpus=4)

print my_chrom.experiments


# Aligning boundaries
my_chrom.align_experiments(names=["First Hi-C experiment", "Second Hi-C experiment"])

print my_chrom.alignment

# Check alignment consistency through randomization

score, pval = my_chrom.align_experiments(randomize=True, rnd_method="interpolate", rnd_num=100)

print 'score:', score
print 'p-value:', pval

ali = my_chrom.alignment[('First Hi-C experiment', 'Second Hi-C experiment')]

print ali

ali.draw()
ali.draw(focus=(1, 250))

xpr = my_chrom.experiments[0]
my_chrom.tad_density_plot(0, focus=(1, 300))

#The get_column function

ali.get_column(3)

cond1 = lambda x: x['score'] > 7
ali.get_column(cond1=cond1)

cond2 = lambda x: x['pos'] > 50
ali.get_column(cond1=cond1, cond2=cond2)
ali.get_column(cond1=cond1, cond2=cond2, min_num=1)


#Compare two TADs
from pytadbit import Chromosome
my_chrom = Chromosome(name='My first chromosome')
my_chrom.add_experiment('First Hi-C experiment', hic_data="scripts/sample_data/HIC_k562_chr19_chr19_100000_obs.txt", resolution=100000)
my_chrom.find_tad('First Hi-C experiment')

tad1 = list(my_chrom.iter_tads('First Hi-C experiment'))[31]
tad2 = list(my_chrom.iter_tads('First Hi-C experiment'))[35]

from pytadbit.tad_clustering.tad_cmo import optimal_cmo
align1, align2, score = optimal_cmo(tad1[1], tad2[1], max_num_v=8, long_nw=True, long_dist=True, method='frobenius')


# 3D modeling
# Remove outliers
from pytadbit import Chromosome

my_chrom = Chromosome('19')
my_chrom.add_experiment('gm', resolution=10000,
                        hic_data='scripts/sample_data/HIC_gm06690_chr19_chr19_100000_obs.txt')

exp = my_chrom.experiments[0]

zeroes = exp.filter_columns(draw_hist=True)

# Parameter optimization for IMP
from pytadbit import load_chromosome # to load chromosomes
from pytadbit.imp.impoptimizer import IMPoptimizer

# Load the chromosome
my_chrom = load_chromosome('some_path.tdb')
Next, load Hi-C data for each experiment (Hi-C data is not saved inside chromosome objects because of their size):

# Loop over experiments in chromosome and load Hi-C data.
res = 100000

for exp in my_chrom.experiments:
    try:
        exp.load_hic_data('../../scripts/sample_data/HIC_{0}_{1}_{1}_{2}_obs.txt'.format(exp.name, my_chrom.name, res))
        exp.normalize_hic(factor=1)
    except IOError:
        print 'file not found for experiment: ' + exp.name
        continue
    print exp

    

### 3D modelling
from pytadbit import load_chromosome # load chromosome
from pytadbit.modelling.IMP_CONFIG import CONFIG # Pre-defined parameters for modeling
from pytadbit.modelling.structuralmodels import load_structuralmodels 

# Load the chromosome
#my_chrom = load_chromosome('some_path.tdb')

# Loop over experiments in chromosome and load Hi-C data.
res = 100000

for exp in my_chrom.experiments:
    try:
        exp.load_hic_data('../../scripts/sample_data/HIC_{0}_{1}_{1}_{2}_obs.txt'.format(exp.name, my_chrom.name, res))
    except:
        print 'file not found for experiment: ' + exp.name
        continue

# Load Hi-C of the individual experiments and put it into the sum experiment BR+TR1+TR2
my_chrom.experiments['k562+gm06690'].load_hic_data((my_chrom.experiments['k562'] + my_chrom.experiments['gm06690']).hic_data,'k562+gm06690')
exp = my_chrom.experiments['gm06690']
exp.normalize_hic()
exp.filter_columns()
print my_chrom.experiments

# See pre-defined sets of parameters
CONFIG

# Set of optimal parameters from pervious tutorial #2

optpar = {'kforce': 5,
          'lowfreq': 0.0,
          'lowrdist': 100,
          'upfreq': 0.8,
          'maxdist': 2750,
          'scale': 0.01,
          'reference': 'gm cell from Job Dekker 2009'}

# Build 3D models based on the HiC data. This is done by IMP.
models = exp.model_region(100, 200, n_models=500, n_keep=100, n_cpus=12, keep_all=True, config=optpar)
print models

models.experiment

# Select top 10 models
models.define_best_models(10)
print "Lowest 10 IMP OF models:"
print models

# Select top 100 models
models.define_best_models(100)
print "Lowest 100 IMP OF models:"
print models

# Get the data for the lowest IMP OF model (number 0) in the set of models
model = models[0]
print model


# Get the IMP OF of the stored model in "model"
model.objective_function(log=True, smooth=False)


# Re-select again the top 1000 models
models.define_best_models(100)
# Calculate the correlation coefficient between a set of kept models and the original HiC matrix
models.correlate_with_real_data(plot=True, cutoff=1000)

models.zscore_plot()

models.align_models(in_place=True)
models.deconvolve(fact=0.6, dcutoff=1000, represent_models='best', n_best_clusters=5)


# Cluster models based on structural similarity
models.cluster_models(fact=0.95, dcutoff=2000)
print models.clusters

cl = models.cluster_analysis_dendrogram(color=True)
# Show de dendogram for only the 5 top clusters and no colors
cl = models.cluster_analysis_dendrogram(n_best_clusters=5, color=True)

# Calculate the consistency plot for all models in the first cluster (cluster 0)
models.model_consistency(cluster=1, cutoffs=(1000,2000))

# Calculate a DNA density plot
models.density_plot()

# Get a similar plot for only the top cluster and show the standar deviation for a specific(s) running window (steps)
models.density_plot(cluster=1,error=True, steps=(5))

models.walking_angle(steps=(3, 5, 7), signed=False)

models.interactions(cutoff=2000)


# Get a contact map for the top 50 models at a distance cut-off of 300nm
models.contact_map(models=range(5,10), cutoff=1200, savedata="contact.txt")
# Correlate the contact map with the original input HiC matrix for cluster 1
models.correlate_with_real_data(cluster=1, plot=True, cutoff=1500)
# Correlate the contact map with the original input HiC matrix for cluster 2
models.correlate_with_real_data(cluster=2, plot=True, cutoff=1500)
# Correlate the contact map with the original input HiC matrix for cluster 10
models.correlate_with_real_data(cluster=10, plot=True, cutoff=1500)


# Get the average distance between particles 13 and 20 in all kept models
models.median_3d_dist(13, 20, plot=False)

# Plot the distance distributions between particles 15 and 20 in all kept models
models.median_3d_dist(15, 20, plot=True)

# Plot the distance distributions between particles 13 and 30 in the top 100 models
models.median_3d_dist(13, 30, models=range(100))

# Plot the distance distributions between particles 13 and 30 in the models from cluster 0
models.median_3d_dist(0, 54, plot=True, cluster=1)

models.view_models(stress='centroid', tool='plot', figsize=(10,10), azimuth=-60, elevation=100)

models.view_models(highlight='centroid', show='highlighted', tool='plot', figsize=(10,10), azimuth=-60, elevation=100, color='tad')

models.view_models(highlight='centroid', show='highlighted', tool='plot', figsize=(10,10), azimuth=-60, elevation=100, color='border')

# Generate the image using Chimera in batch mode. That takes some time, wait a bit before running next command.
# You can check in your home directory whether this has finished.
models.view_models(models=[0], tool='chimera_nogui', savefig='/tmp/image_model_1.png')
