# strain-mapping

<a href="https://github.com/tstepien/strain-mapping/"><img src="https://img.shields.io/badge/GitHub-tstepien%2Fstrain--mapping-blue.svg" /></a> <a href="https://doi.org/10.1101/460774"><img src="https://img.shields.io/badge/bioRxiv-460774-orange.svg" /></a> <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" /></a>

## Programs

+ area_extraction
  + [gettingareas.ijm](area_extraction/gettingareas.ijm): run this program in ImageJ to extract the areas of a segmented image in pixels
+ segmentation
  + [SingleRoiBatchLevelSetMacro.ijm](segmentation/SingleRoiBatchLevelSetMacro.ijm): run this program in ImageJ to segment a time-lapse sequence with one ROI opened
  + [BatchLevelSetMacro.ijm](segmentation/BatchLevelSetMacro.ijm): run this program in ImageJ to segment a time-lapse sequence with a small box ROI and large box ROI
+ strain_maps
  + [DisplacementMaps.txt](strain_maps/DisplacementMaps.txt): place this file into the ImageJ>macros folder
  + [StrainMapsFromDisplacementMaps.txt](strain_maps/StrainMapsFromDisplacementMaps.txt): place this file into the ImageJ>macros folder
  + [Batch_Strain_Maps.ijm](strain_maps/Batch_Strain_Maps.ijm): run this program in ImageJ to calculate the strain maps for a time-lapse image

## Licensing
Copyright 2012-2019 [Lance Davidson](http://github.com/ladavidson/), [Holley Lynch](http://github.com/helynch), [Tracy Stepien](http://github.com/tstepien/).  This is free software made available under the MIT License. For details see the LICENSE file.
