//	This macro should be run with a saved image set after the user has defined an
//	roi for seeding the active contour program. This assumes the contours
//	will move inward thus a contour larger than the largest frame is a good start.
//	The macro will output an image set with contours drawn on the original
//	image and a mask image based on those contours. It is recommended that
//	the user try the level set program on a frame or two prior to running to
//	find a seed oval that works and the proper convergence. Not all data sets
//	may be able to be fit by a single roi.
//--------------------------------------------------------------------------------
//       User-Defined Variables
//--------------------------------------------------------------------------------
// In put the convergence criterion. The smaller this number the greater the chance
// that the program will shoot past the desired contour. The larger the number the 
// greater the chance that the program will never reach the desired contour.
	convergence = 0.002;
//--------------------------------------------------------------------------------



setBatchMode(true);


imageStack = File.openDialog("Select image sequence . . .");
open(imageStack);
isName = File.getName(imageStack);

savePath = getDirectory("Select a Save Folder");

totalSlices = nSlices;

//print(totalSlices);

roiManager("Select",0);

getSelectionBounds(x0, y0, width0, height0);


tmp = getDirectory("temp");
if (tmp=="")
	exit("No temp directory available");

// Create a directory in temp
tempDir = tmp+"BatchLevelSet"+File.separator;
File.makeDirectory(tempDir);
if(!File.exists(tempDir))
	exit("Unable to create directory");

print(tempDir);
call("java.lang.System.gc"); 

	for (k = 1; k <= totalSlices; k++){
		open(imageStack,k);
		rename(k);
		selectWindow(k);
		roiManager("Select",0);
		run("Level Sets", "method=[Active Contours] use_level_sets grey_value_threshold=5 distance_threshold=0.50 advection=1 propagation=1 curvature=1.25 grayscale=0 convergence=&convergence region=inside");
		//print("I arrived out of the snake");
		selectWindow("Segmentation of "+ k);
		save(tempDir+"Seg_"+k+".tif"); close();
		selectWindow("Segmentation progress of "+ k);
		save(tempDir+"Draw_"+k+".tif"); close();
		run("Close");
		//selectWindow("Segmentation progress of "+ k);
		//save(savePath+"Draw_"+j+"_"+k+".tif"); 
		activeImage = getTitle();
		print("Pre-close active image is:",activeImage);
		close();
		activeImage = getTitle();
		print("Post-close active image is:",activeImage);
		//selectWindow("Segmentation progress of "+k); close();
		//selectWindow(k); close();
		//roiManager("Delete");
		//roiManager("Open", tempDir+"CompleteRoiSet.zip");
		call("java.lang.System.gc"); 
		//close("*"+k);
		 while (nImages>0) { 
        			 selectImage(nImages); 
         			 close(); 
  		  } 
	}
	firstDraw = tempDir+"Draw_"+k+".tif";
	firstSeg = tempDir+"Seg_"+k+".tif";
	seqDraw = savePath+"Draw.tif";
	seqSeg = savePath+"Seg.tif";
	run("Image Sequence...", "open=&firstDraw number=10000 starting=1 increment=1 scale=100 file=Draw_ or=[] sort");
	save(seqDraw); close();
	run("Image Sequence...", "open=&firstSeg number=10000 starting=1 increment=1 scale=100 file=Seg_ or=[] sort");
	save(seqSeg); close();

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


