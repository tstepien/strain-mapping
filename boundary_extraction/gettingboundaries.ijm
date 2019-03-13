//	getting boundaries
//--------------------------------------------------------------------------------



setBatchMode(true);


imageStack = File.openDialog("Select mask sequence . . .");
open(imageStack);
isName = File.getName(imageStack);

savePath = getDirectory("Select a Save Folder");

sliceInitNumber = getNumber("Which number slice is the starting image?", 1)

totalSlices = nSlices;

call("java.lang.System.gc");

	for (k = 1; k <= totalSlices; k++){
		open(imageStack,k);
		rename(k);
		selectWindow(k);

		if (k==1){
			imageWidth = getWidth();
			imageHeight = getHeight();
		}

		for (x = 1; x < imageWidth; x++){
			for(y = 1; y < imageHeight; y++){
				pixValue = getPixel(x,y);
				if(pixValue>0){
					xVal = x;
					yVal = y;
					break;
				}
			}
		}

		doWand(xVal, yVal);
		run("Interpolate", "interval=0.5 smooth");

		sliceNumber = sliceInitNumber + k - 1;
     		txtPath = savePath+sliceNumber+".txt"; 
		saveAs("XY Coordinates",txtPath);
		close();
		while (nImages>0) { 
			selectImage(nImages); 
			close(); 
		} 
	}


setBatchMode("exit and display");

while (nImages>0) { 
	selectImage(nImages); 
	close();
}

print("Extracting boundaries successfully completed");