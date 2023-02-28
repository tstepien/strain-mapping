//	determining amount to crop or extend the images to
//	have at least cropValue number of pixels between the
//	largest bounding box (for each side) and the edge of
//	the image
//
//	It will now create the cropped mask and image file.
//	It also clears outside of the main explant.
//--------------------------------------------------------------------------------


cropValue = 200;


setBatchMode(true);

// set a path for the mask stack by user interaction
maskStack = File.openDialog("Select mask sequence . . .");
open(maskStack);
rename("mask");
open(maskStack);
rename("mask2");
selectWindow("mask");

// get names for the stacks to that they can be selected later as needed
msName = File.getName(maskStack);
defaultName = split(msName,".");

savePath = getDirectory("Select a Save Folder");
saveName = getString("File identifier", defaultName[0]);

//selectWindow(msName);
maskSlices = nSlices;

txtPath = savePath+saveName+"_crop_extend.txt";
f = File.open(txtPath);

call("java.lang.System.gc");
//open(maskStack);


	for (k = 1; k <= maskSlices; k++){
		setSlice(k);
		Cx=0;
		Cy=0;
	
		if (k==1){
			imageWidth = getWidth();
			imageHeight = getHeight();
		}
		brightPixels = 0;
		xSum = 0;
		ySum = 0;
		for (x = 1; x < imageWidth; x++){
			for(y = 1; y < imageHeight; y++){
				pixValue = getPixel(x,y);
				if(pixValue>0){
					xSum = xSum+x;
					ySum = ySum+y;
					brightPixels++;
				}
			}
		}
		Cx=xSum/brightPixels;
		Cy=ySum/brightPixels;
		//makeRectangle(0, 0, 1, 1);
		//IJ.log("Cx: "+Cx+" Cy: "+Cy);
		run("Select None");
		doWand(Cx,Cy);
		run("Clear Outside", "slice");

		//run("Create Selection");
		//run("Make Inverse");
		run("To Bounding Box");

		run("Set Measurements...", "area bounding redirect=None decimal=3");
		run("Measure");
		//getSelectionBounds(valBX,valBY,valWidth,valHeight);
		valBX = getResult("BX", k-1);
		valWidth = getResult("Width", k-1);
		setResult("BX+Width", k-1, valBX+valWidth);

		valBY = getResult("BY", k-1);
		valHeight = getResult("Height", k-1);
		setResult("BY+Height", k-1, valBY+valHeight);

		//close();
		 //while (nImages>0) { 
        //			 selectImage(nImages); 
       //  			 close(); 
  		//  } 
	}

run("Summarize");

maxrow = nResults-1;
minrow = nResults-2;

minLeft = getResult("BX", minrow);
minTop = getResult("BY", minrow);

maxRight = getResult("BX+Width", maxrow);
maxBottom = getResult("BY+Height", maxrow);

diffLeft = cropValue-minLeft;
if(minLeft>=cropValue){
	print(f, "Left: Crop "+diffLeft+" pixels");
}else{
	print(f, "Left: Extend +"+diffLeft+" pixels");
}

diffTop = cropValue-minTop;
if(minTop>=cropValue){
	print(f, "Top: Crop "+diffTop+" pixels");
}else{
	print(f, "Top: Extend +"+diffTop+" pixels");
}

diffRight = cropValue-(imageWidth-maxRight);
if(imageWidth-maxRight>=cropValue){
	print(f, "Right: Crop "+diffRight+" pixels");
}else{
	print(f, "Right: Extend +"+diffRight+" pixels");
}

diffBottom = cropValue-(imageHeight-maxBottom);
if(imageHeight-maxBottom>=cropValue){
	print(f, "Bottom: Crop "+diffBottom+" pixels");
}else{
	print(f, "Bottom: Extend +"+diffBottom+" pixels");
}

File.close(f);

Rwidth = imageWidth+diffRight;
Bheight = imageHeight+diffBottom;
Lwidth = Rwidth+diffLeft;
Theight = Bheight+diffTop;

selectWindow("mask2"); 
run("Canvas Size...", "width=&Rwidth height=&Bheight position=Top-Left zero");
run("Canvas Size...", "width=&Lwidth height=&Theight position=Bottom-Right zero");



selectWindow("mask2"); 
save(savePath+defaultName[0]+"_crop_extend.tif"); close;
selectWindow("Results");
run("Close");

imageStack = File.openDialog("Select corresponding image sequence . . .");
open(imageStack);
rename("image");
selectWindow("image");
imName = File.getName(imageStack);
defaultName2 = split(imName,".");
//saveName2 = getString("File identifier", defaultName2[0]);
run("Canvas Size...", "width=&Rwidth height=&Bheight position=Top-Left zero");
run("Canvas Size...", "width=&Lwidth height=&Theight position=Bottom-Right zero");
selectWindow("image"); 
save(savePath+defaultName2[0]+"_crop_extend.tif"); close;


setBatchMode("exit and display");

while (nImages>0) { 
	selectImage(nImages);
	close();
}