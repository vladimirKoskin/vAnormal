%%% Generate 2D coordinates
x_vals = linspace(-3,3,300);
y_vals = x_vals;

%%% Set sigmq
sigma = 0.7;

pdf_Anormal = zeros(length(x_vals),length(y_vals));
petals_vals = 1:8;

figure; hold on
for n_petals_id = 1:length(petals_vals)
    n_petals = petals_vals(n_petals_id);
for x_id = 1:length(x_vals)
    x = x_vals(x_id);
    for y_id = 1:length(y_vals)
        y = y_vals(y_id);        
        % Transform coordinates from (x,y) to (angle,Distance)
        angle = atan2(x,y); 
        distance_squared = x^2 + y^2;        
        % Use the chosen shape function
        if n_petals == 1         
            r = (2 - 2*sin(angle)+sin(angle)*sqrt(abs(cos(angle)))/(sin(angle)+1.4)); 
            % Heart
        else
            r = (sin(angle*n_petals)+2); 
            % Flower
        end        
        % Apply the formula
        pdf_Anormal(x_id,y_id) = exp( -1/2*(distance_squared)./(sigma*r)^2);
    end
end
pdf_Anormal = pdf_Anormal./sum(pdf_Anormal(:)); % Normalize at the end because used non-normalized shape function r.
if length(petals_vals) > 1
    subplot(2,ceil(length(petals_vals)/2),n_petals_id); hold on
end
if n_petals == 1
title('Heart')
else
title("nb petals = "+num2str(n_petals));
end
surface(pdf_Anormal,'EdgeAlpha',0.1);
end