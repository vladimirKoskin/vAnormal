%% Get DATA 

%%% 
url = 'http://socr.ucla.edu/docs/resources/SOCR_Data/SOCR_Data_Dinov_020108_HeightsWeights.html'

options = weboptions('RequestMethod','get','ArrayFormat','csv','ContentType','text');
try 
    data = webread(url,options);
    disp('CSV formatted data:');
    data;
catch 
    disp('No information found.');
end
data(1:1000)

line_start_list = strfind(data,'<tr');
line_end_list = strfind(data,'</tr>');
n_line = length(line_start_list);

[data_weight,data_height] = deal(zeros(1,n_line-1));
for line_id = 2:n_line
    
    column_start_list = strfind(data(line_start_list(line_id):line_end_list(line_id)),'<td');
    column_end_list = strfind(data(line_start_list(line_id):line_end_list(line_id)),'</td>');
    
    tmp_data_height = data(line_start_list(line_id)+column_start_list(2):line_start_list(line_id)+column_end_list(2));
    tmp_data_weight = data(line_start_list(line_id)+column_start_list(3):line_start_list(line_id)+column_end_list(3));
    
    data_height(line_id-1) = str2num(tmp_data_height(strfind(tmp_data_height,'>')+1:strfind(tmp_data_height,'<')-1));
    data_weight(line_id-1) = str2num(tmp_data_weight(strfind(tmp_data_weight,'>')+1:strfind(tmp_data_weight,'<')-1));
end

%%
data = readtable('./dataset_facebook_metrics/dataset_Facebook.csv');
data.LifetimePostTotalImpressions
data.TotalInteractions

summary(data)
data_height = data.LifetimePostTotalImpressions;
sum(isnan(data_height))
% data_height(isnan(data_height)) = -1;
data_weight = data.TotalInteractions;
sum(isnan(data_weight))
% data_weight(isnan(data_weight)) = -1;

%% Fits



%%% Normal Fit for Each dimension separately

mean_height = nanmean(data_height);
mean_weight = nanmean(data_weight);

std_height = nanstd(data_height);
std_weight = nanstd(data_weight);
grid_precision = 100;

%%%
coeff_grid_min_max = 2;
min_height = max(min(data_height),mean_height-coeff_grid_min_max*std_height);
max_height = min(max(data_height),mean_height+coeff_grid_min_max*std_height); 

min_weight = max(min(data_weight),mean_weight-coeff_grid_min_max*std_weight);
max_weight = min(max(data_weight),mean_weight+coeff_grid_min_max*std_weight); 
%%%



height_grid = linspace(min_height,max_height,grid_precision);
weight_grid = linspace(min_weight,max_weight,grid_precision);
est_pmf_height = normpdf(height_grid,mean_height,std_height);
est_pmf_weight = normpdf(weight_grid,mean_weight,std_weight);

figure; hold on ;
subplot(1,2,1); hold on
    title('Normal distribution fit to the Height distribution in the population')
    plot(height_grid,est_pmf_height)
subplot(1,2,2); hold on
    title('Normal distribution fit to the Weight distribution in the population')
    plot(weight_grid,est_pmf_weight)

%%% Uncorrelated Bi-Variate Normal Fit:
  
covar_mat = [std_height^2, 0; 0 , std_weight^2];
mean_vect = [mean_height,mean_weight];

gridpoints_2d_list = zeros(2,grid_precision^2);
countr = 1;
for i = 1:grid_precision
    for j = 1:grid_precision       
        gridpoints_2d_list(1,countr) = height_grid(i);
        gridpoints_2d_list(2,countr) = weight_grid(j);
        countr = countr + 1;
    end
end

est_pmf_both = mvnpdf(gridpoints_2d_list',mean_vect,covar_mat);
est_pmf_both_mat = reshape(est_pmf_both,grid_precision,grid_precision);

figure; hold on ; title('Uncorrelated Bi-Variate Normal Fit')
surface(height_grid,weight_grid,est_pmf_both_mat)


%%% Full Bi-Variate Normal Fit:
covar_mat_good = nancov([data_height,data_weight]);


est_pmf_both_good = mvnpdf(gridpoints_2d_list',mean_vect,covar_mat_good);
est_pmf_both_mat_good = reshape(est_pmf_both_good,grid_precision,grid_precision);

figure; hold on; title('Full Bi-Variate Normal Fit')
surface(height_grid,weight_grid,est_pmf_both_mat_good)

%%% MultiVariate Kernel Density Fit:

KDE_est = mvksdensity(data_full,gridpoints_2d_list');
KDE_est_mat = reshape(KDE_est,grid_precision,grid_precision);

figure; hold on; title('Full KDE Fit')
surface(height_grid,weight_grid,KDE_est_mat)

figure; hold on; title('Scattered Data')
scatter(data_height,data_weight)


%%
% prompt = 'Enter company of interest:';
% val = input(prompt,'s');
% url = strcat(url,val,'.csv');