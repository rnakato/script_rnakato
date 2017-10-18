from pytadbit import Chromosome
from pytadbit import load_chromosome

Ct="Control,RPE_Ct/chr19_R_Ct_100000_iced_dense.matrix"
CTCF="CTCFKD,RPE_CTCFKD/chr19_R_si628_100000_iced_dense.matrix"
Rad21="Rad21KD,RPE_Rad21KD/chr19_R_si621_100000_iced_dense.matrix"
NIPBL="NIPBLKD,RPE_NIPBLKD/chr19_R_si7_100000_iced_dense.matrix"

tdbfile="RPE.tdb"
samples=[Ct,CTCF,Rad21,NIPBL]
my_chrom = loadData(tdbfile, samples)
ncpu=24

# Compare two TADs in one sample
tad1 = list(my_chrom.iter_tads('k562'))[31]
tad2 = list(my_chrom.iter_tads('k562'))[35]
align1, align2, score = optimal_cmo(tad1[1], tad2[1],
                                    max_num_v=8, long_nw=True, long_dist=True,
                                    method='frobenius')

### 2サンプル比較
label1="Control"
label2="Rad21KD"
my_chrom.find_tad([label1, label2], batch_mode=True, n_cpus=ncpu)
print my_chrom.experiments

# Aligning boundaries
my_chrom.align_experiments(names=[label1, label2])
# Check alignment consistency through randomization
ali = my_chrom.alignment[(label1, label2)]
print ali
ali.draw(savefig="TADbit." + label1 + "-" + label2 + ".TAD.png")
#ali.draw(focus=(1, 250))
score, pval = my_chrom.align_experiments(names=[label1, label2], randomize=True,
                                         rnd_method="interpolate", rnd_num=100)
print 'score:', score
print 'p-value:', pval

def loadData(tdbfile, samples):
    my_chrom = load_chromosome(tdbfile)
    for i,exp in enumerate(my_chrom.experiments):
        try:
            label, path = samples[i].split(",")
            print(i)
            print(path)
            print(exp.name)
            exp.load_hic_data(path)
            exp.normalize_hic(factor=1)
            exp.filter_columns()
        except IOError:
            print 'file not found for experiment: ' + exp.name
            continue
    return my_chrom

