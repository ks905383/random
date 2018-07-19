# random
Repository for utilities and other scripts that aren't project-specific. 

------------------
Included functions: 
------------------
R: 
fix_estout - turn STATA estout output into a quickly useable list of data frames that can be used for plotting (esp. through ggplot2) or further analysis. In the package [various.utilities]. 

MATLAB:
as_vector - a generalized (:) operator that works on any inputted array

data_colormap - a better, more controllable way to assign colors to values for plotting

loc_descriptor - a way to get a useful string location description for any lat/lon pair using google maps api

map_values - a one-line, fast way to map geographically stored values

pixel_overlaps / geo_agg - an efficient way to find the overlap between a grid and a struct of geographic information (say, from a shapefile) + a related function to spatially aggregate a variable stored on that grid to the geographic shapes

derive_bounds - a function to calculate the edges of pixels only given in 2-D array form (currently only debugged enough to work with pixel_overlaps / geo_agg above)

standard_colorbar - a one-line, fast way to get an appropriately-placed and sized colorbar
