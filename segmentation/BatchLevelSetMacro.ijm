//	This macro should be run after the image set to be run is open
//	and the user has defined a small and large box to bind the test
//	contours for seeding the active contour program. A good start for
//	the ROIs is a pre-box that is slightly larger than the smallest frame
//	and a post-box that is slightly larger than the largest frame.
//	The macro will output an image set with contours drawn on the original
//	image and a mask image based on those contours based off of the active.
//	contour for each box. The user can then take the best fit frames from the 
//	different boxes to make a mask set that works for the application.
//--------------------------------------------------------------------------------
//       User-Defined Variables
//--------------------------------------------------------------------------------
//specify the number of seed contours desired:
	nBox = 5;

// specify the fraction of the image set that each seed contour will be 
// tested over:
	subset = 4;

//determine how change in major axis will be handled:
//1 means that the smallest height and smallest width will be
//used even if they come from different ROIs. If 0 is selected it will start
//with the smallest width and increment the width and its height between the
//extreme values. Both branches are identical if the smallest width was in the
//same ROI as the smallest height.
	maintainAR = 0;

//--------------------------------------------------------------------------------

if(nBox+1 < subset-1){
	Dialog.create("User Input Variable Warning");
	Dialog.addMessage("Warning:\n Not all frames will be analyzed.\n");
	Dialog.show();
}

setBatchMode(true);

widthArray = newArray(nBox);
heightArray = newArray(nBox);
xArray = newArray(nBox);
yArray = newArray(nBox);

imageStack = File.openDialog("Select image sequence . . .");
open(imageStack);
isName = File.getName(imageStack);

savePath = getDirectory("Select a Save Folder");

totalSlices = nSlices;

//print(totalSlices);

roiManager("Select",0);

getSelectionBounds(x0, y0, width0, height0);

//print(x0,y0,width0,height0);

roiManager("Select",1);

getSelectionBounds(x1, y1, width1, height1);

//print(x1,y1,width1,height1);

centerX0 = x0+width0/2;
centerY0= y0+height0/2;
//print(centerX0,centerY0);

centerX1 = x1+width1/2;
centerY1= y1+height1/2;
//print(centerX1,centerY1);

centerX=(centerX0+centerX1)/2;
centerY=(centerY0+centerY1)/2;
//print(centerX,centerY);

widthRange = abs(width0-width1);
heightRange = abs(height0-height1);

widthIncrement=widthRange/(nBox+1);
heightIncrement=heightRange/(nBox+1);

//print(widthIncrement);
//print(heightIncrement);

if(maintainAR==0) {
	//print("false");
	if( width0 < width1){
		if( height0 > height1){
			ARswitch = 1;
			maximumHeight = height0;
			minimumWidth=width0;
			first_0 = 1;
		}else{
			ARswitch = 0;
		}
	} else{
		if (height0 < height1){
			ARswitch = 1;
			maximumHeight = height1;
			minimumWidth=width1;
			first_0 = 0;
		} else{
			ARswitch=0;
		}
	}
	if(ARswitch){
		for (i =0; i < nBox; i++){
		widthArray[i] = minimumWidth+(i+1)*widthIncrement;
		heightArray[i] = maximumHeight-(i+1)*heightIncrement;
		xArray[i] = parseInt(centerX-widthArray[i]/2);
		yArray[i] = parseInt(centerY-heightArray[i]/2);
		widthArray[i] = parseInt(widthArray[i]);
		heightArray[i] = parseInt(heightArray[i]);
		//print("(",xArray[i],",",yArray[i],")");
		//print( "width:",widthArray[i]);
		//print( "height:", heightArray[i]);
		makeOval(xArray[i],yArray[i],widthArray[i],heightArray[i]);
		roiManager("Add");
		}

	} else{
	maintainAR = 1;
	}
}
if(maintainAR){
	//print("true");
	if( width0 < width1){
		minimumWidth=width0;
		first_0 = 1;
	} else{
		minimumWidth=width1;
		first_0 = 0;
	}
	//print(minimumWidth);

	if( height0 <height1){
		minimumHeight=height0;
	} else{
		minimumHeight=height1;
	}
	//print(minimumHeight);
	
	for (i =0; i < nBox; i++){
	widthArray[i] = minimumWidth+(i+1)*widthIncrement;
	heightArray[i] = minimumHeight+(i+1)*heightIncrement;
	xArray[i] = parseInt(centerX-widthArray[i]/2);
	yArray[i] = parseInt(centerY-heightArray[i]/2);
	widthArray[i] = parseInt(widthArray[i]);
	heightArray[i] = parseInt(heightArray[i]);
	//print("(",xArray[i],",",yArray[i],")");
	//print( "width:",widthArray[i]);
	//print( "height:", heightArray[i]);
	makeOval(xArray[i],yArray[i],widthArray[i],heightArray[i]);
	roiManager("Add");
	}
	//print(widthArray[1]);
	//print(heightArray[1]);
}
call("java.lang.System.gc"); 
//Get path to temp directory
tmp = getDirectory("temp");
if (tmp=="")
	exit("No temp directory available");

