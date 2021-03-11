/*
There are some interesting points to remember about using the geography data type. 
- The first point is that since the geography data type is implemented as a .NET CLR data type, the methods are case sensitive and an error will be returned if a method is called otherwise. 
- The second point is that the methods must be called via geography::method since it is a static method. 
- Finally, and perhaps most important, is the order in which the coordinates are entered in the data type. 
The functions used for the geography data types view coordinates as {X,Y} coordinates. 
In order to properly document the locations of the earthquakes I will need to present the data as longitude first, then latitude, which is different from how most people think of earth-related coordinates. 
As for the Spatial Reference Identifier, the one that is used for the planet Earth is the World Geodetic System 1984 (WGS 84), represented in the sys.spatial_reference_systems table as 4326.
*/



SELECT * from  sys.spatial_reference_systems 
    WHERE spatial_reference_id = 4326 
    
/*
well_known_text:

GEOGCS["WGS 84", 
    DATUM["World Geodetic System 1984", ELLIPSOID["WGS 84", 6378137, 298.257223563]], 
    PRIMEM["Greenwich", 0], 
    UNIT["Degree", 0.0174532925199433]]
*/

DECLARE @g geometry;
SET @g = geometry::STGeomFromText('LINESTRING(0 0, 0 1, 1 0)', 4326);
SELECT @g, @g.ToString()


SELECT geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656)', 4326)



CREATE TABLE dbo.EarthquakeData 
( 
     EarthquakeID INT IDENTITY(1,1) 
          CONSTRAINT PK_EarthquakeData_EarthquakeID PRIMARY KEY 
     , EarthquakeDateTime SMALLDATETIME NOT NULL 
     , EarthquakeDescription VARCHAR(250) NOT NULL 
     , EarthquakeInformation GEOGRAPHY NOT NULL 
)

SELECT * FROM EarthquakeData 

INSERT INTO EarthquakeData (EarthquakeDateTime,EarthquakeDescription,EarthquakeInformation) VALUES 
(GETDATE(),'1', geography::STGeomFromText('POINT(-81.13 -6.57 15.0 6.0)',4326))
INSERT INTO EarthquakeData (EarthquakeDateTime,EarthquakeDescription,EarthquakeInformation) VALUES 
(GETDATE(),'2', geography::STGeomFromText('POINT(-177.33 -20.78 10.0 5.5)',4326))
INSERT INTO EarthquakeData (EarthquakeDateTime,EarthquakeDescription,EarthquakeInformation) VALUES 
(GETDATE(),'3', geography::STGeomFromText('POINT(178.32 -16.21 21.8 5.7)',4326))
INSERT INTO EarthquakeData (EarthquakeDateTime,EarthquakeDescription,EarthquakeInformation) VALUES 
(GETDATE(),'4', geography::STGeomFromText('POINT(-72.98 6.72 161.2 5.0)',4326))
INSERT INTO EarthquakeData (EarthquakeDateTime,EarthquakeDescription,EarthquakeInformation) VALUES 
(GETDATE(),'5', geography::STGeomFromText('POINT(126.40 3.90 20.0 7.2)',4326))
INSERT INTO EarthquakeData (EarthquakeDateTime,EarthquakeDescription,EarthquakeInformation) VALUES 
(GETDATE(),'6', geography::STGeomFromText('POINT(126.50 3.98 35.0 5.6)',4326))

SELECT * FROM EarthquakeData 

SELECT 
    EarthquakeID, EarthquakeInformation, 
    CONVERT(varchar(max), EarthquakeInformation) AS Point 
    from EarthquakeData

SELECT 
    EarthquakeID, EarthquakeInformation, 
    CONVERT(varchar(max), EarthquakeInformation) AS Point,
    EarthquakeInformation.Lat AS Latitude,
    EarthquakeInformation.Long AS Longitude,
    EarthquakeInformation.Z AS Depth,
    EarthquakeInformation.M AS Magnitude
    from EarthquakeData

    
SELECT * FROM quak2000

