// TO RUN: select batch directory for analysis

// GOALS:
// 1) automatically split long stacks into hyperstacks with 2 channels and X z plane
// 2) allow user to select ROIs and make crops from a big batch of movies quickly

mainDir = getDirectory("Choose a directory containing your files:"); 
mainList = getFileList(mainDir); 

Dialog.create("Define the image type");
Dialog.addString("Input Image Type:", ".nd2"); //default is .tif
Dialog.addString("Brightfield image channel number:", "1"); //default is 1

// next pull out the values from the dialog box and save them as variables
Dialog.show();
imageType = Dialog.getString();
brightChannel = Dialog.getString();

// make sub directories for output files
maxDir = mainDir+"Output-MaxZ"+File.separator;
File.makeDirectory(maxDir);
bmpDir = mainDir+"Output-RGBbmp"+File.separator;
File.makeDirectory(bmpDir);
sumDir = mainDir+"Output-SumZ"+File.separator;
File.makeDirectory(sumDir);
avgDir = mainDir+"Output-AvgZ"+File.separator;
File.makeDirectory(avgDir);
brightDir = mainDir+"Output-Brightfield"+File.separator;
File.makeDirectory(brightDir);
Dir = mainDir+"yeastspotter"+File.separator;
File.makeDirectory(Dir);


for (m=0; m<mainList.length; m++) { //clunky, loops thru all items in folder looking for image
	if (endsWith(mainList[m], imageType)) { 
		open(mainDir+mainList[m]); //open image file on the list
		
		title = getTitle(); //save the title of the movie
		name = substring(title, 0, lengthOf(title)-4);
		run("Duplicate...", "duplicate");
		rename("max");
		
		// max Z project all channels
		run("Z Project...", "projection=[Max Intensity]");
		maxtitle = getTitle(); //save the new title of the movie
		run("Split Channels");
		
		if (brightChannel == 1) { 
			green = "C2-";
			bright = "C1-";
		} else {
			green = "C1-";
			bright = "C2-";
		}

		green_title = green+maxtitle;
		bright_title = bright+maxtitle;
		
		// save tiff of max projection
		selectWindow(green_title);
		saveAs("Tiff", maxDir+name+"_MAXZ.tif");
		resetMinAndMax();	
		// also save as bmp	
		run("RGB Color", "frames");
		saveAs("bmp", bmpDir+name+"_MAXZ.bmp");
		// save brightfield
		selectWindow(bright_title);
		saveAs("Tiff", brightDir+name+"_brightfield.tif");

		selectWindow(title);
		run("Duplicate...", "duplicate");
		// sum Z project all channels
		run("Z Project...", "projection=[Sum Slices]");
		sumtitle = getTitle(); //save the new title of the movie
		run("Split Channels");
		green_title = green+sumtitle;
		bright_title = bright+sumtitle;
		
		selectWindow(green_title);
		saveAs("Tiff", sumDir+name+"_SUMZ.tif");
		resetMinAndMax();		
		run("RGB Color", "frames");
		saveAs("bmp", bmpDir+name+"_SUMZ.bmp");
		close(bright_title);


		// average projection image
		selectWindow(title);
		run("Duplicate...", "duplicate");
		// avg Z project all channels
		run("Z Project...", "projection=[Average Intensity]");
		avgtitle = getTitle(); //save the new title of the movie
		run("Split Channels");
		
		green_title = green+avgtitle;
		bright_title = bright+avgtitle;

		selectWindow(green_title);
		saveAs("Tiff", avgDir+name+"_AVGZ.tif");
		resetMinAndMax();		
		run("RGB Color", "frames");
		saveAs("bmp", bmpDir+name+"_AVGZ.bmp");
		close(bright_title);
		close("*");
		
	}
}