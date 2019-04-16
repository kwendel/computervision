function [] = print_progress(text, percentage, file_name)
%PRINT_PROGRESS Prints the progress 
%

if nargin == 3
    disp(strcat(text, file_name))
else
    disp(strcat(text))
end

disp(strcat("Progress - ", num2str( percentage * 100), " %" ));
end

