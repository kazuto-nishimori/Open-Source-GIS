::This batch file automates the hydrological analysis discussed on my github page, kazuto-nishimori.github.io. It is required to install the latest version of SAGA, an opensource physical GIS software. This file will use DEM files in the saga format (.sgrd) and performs hillshade, sink route, sink fill, flow accumulation and channel network. Enjoy!


::set the path to your SAGA program
SET PATH=%PATH%;c:\saga6

::set the prefix to use for all names and outputs
SET pre=ASTKilimanjaro

::set the directory in which you want to save ouputs. In the example below, part of the directory name is the prefix you entered above
SET od=W:\Week4\%pre%

::set the directory of the DEM file
SET dem=W:\Week4\ASTKilimanjaroDEM\ASTKilimanjaroDEMmosaic.sgrd

:: the following creates the output directory if it doesn't exist already
if not exist %od% mkdir %od%





:: Let us begin the processing. We will create a hillshade file. 
saga_cmd ta_lighting 0 -ELEVATION=%dem% -SHADE=%od%\%pre%HS.sgrd -METHOD=0 -POSITION=0 -AZIMUTH=315.000000 -DECLINATION=45.000000 -EXAGGERATION=1.000000 -UNIT=0 -SHADOW=0 -NDIRS=8 -RADIUS=10.000000 

:: Sink drainage route created and saved
saga_cmd ta_preprocessor 1 -ELEVATION=%dem% -SINKROUTE=%od%\%pre%SDR.sgrd -THRESHOLD=0 -THRSHEIGHT=100.000000

:: Sinks filled and saved
saga_cmd ta_preprocessor 2 -DEM=%dem% -SINKROUTE=%od%\%pre%SDR.sgrd -DEM_PREPROC=%od%\%pre%SDEM.sgrd -METHOD=1 -THRESHOLD=0 -THRSHEIGHT=100.000000

:: Flow accumulation created and saved
saga_cmd ta_hydrology 0 -ELEVATION=%od%\%pre%SDEM.sgrd  -SINKROUTE=%od%\%pre%SDR.sgrd  -FLOW=%od%\%pre%FA.sgrd -STEP=1 -FLOW_UNIT=0  -METHOD=4 -LINEAR_DO=1 -LINEAR_MIN=500 -CONVERGENCE=1.100000
::saga_cmd ta_hydrology 0 -ELEVATION=%dem% -SINKROUTE=%od%\%pre%SDR.sgrd  -WEIGHTS=NULL -FLOW=%od%\%pre%FA.sgrd -VAL_INPUT=NULL -ACCU_MATERIAL=NULL -STEP=1 -FLOW_UNIT=0 -FLOW_LENGTH=NULL -LINEAR_VAL=NULL -LINEAR_DIR=NULL -METHOD=4 -LINEAR_DO=1 -LINEAR_MIN=500 -CONVERGENCE=1.100000

:: Channel network, route and vector version of network created and saved
saga_cmd ta_channels 0 -ELEVATION=%od%\%pre%SDEM.sgrd -SINKROUTE=%od%\%pre%SDR.sgrd -CHNLNTWRK=%od%\%pre%CN.sgrd -CHNLROUTE=%od%\%pre%CR.sgrd -SHAPES=%od%\%pre%CS.sgrd -INIT_GRID=%od%\%pre%FA.sgrd -INIT_METHOD=2 -INIT_VALUE=1000  -MINLEN=10

::Difference between the sink filled DEM and flow accumulation calculated and saved.
saga_cmd grid_calculus 3 -A=%od%\%pre%SDEM.sgrd -B=%od%\%pre%FA.sgrd -C=%od%\%pre%DIF.sgrd



::print a completion message so that uneasy users feel confident that the batch script has finished!
ECHO Processing Complete!
PAUSE