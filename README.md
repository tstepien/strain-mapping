# strain-mapping

<a href="https://github.com/tstepien/strain-mapping/"><img src="https://img.shields.io/badge/GitHub-tstepien%2Fstrain--mapping-blue.svg" /></a> <a href="https://doi.org/10.1101/460774"><img src="https://img.shields.io/badge/bioRxiv-460774-orange.svg" /></a> <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" /></a>

The code contained in the strain-mapping project was developed for work in the [Mechanics of Morphogenesis/Davidson Lab](http://mechmorpho.org/) and described in various papers including:
><a href="http://math.arizona.edu/~stepien/">Tracy L. Stepien</a>, [Holley E. Lynch](https://www.stetson.edu/other/faculty/holley-lynch.php), Shirley X. Yancey, Laura Dempsey, and [Lance A. Davidson](http://mechmorpho.org/), Using a continuum model to decipher the mechanics of embryonic tissue spreading from time-lapse image sequences: An approximate Bayesian computation approach, under review in *PLOS ONE*, bioRxiv:[460774](https://doi.org/10.1101/460774).

A strain mapping method is developed to calculate the deformation of a tissue via estimates of the engineering/Cauchy strains ε_{xx}, ε_{yy}, ε_{xy}, and ε_{yx}, and the displacement gradient ∇u between two images in a time-lapse sequence.

## Necessary Items

*Images:* A time-lapse sequence of images is needed that is landmark-rich image, for example, with textures of pigmentation, sub-cellular organelles, dye, or fluorescence.

*Applications:* The code in this package is developed for [ImageJ](https://imagej.nih.gov/ij/)/[Fiji](https://fiji.sc/) and [MATLAB](https://www.mathworks.com/products/matlab.html). Furthermore, [bUnwarpJ](https://imagej.net/BUnwarpJ) is a required plug-in for ImageJ/Fiji.

## Strain Mapping Method

### Segmentation

Before strain mapping can be computed, the first step is to segment the time-lapse sequence of images so that a mask is created showing where the tissue is in the image. The relevant code is located in the [segmentation](segmentation/) folder:

+ [SingleRoiBatchLevelSetMacro.ijm](segmentation/SingleRoiBatchLevelSetMacro.ijm): run this program in ImageJ to segment a time-lapse sequence with one ROI opened
+ [BatchLevelSetMacro.ijm](segmentation/BatchLevelSetMacro.ijm): run this program in ImageJ to segment a time-lapse sequence with a small box ROI and large box ROI

### Strain Mapping

The relevant code for strain mapping is located in the [strain_maps](strain_maps/) folder:

+ [DisplacementMaps.txt](strain_maps/DisplacementMaps.txt): place this file into the ImageJ>macros folder
+ [StrainMapsFromDisplacementMaps.txt](strain_maps/StrainMapsFromDisplacementMaps.txt): place this file into the ImageJ>macros folder
+ [Batch_Strain_Maps.ijm](strain_maps/Batch_Strain_Maps.ijm): run this program in ImageJ to calculate the strain maps for a time-lapse image

## Other Image Analysis

### Area Extraction

The relevant code for calculating the area of segmented images is located in the [area_extraction](area_extraction/) folder:

+ [gettingareas.ijm](area_extraction/gettingareas.ijm): run this program in ImageJ to extract the areas of a segmented image in pixels

### Boundary Extraction

The relevant code for finding the boundary locations of segmented images is located in the [boundary_extraction](boundary_extraction/) folder:

+ [gettingboundaries.ijm](boundary_extraction/gettingboudaries.ijm): run this program in ImageJ to extract the boundary locations of a segmented image in pixels

### Conversion of ImageJ data to MATLAB


## Licensing
Copyright 2012-2019 [Lance Davidson](http://github.com/ladavidson/), [Holley Lynch](http://github.com/helynch), [Tracy Stepien](http://github.com/tstepien/).  This is free software made available under the MIT License. For details see the LICENSE file.
