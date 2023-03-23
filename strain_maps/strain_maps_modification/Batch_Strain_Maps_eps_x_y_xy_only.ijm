/*// This macro was created to create strain maps of a region
// within a mask. It is designed to be run using two saved stacks.
// One with the timelapse to be analyzed in bulk, and one a binary
// stack with the area of interest filled with white and the
// background black.

// Only epsx, epsy, and epsxy are calculated and saved (epsyx, eps1, eps2, and theta are not)

//User must have bUnwarpJ and the DisplacementMaps_eps_x_y_xy_only macro  and the 
//StrainMapsFromDisplacementMaps_eps_x_y_xy_only macro saved in the macro folder.

//--------------------------------------------------------------------------------------
//	User Defined Variables
//--------------------------------------------------------------------------------------
//  indicate the number of frames between frames to be compared
//	frameIncrement = 3;

// choose if the increment will be rolling (e.g. 1-5, 2-6, 3-7, ...) or not (e.g. 1-5, 6-10, 11-15, ...)
//	rolling = 1; -only does rolling increments at the moment.

//--------------------------------------------------------------------------------------

//this just determines if the temp file will be cleared. It should be 1 unless there is a reason
//data should be temporarily left in the temp file.
*/

cleanFinish = 1;

/*//make this true if you are debugging and want to use the default files
*/
deBug = 0;

Dialog.create("Batch Strain Maps");
Dialog.addNumber("Frame Increment",1);
Dialog.addCheckbox("Rolling Increments",true);
Dialog.addCheckbox("Verbose",false);
Dialog.show();
frameIncrement = Dialog.getNumber();
rolling = Dialog.getCheckbox();
verbose = Dialog.getCheckbox();

run("Collect Garbage"); // this command works in Fiji but not ImageJ
			// (click the status bar in ImageJ to release memory)

if (rolling){
	interval = 1;
}else{
	interval = frameIncrement;
}

//This allows the macro to run without images being displayed.
//if (!deBug){
	setBatchMode(true);
//}

if (deBug){
	imageStack = "C:\\Users\\lab\\Documents\\StrainMapping\\manualVsBatch\\RegBC Substack (1,11) 133x100.tif";
	open(imageStack);
	//imageTitle = getTitle();
	maskStack = "C:\\Users\\lab\\Documents\\StrainMapping\\manualVsBatch\\Seg Substack (1,11) 133x100.tif";
	open(maskStack);
	//maskTitle = getTitle();
	saveDirectory = "C:\\Users\\lab\\Documents\\StrainMapping\\manualVsBatch\\Test";
	print("deBugging turned on");
	
}else{
	// set a path for the image stack and the mask stack by user interaction
	imageStack = File.openDialog("Select image sequence . . .");
	open(imageStack);
	//imageTitle = getTitle();
	maskStack = File.openDialog("Select mask sequence . . .");
	open(maskStack);
	//maskTitle = getTitle();
	saveDirectory = getDirectory("Choose a save directory");
}

// get names for the stacks to that they can be selected later as needed
isName = File.getName(imageStack);
msName = File.getName(maskStack);

saveFile= saveDirectory+"Centroids.txt";
outputFile=File.open(saveFile);

selectWindow(isName);
imageSlices = nSlices;
//close();

selectWindow(msName);
maskSlices = nSlices;


// Get path to temp directory
  tmp = getDirectory("temp");
  if (tmp=="")
      exit("No temp directory available");

// Create a directory in temp
  tempDir = tmp+"batchStrainMapData"+File.separator;
  File.makeDirectory(tempDir);
  if (!File.exists(tempDir))
      exit("Unable to create directory");





selectWindow(msName);
//run("Copy");
selectWindow(isName);
type = bitDepth();
getDimensions(width, height, channels, slices, frames);
/*(if (maskSlices == 1){
	newImage("single_mask_stack",type, width, height, imageSlices); 
	for (m = 1; m <= imageSlices; m++){
		setSlice(m);
		run("Paste");
	}
	save(tempDir+"single_mask_stack.tif");
	maskSlices = imageSlices;
	msName = File.getName(tempDir+"single_mask_stack.tif");
	maskStack = tempDir+"single_mask_stack.tif";
}*/
while (nImages > 0) {
	selectImage(nImages);
	close();
}

//if ( imageSlices != maskSlices){
//	exit("Length of mask stack does not match length of image stack.");
//}
 

