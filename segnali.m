clear all
for dataset = 1:10
%     file_train = ["0115_8min.mat","0123_8min.mat","0030_8min.mat","0031_8min.mat","0032_8min.mat","0105_8min.mat","0035_8min.mat","0028_8min.mat","0018_8min.mat","0029_8min.mat"]; 
   file_test = ["0103_8min.mat","0134_8min.mat","0133_8min.mat","0127_8min.mat","0125_8min.mat","0123_8min.mat","0122_8min.mat","0121_8min.mat","0104_8min.mat","0103_8min.mat","0023_8min.mat","0016_8min.mat","0015_8min.mat","0009_8min.mat"];

test_dataset{dataset} = load(file_test(dataset));
end