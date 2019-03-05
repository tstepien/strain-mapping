//	getting areas
//--------------------------------------------------------------------------------



setBatchMode(true);

setOption("JFileChooser", true); // Mac OS 10.11 removed title bar from file open windows

// set a path for the mask stack by user interaction
maskStack = File.openDialog("Select mask sequence . . .");
open(maskStack);

// get names for the stacks to that they can be selected later as needed
msName = File.getName(maskStack);

savePath = getDirectory("Select a Save Folder");
saveName = getString("File identifier","Pos")
scalingpxpermicron = getNumber("Scaling (px/micron):",0.177);
scalingsq = scalingpxpermicron*scalingpxpermicron;

setOption("JFileChooser", false);

selectWindow(msName);
maskSlices = nSlices;

txtPath = savePath+saveName+"_areas.txt";
f = File.open(txtPath);

call("java.lang.System.gc");

	for (k = 1; k <= maskSlices; k++){
		open(maskStack,k);
		rename("mask");
		selectWindow("mask");

		run("Create Selection");

		run("Make Inverse");
		run("Measure");
		areareg = getResult("Area",k-1);
		areareg = areareg/scalingsq;
		print(f, areareg);

		close();
		 while (nImages>0) { 
        			 selectImage(nImages); 
         			 close(); 
  		  } 
	}

selectWindow("Results");
run("Close");

setBatchMode("exit and display");

 while (nImages>0) { 
 			 selectImage(nImages); 
       			 close();
 }