if(maskSlices > 1){
	maskCrossStack = tempDir+"crossMask.tif";
	for (i =1; i <= imageSlices-frameIncrement; i=i+interval){
		//if(i-frameIncrement > 0){
			open(maskStack, i);
			rename("firstmask");
			open(maskStack, i+frameIncrement);
			rename("lastmask");
			imageCalculator("AND create", "firstmask","lastmask");
			//run("Subtract...", "value=255");
			//setThreshold(200, 255);
			selectWindow("firstmask"); close();
			selectWindow("lastmask"); close();
			rename("nextMask");
			if(i == 1){
				rename("crossMask.tif");
				save(tempDir+"crossMask.tif");
			}else{
				run("Concatenate...", " title=temp image1=crossMask.tif image2=nextMask");
				selectWindow("temp"); rename("crossMask.tif");
				//save(tempDir+"crossMask.tif");
			}
		//}
	}
	save(tempDir+"crossMask.tif");
	selectWindow("crossMask.tif");close();
}


nSets = 0;
for (i =1; i <= imageSlices-frameIncrement; i=i+interval){
	print("Making stacks with image and masks");
	open(imageStack,i);
	if(maskSlices ==1){
		open(maskStack);
	}else{
		open(maskCrossStack,i);
	}
	name_i = "Match_"+i+".tif";
	run("Images to Stack", "name=&name_i title=[] use");
	selectWindow(name_i);
	save(tempDir+name_i);
	close();
	
	//if(i-frameIncrement > 0){
		open(imageStack,i+frameIncrement);
		if(maskSlices ==1){
			open(maskStack);
		}else{
			open(maskCrossStack, i);
			//rename("firstmask");
			//open(maskStack, i);
			//rename("lastmask");
			//imageCalculator("AND create", "firstmask","lastmask");
			////run("Subtract...", "value=255");
			////setThreshold(200, 255);
			//selectWindow("firstmask"); close();
			//selectWindow("lastmask"); close();
		}
		name_i = "Cross_"+i+".tif";
		run("Images to Stack", "name=&name_i title=[] use");
		selectWindow(name_i);
		save(tempDir+name_i);
		close();
		nSets++;
	//}
}

Cx = newArray(nSets);
Cy = newArray(nSets);
print(width);
print(height);
counter = 0;
for(s = 0; s < imageSlices; s=s+interval){
	if(counter<nSets){
		IJ.log("s: "+s);
		xSum=0;
		ySum=0;
		brightPixels=0;
		open(tempDir+"Match_"+(s+1)+".tif",2);
		for (x = 1; x < width; x++){
			for(y = 1; y < height; y++){
				pixValue = getPixel(x,y);
				if(pixValue>0){
					xSum = xSum+x;
					ySum = ySum+y;
					brightPixels++;
				}
			}
		}
		Cx[counter]=xSum/brightPixels;
		Cy[counter]=ySum/brightPixels;
		print(outputFile,Cx[counter]+"\t"+Cy[counter]);
		counter++;
	}
}
File.close(outputFile);

label = split(isName,".");
sD = split(saveDirectory,"\\");
dirName = sD[0]+File.separator;
for(m = 1; m < lengthOf(sD); m++){
		dirName = dirName+sD[m]+File.separator;
	}
//print(dirName);
if(deBug){
	//newImage("TestSave", "8-bit White", 220, 225, 3);
	//save(dirName+"TestSave.tif");
	print(nSets);
}

