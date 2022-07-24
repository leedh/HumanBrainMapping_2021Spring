#######################
## Human Brain Mapping 2021 Spring
#######################
## Preprocessing Example 
## 181127 jyh edited - @Align_centers added. 
## 
## *STEP*
##    01. Skull Stripping
##    02. Alignment (co-registration & motion correction)
##    03. Scaling
##    04. Detrending
##    05. Highpass filtering
##    06. Add mean 
##
## Make your own preprocessing steps by customizing functions below.
#######################

SN=sub-hbm001 #ret num
RET_DIR=/media/das/HBM_2021spring/imaging/raw #set directories 
subjdir=$RET_DIR/${SN}/ #set directories
cd $subjdir 


##------------------------ 01Skull Stripping ------------------------
3dSkullStrip -input T1+orig. -prefix T1_SS     #make T1_SS+orig. file 


##------------------------ 02Alignment: Co-regi & volreg ------------------------
#!!!DECIDE FIRST WHICH WAY YOU WANT TO DO ALIGNMENT (ANAT@EPI? EPI@ANAT?) 
#This script is wrote for anat@epi alignment. 

#Align centers first 
@Align_Centers -no_cp -base MT1.nii -dset T1_SS+orig. 

#T1_SS - EPI alignment 
#example1. anat 2 epi 
align_epi_anat.py -epi MT1.nii -epi_base 0 -anat T1_SS+orig.HEAD -anat2epi \
-cost lpa -deoblique off -feature_size 0.5 -ginormous_move #align_centers yes 

# Co-registration : Align anatomical images to EPI 
# Motion correction : Align EPIs to EPI (volume registration)
# afni_proc.py does both alignment processes + other preprocessing things. 

subj=MT_proc
afni_proc.py -subj_id ${subj} \
-dsets MT1.nii MT2.nii \
-blocks align volreg blur mask regress \
-volreg_base_dset MT1.nii'[0]'     \ #voleg:register epis to the FIRST volume of MT1.nii 
-volreg_align_e2a                         \
-align_opts_aea -giant_move               \ #co-regi:align anatomy to epi, and then epi to anatomy again(e2a)
-copy_anat T1_SS+orig.               \ #use this file as anatomy
-regress_censor_motion 0.5                \ #remove TRs with head motion over .5. 
-regress_censor_outliers 0.1              \
#-blur_size 5 # smoothing. specify how much spatial blurring will be used (FWHM mm)
# if you plan on additional preprocessing, always remember to smooth at the very last step

tcsh -xef proc.${subj} |& tee output.proc.${subj} #run the tcsh script. 
cd ./${subj}.results #go check the results. 



#**Read Me!**
#afni_proc.py creates a preprocessing tcsh script. (checking the script is highly recommended)
#You can add more and more preprocessing steps into it. 
#For example, you can do other types of alignment using this function (google additional options)  
# (anat to EPI, EPI to anat, EPI to EPI, surf to EPI, anat to anat etc...)

#ANOTHER WAY TO DO ALIGNMENT
#example2. anat to anat (if you're doing multi-session experiment)
align_epi_anat.py -dset1 T1_SS_session1+orig.nii -dset2 T1_SS_session2+orig -dset2to1 \
-cost lpa -deoblique off -feature_size 0.5 -ginormous_move 


##------------------------ 03Scaling (intensity normalization) ------------------------
run=( 01 02 03 04 05 06 07 08)
for r in "${run[@]}"
do
#get spaces between brain and skull in every run images
3dClipLevel pb01.${subj}.r${r}.volreg+orig.HEAD >> clip.txt
#calculate the mean value of total of epi images   
3dTstat -mean -prefix r.${r}.base pb01.${subj}.r${r}.volreg+orig.HEAD'[0..$]' 
done

more clip.txt # check the smallest clip value across all runs
clip=$(cut -f1 -d"," clip.txt | sort -n | head -1) # assign the clip value# assign the clip value
for r in "${run[@]}"
do
3dcalc -a pb01.${subj}.r${r}.volreg+orig. -b r.${r}.base+orig. \
       -expr "(100 * a/b) * step(b-$clip)" -prefix pb02.${subj}.r${r}.scaled #remove the space and scale 
done
# (tip) when calling variables(like $clip) within 3dcalc -expr, be sure to use "", and not ''


##------------------------ 04Detrending & 05Filtering ------------------------
run=( 01 02 03 04 05 06 07 08)
for i in "${run[@]}"
do
3dDetrend -polort 1 -prefix pb03.${subj}.r$i.sc_dt+orig pb02.${subj}.r${r}.scaled
# this is high-pass filtering since there's no ceiling
3dBandpass -prefix pb04.${subj}.r${r}.sc_dt_hp 0.01 99999 pb03.${subj}.r${r}.sc_dt+orig 
done


##------------------------ 06Adding mean ------------------------
#add mean (since the values after filtering are too small for further calculation)
3dTstat -mean -prefix r.${r}.sc_base pb02.${subj}.r$i.scaled+orig.HEAD'[0..$]'
3dcalc  -a pb04.${subj}.r$i.sc_dt_hp+orig.HEAD -b r.${r}.sc_base+orig.HEAD \
	-expr 'a+b' -prefix pb05.${subj}.r${r}.sc_dt_hp_am








