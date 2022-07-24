function condition_list = shuffled_condition(i)
% choose one of condition list order
%

    if i==1
        condition_list = ["High_Certainty" "Middle_Certainty"];
    elseif i==2
        condition_list = ["High_Certainty" "Low_Certainty"];
    elseif i==3
        condition_list = ["Low_Certainty" "Middle_Certainty"];
    elseif i==4
        condition_list = ["Low_Certainty" "High_Certainty"];
    elseif i==5
        condition_list = ["Middle_Certainty" "Low_Certainty"];
    elseif i==6
        condition_list = ["Middle_Certainty" "High_Certainty"];
    elseif i==7
        condition_list = ["Low_Certainty" "Low_Certainty"];
    elseif i==8
        condition_list = ["High_Certainty" "High_Certainty"];
    end

end