setBatchMode(false);
//c = 1;
for (j = 1; j <= (imageSlices-frameIncrement); j=j+interval){
	//if (c <= nSets){
		if (verbose){
			directTransSave = dirName+label[0]+"_"+ (j+frameIncrement)+"_direct_transf.txt";
			inverseTransSave = dirName +label[0]+"_"+ j+"_inverse_transf.txt";
		}else{
			directTransSave = tempDir+label[0]+"_"+ (j+frameIncrement)+"_direct_transf.txt";
			inverseTransSave = tempDir +label[0]+"_"+ j+"_inverse_transf.txt";
		}
		//the code right below this is a clunky way of dealing with the first run being different
		//it should be commented out if a better fix comes along
		if (j==1){
			targetImage = "Match_"+j+".tif";
			sourceImage = "Cross_"+j+".tif";
			trashSave = dirName+"trash.txt";
			open(tempDir+sourceImage);
			open(tempDir+targetImage);
			run("bUnwarpJ", "source_image=&sourceImage target_image=&targetImage registration=Accurate image_subsample_factor=0 initial_deformation=Fine final_deformation=Fine divergence_weight=0 curl_weight=0 landmark_weight=0 image_weight=1 consistency_weight=10 stop_threshold=0.005 save_transformations save_direct_transformation=["+trashSave+"] save_inverse_transformation=["+trashSave+"]");
			selectWindow("Registered Target Image");
			close();
			selectWindow("Registered Source Image");
			close();
			 if (isOpen("Log")) { 
        		 selectWindow("Log"); 
       	 		 run("Close"); 
			} 
			selectWindow(sourceImage);
			close();
			selectWindow(targetImage);
			close();

		}
		//end of trash run
		run("Collect Garbage");
		targetImage = "Match_"+j+".tif";
		sourceImage = "Cross_"+j+".tif";
		open(tempDir+sourceImage);
		open(tempDir+targetImage);
		run("bUnwarpJ", "source_image=&sourceImage target_image=&targetImage registration=Accurate image_subsample_factor=0 initial_deformation=Fine final_deformation=Fine divergence_weight=0 curl_weight=0 landmark_weight=0 image_weight=1 consistency_weight=10 stop_threshold=0.005 save_transformations save_direct_transformation=["+directTransSave+"] save_inverse_transformation=["+inverseTransSave+"]");
		selectWindow("Registered Target Image");
		close();
		selectWindow("Registered Source Image");
		close();
		 if (isOpen("Log")) { 
        	 selectWindow("Log"); 
       	 	 run("Close"); 
		} 
		call("bunwarpj.bUnwarpJ_.convertToRawTransformationMacro", tempDir+sourceImage, tempDir+targetImage,directTransSave, directTransSave);
	
		selectWindow(sourceImage);
		close();
		selectWindow(targetImage);
		close();
		savePath = runMacro("DisplacementMaps_eps_x_y_xy_only", directTransSave);
		runMacro("StrainMapsFromDisplacementMaps_eps_x_y_xy_only", savePath);
		selectWindow("rawX"); close();
		selectWindow("rawY"); close();
		run("Collect Garbage");
	//}
}

//c2 = 1;
setBatchMode(true);
for (m= 1; m <= (imageSlices-frameIncrement); m=m+interval){
	//if(c2 <=nSets){
		
		if (verbose){
			directTransFile = dirName+label[0]+"_"+ (m+frameIncrement)+"_direct_transf";
			directTransFilePrefix = label[0]+"_"+ (m+frameIncrement)+"_direct_transf";
			saveDir = dirName;
		}else{
			directTransFile = tempDir+label[0]+"_"+ (m+frameIncrement)+"_direct_transf";
			directTransFilePrefix = label[0]+"_"+ (m+frameIncrement)+"_direct_transf";
			saveDir = tempDir;
		}

		if (maskSlices ==1){
			open(maskStack);
		}else{
			open(maskCrossStack,m);
		}
		save(tempDir+"mask.tif"); close();
		open(tempDir+"mask.tif");

		//deltaxName = directTransFilePrefix+"_deltax.tif";
		//selectWindow("rawX");
		//save(saveDir+deltaxName); close();

		//deltayName = directTransFilePrefix+"_deltay.tif";
		//selectWindow("rawY");
		//save(saveDir+deltayName); close();
	
		epsxName = directTransFilePrefix+"_epsx.tif";
		epsxPath = directTransFile+"_epsx.tif";
		open(epsxPath);
		imageCalculator("Multiply create 32-bit", "mask.tif",epsxName);
		selectWindow("Result of mask.tif");
		run("Divide...", "value=255");
		save(saveDir+epsxName); close();
		selectWindow(epsxName); close();
	
		epsyName = directTransFilePrefix+"_epsy.tif";
		epsyPath = directTransFile+"_epsy.tif";
		open(epsyPath);
		imageCalculator("Multiply create 32-bit", "mask.tif",epsyName);
		selectWindow("Result of mask.tif");
		run("Divide...", "value=255");
		save(saveDir+epsyName); close();
		selectWindow(epsyName); close();
	
		epsxyName = directTransFilePrefix+"_epsxy.tif";
		epsxyPath = directTransFile+"_epsxy.tif";
		open(epsxyPath);
		imageCalculator("Multiply create 32-bit", "mask.tif",epsxyName);
		selectWindow("Result of mask.tif");
		run("Divide...", "value=255");
		save(saveDir+epsxyName); close();
		selectWindow(epsxyName); close();
		
		selectWindow("mask.tif"); close();

	//}
}

setBatchMode(false);
image_count = nSets*9;

run("Image Sequence...", "open=["+saveDir+epsxName+"] number=&image_count starting=1 increment=1 scale=100 file=t_transf_deltaX.tif or=[] sort");
rename("deltax");
save(dirName+"deltax.tif"); close();


run("Image Sequence...", "open=["+saveDir+epsxName+"] number=&image_count starting=1 increment=1 scale=100 file=t_transf_deltaY.tif or=[] sort");
rename("deltay");
save(dirName+"deltay.tif"); close();