// Create a directory in temp
tempDir = tmp+"BatchLevelSetROI"+File.separator;
File.makeDirectory(tempDir);
if(!File.exists(tempDir))
	exit("Unable to create directory");

print(tempDir);
call("java.lang.System.gc"); 
roiManager("Save", tempDir+"CompleteRoiSet.zip");
roiCount=roiManager("Count");
//print(roiCount);
j=0;


for(j=0; j < roiCount; j++){
	if (j==0){
		if (first_0){
			firstSlice = 1;
			lastSlice = parseInt(totalSlices/subset);
		}
		else{
			firstSlice = totalSlices - parseInt(totalSlices/subset);
			lastSlice = totalSlices;
		}
	}
	if (j == 1){
		if (!first_0){
			firstSlice = 1;
			lastSlice = parseInt(totalSlices/subset);
		}
		else{
			firstSlice = totalSlices - parseInt(totalSlices/subset);
			lastSlice = totalSlices;
		}
	}
	if (j >1){
		multiplier = (totalSlices*(1-1/subset)/(nBox+1))*(j-1);
		firstSlice = parseInt(multiplier);
		lastSlice = parseInt(totalSlices/subset + multiplier);
	}
		//roiManager("Save Selected", tempDir+"temp.zip")
		//roiManager("Deselect");
		//roiManager("Delete");
		//roiManager("Open",tempDir+"temp.zip");
	for (k = firstSlice; k <= lastSlice; k++){
		open(imageStack,k);
		rename(k);
		selectWindow(k);
		roiManager("Select",j);
		run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=5 distance_threshold=0.50 advection=1 propagation=1 curvature=1.25 grayscale=0 convergence=0.0015 region=inside");
		//print("I arrived out of the snake");
		selectWindow("Segmentation of "+ k);
		save(tempDir+"Seg_"+j+"_"+k+".tif"); close();
		selectWindow("Segmentation progress of "+ k);
		save(tempDir+"Draw_"+j+"_"+k+".tif"); close();
		run("Close");
		//selectWindow("Segmentation progress of "+ k);
		//save(savePath+"Draw_"+j+"_"+k+".tif"); 
		activeImage = getTitle();
		print("Pre-close active image is:",activeImage);
		close();
		activeImage = getTitle();
		print("Post-close active image is:",activeImage);
		//selectWindow("Segmentation progress of "+k); close();
		selectWindow(k); close();
		//roiManager("Delete");
		//roiManager("Open", tempDir+"CompleteRoiSet.zip");
		call("java.lang.System.gc"); 
		//close("*"+k);
		 while (nImages>0) { 
        			 selectImage(nImages); 
         			 close(); 
  		  } 
	}
	firstDraw = "["+tempDir+"Draw_"+j+"_"+k+".tif]";
	firstSeg = tempDir+"Seg_"+j+"_"+k+".tif";
	seqDraw = savePath+"Draw_"+j+".tif";
	seqSeg = savePath+"Seg_"+j+".tif";
	run("Image Sequence...", "open=&firstDraw number=10000 starting=1 increment=1 scale=100 file=Draw_"+j+" or=[] sort");
	save(seqDraw); close();
	run("Image Sequence...", "open=&firstSeg number=10000 starting=1 increment=1 scale=100 file=Seg_"+j+" or=[] sort");
	save(seqSeg); close();
}

//selectWindow(isName); close();
//roiManager("Deselect");
//roiManager("Delete");
setBatchMode("exit and display");

 while (nImages>0) { 
       			 selectImage(nImages); 
       			 close();
 }
list = getFileList(tempDir);
for (k=0; k<list.length; k++)
   	ok = File.delete(tempDir+list[k]);
	ok = File.delete(tempDir);
if (File.exists(tempDir))
     	exit("Unable to delete temporary directory");
 else
     	 print("Temporary directory and files successfully deleted");


