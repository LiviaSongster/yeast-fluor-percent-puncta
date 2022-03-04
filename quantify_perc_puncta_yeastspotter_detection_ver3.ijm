// TO RUN: select folder containing all your BLINDED movies as .nd2 files.
// make sure they are all in the same format (i.e., green channel first, then DIC)

// GOALS:
// 1) analyze the fraction of fluorescence signal coming from very bright puncta vs. all signal within the cell
// 2) expect high percentage = less diffuse fluorescence

mainDir = getDirectory("Choose a directory containing your files:"); 
yeastDir = getDirectory("Choose the corresponding yeastspotter directory:");
Dialog.create("Define variables");
Dialog.addString("Puncta Threshhold:", "550"); //default is 550

// next pull out the values from the dialog box and save them as variables
Dialog.show();
punctaValue = Dialog.getString(); 

// finds all the filenames within the folder you select
mainList = getFileList(mainDir); 
yeastList = getFileList(yeastDir);

// make a new folder to hold all the outputs at the very end
finalDir = mainDir+"Percent-Puncta-Results"+File.separator;
File.makeDirectory(finalDir);

// default assumes files are all .tif - will NOT analyze if filetype is not tif
imageType = ".tif";

// clunky, loops thru all items in folder looking for image
for (m=0; m<mainList.length; m++) { // m is iterator
	 
	 // if filename list is nd2, execute following code. otherwise, skip the file
	if (endsWith(mainList[m], imageType)) {
		
		open(mainDir+mainList[m]); //open image file on the list
		title = getTitle(); //save the title of the movie
		name = substring(title, 0, lengthOf(title)-9);
		
		// make new folder for each image's output
		outputDir = mainDir+name+"-output"+File.separator; 
		File.makeDirectory(outputDir);
		
		open(yeastDir+name+"_brightfield.tif");
		run("Invert");
		run("Analyze Particles...", "size=200-Infinity circularity=0.70-1.00 exclude clear add");

		selectWindow(title);
		// next save each cell roi and duplicate the images
		if (roiManager("Count") > 0){
			// first save all the rois as separate cell rois, then clear the roi list so it can be repopulated as necessary
			for (n = 0; n < roiManager("count"); n++){
				roiManager("Save", outputDir+"cell"+n+"_"+name+".roi"); 
				selectWindow(title); // selects your movie
				roiManager("Select", n); // select the cell roi
				run("Duplicate...", " "); // duplicate the image of the cell
				saveAs("Tiff", outputDir+"cell"+n+"_"+name+".tif");	// this is for analysis
				run("RGB Color");
				saveAs("BMP", outputDir+"cell"+n+"_"+name+".bmp");	// this is for easy checking later
        		}
		}
		close("*"); // close everything
		
		// now get list of all files within the current outputDir
		cellList = getFileList(outputDir); 
		
		// loop thru all tifs
		for (i=0; i<cellList.length; i++) { // i is iterator
	  		if (endsWith(cellList[i], ".tif")) {
			
			open(outputDir+cellList[i]); //open image file on the list
			title2 = getTitle(); //save the title of the image
			name2 = substring(title2, 0, lengthOf(title2)-4); // save name of image without suffix
			// first take a read of intensity within the initial roi
			run("Measure");
			selectWindow("Results");
			saveAs("Results", finalDir+name2+"_totalcell_results.csv");
			close("ROI Manager");
			close("Results");
			
			// duplicate image
			selectWindow(title2);
			run("Select All");
			run("Duplicate...", " ");
			rename("median");

			// next we need to make a median filtered image, which we will then subtract
			run("Median...", "radius=20");
			imageCalculator("Subtract create", title2,"median");
			// the result is our new mask
			rename("mask");
			// now we want to threshold and save the mask
			//punctaThreshPerc = 95; // we only want the top 2% of bright spots to count
			//nBins = 255;
			//getHistogram(values, count, nBins);
			//cumSum = getWidth() * getHeight();
			//punctaValue = cumSum * (punctaThreshPerc / 100); // this is the value of our threshhold
			//punctaValue = 550;
			setThreshold(punctaValue, 65535);
			//setAutoThreshold("Default dark");
			setOption("BlackBackground", true);
			run("Convert to Mask");
			run("Watershed");
			//waitForUser("Manually correct the mask of the puncta using paintbrush, then click OK"); 
			selectWindow("mask");
			saveAs("BMP", outputDir+name2+"_puncta_mask.bmp");	// save the mask

			run("Analyze Particles...", "clear add");
			// if roi manager is empty, skip the following code
			if (roiManager("Count") > 0){
				roiManager("Save", outputDir+name2+"_puncta_RoiSet.zip");
									
				// analyze particles on the tif
				selectWindow(title2);
				roiManager("Deselect");
				roiManager("multi-measure measure_all");
				selectWindow("Results");
				saveAs("Results", finalDir+name2+"_puncta_results.csv");
				close("Results");
				close("ROI Manager");
			}
			
			close("*");
			}
		}
	} // end if loop
} // end initial forloop