run("Image Sequence...", "open=["+saveDir+epsxName+"] number=&image_count starting=1 increment=1 scale=100 file=t_transf_epsx.tif or=[] sort");
rename("epsx");
getStatistics(area, mean, min, max, std, histogram);
if(abs(max)>abs(min)){
	upper = max;
	lower = -max;
}else{
	upper = abs(min);
	lower = -abs(min);
}
if( getPixel(0,0)==0 && getPixel(0,1)==0){
	setPixel(0,0,upper);
	setPixel(0,1,lower);
}else{
	IJ.log("Unable to balance histogram for epsx");
}
//setAutoThreshold("Default");
//save(dirName+"epsx_test.tif"); //close();
//image_count++;

run("Image Sequence...", "open=["+saveDir+epsxName+"] number=&image_count starting=1 increment=1 scale=100 file=t_transf_epsy.tif or=[] sort");
rename("epsy");
getStatistics(area, mean, min, max, std, histogram);
if(abs(max)>abs(min)){
	upper = max;
	lower = -max;
}else{
	upper = abs(min);
	lower = -abs(min);
}
if( getPixel(0,0)==0 && getPixel(0,1)==0){
	setPixel(0,0,upper);
	setPixel(0,1,lower);
}else{
	IJ.log("Unable to balance histogram for epsy");
}
//setAutoThreshold("Default");
//save(dirName+"epsy_test.tif"); //close();
//image_count++;

run("Image Sequence...", "open=["+saveDir+epsxName+"] number=&image_count starting=1 increment=1 scale=100 file=t_transf_epsxy.tif or=[] sort");
rename("epsxy");
getStatistics(area, mean, min, max, std, histogram);
if(abs(max)>abs(min)){
	upper = max;
	lower = -max;
}else{
	upper = abs(min);
	lower = -abs(min);
}
if( getPixel(0,0)==0 && getPixel(0,1)==0){
	setPixel(0,0,upper);
	setPixel(0,1,lower);
}else{
	IJ.log("Unable to balance histogram for epsxy");
}
//setAutoThreshold("Default");
//save(dirName+"epsxy_test.tif"); //close();
//image_count++;


run("Concatenate...", "  title=[eps_xy] image1=epsx image2=epsy image3=epsxy image5=[-- None --]");
setAutoThreshold("Default");
run("Make Substack...", "delete slices=1-"+nSets);
save(dirName+"epsx.tif"); close();
run("Make Substack...", "delete slices=1-"+nSets);
save(dirName+"epsy.tif"); close();
selectWindow("eps_xy");
save(dirName+"epsxy.tif"); close();


if(deBug){
	//open(tempDir+"Cross_1.tif");
	//open(tempDir+"Match_1.tif");
	//run("bUnwarpJ", "source_image=Cross_1.tif target_image=Match_1.tif registration=Accurate image_subsample_factor=0 initial_deformation=[Very Coarse] final_deformation=Fine divergence_weight=0 curl_weight=0 landmark_weight=0 image_weight=1 consistency_weight=10 stop_threshold=0.005 save_transformations save_direct_transformation=[C:\\Users\\lab\\Documents\\bUnwarpJTrial\\ShirleyMa100714 Animal cap x0.8 Scion x2\\Pos11\\BulkSnakeMask\\OutputTest\\Cross_1_direct_transf.txt] save_inverse_transformation=[C:\\Users\\lab\\Documents\\bUnwarpJTrial\\ShirleyMa100714 Animal cap x0.8 Scion x2\\Pos11\\BulkSnakeMask\\OutputTest\\Match_1_inverse_transf.txt]");
	//run("bUnwarpJ", "load=[C:\\Users\\lab\\Documents\\bUnwarpJTrial\\ShirleyMa100714 Animal cap x0.8 Scion x2\\Pos11\\BulkSnakeMask\\Cross_1_direct_transf.txt] saving=[C:\\Users\\lab\\Documents\\bUnwarpJTrial\\ShirleyMa100714 Animal cap x0.8 Scion x2\\Pos11\\BulkSnakeMask\\Cross_1_direct_transf]");
}

if (cleanFinish){
	list = getFileList(tempDir);
	for (k=0; k<list.length; k++)
   		 ok = File.delete(tempDir+list[k]);
	ok = File.delete(tempDir);
	if (File.exists(tempDir))
     		 exit("Unable to delete temporary directory");
 	 else
     		 print("Temporary directory and files successfully deleted");
}



lastImgOpenNum = j-1;
selectWindow("Match_"+lastImgOpenNum+"-1.tif");close();
run("Collect Garbage");
