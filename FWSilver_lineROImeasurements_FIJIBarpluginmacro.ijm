selectWindow("WT_male_FW_upperlamina_silver_08-thresholded_medfilt5.tif");
run("Plot Profile");
makeLine(99, 162, 624, 162);
run("Plot Profile");

selectWindow("Plot of Plot of WT_male_FW_upperlamina_silver_08-thresholded_medfilt5");	
run("Find Peaks", "min._peak_amplitude=22.65 min._peak_distance=0 min._value=[] max._value=[]");