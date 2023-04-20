# ancestry identification v1
# constructed by Tsing Lin 2023-04-10
admixture="" # software path
refer_path="" # reference genotype (plink format .bed .bim .fam)
candi_path="" # candidate genotype (plink format .bed .bim .fam)
data_path="" # population information path (.fam)
save_path="" # save path

fid=candidate
iid=358

cd ${data_path}
files=`ls *.txt`
cd ${save_path}

# generate 
echo "$fid $iid 0 0 0 -9" > ${save_path}/${fid}.${iid}.txt

# extract candidate genotype
plink --bfile ${candi_path}/candidates \
--keep ${save_path}/${fid}.${iid}.txt \
--extract ${refer_path}/Reference.bim \
--make-bed \
--out ${save_path}/${fid}.${iid}

# run admixture
for j in ${files[@]}
do

# extrac reference individuals
plink --bfile ${refer_path}/Reference \
--keep ${data_path}/${j} \
--make-bed \
--out ${save_path}/tmp
# merge genotype between reference panel and candidate
plink --bfile ${save_path}/tmp \
--bmerge ${save_path}/${fid}.${iid} \
--make-bed \
--out ${save_path}/${j%.txt}

rm ${save_path}/${fid}.${iid}/tmp.*

# run structure
# for K in `seq 2 5`
# do
if [ ${j} == "All_individuals.txt" ]; then
# run candidate with all reference panel 
K=2
${admixture} --cv ${save_path}/${j%.txt}.bed ${K} -j23 | tee ${save_path}/${j%.txt}.${K}.out
else
# run cadidate with each indigenous breed
K=5
${admixture} --cv ${save_path}/${j%.txt}.bed ${K} -j23 | tee ${save_path}/${j%.txt}.${K}.out
fi

done

# remove the middle files
rm ${save_path}/*.bed ${save_path}/*.bim ${save_path}/*.nosex ${save_path}/*.P
