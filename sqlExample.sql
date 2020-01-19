--
-- File generated with SQLiteStudio v3.2.1 on Sun Jan 19 14:38:54 2020
--
-- Text encoding used: UTF-8
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Table: customers
CREATE TABLE customers (
    Zip    INTEGER,
    CustID INTEGER
);


-- Table: orders
CREATE TABLE orders (
    OrderType,
    OrderID,
    PartID,
    Quantity,
    CustID,
    Date
);


-- Table: parts
CREATE TABLE parts (
    Name,
    Price,
    PartID,
    UPC
);


-- Table: States
CREATE TABLE States (
    [State Code]         INTEGER PRIMARY KEY,
    [State Abbreviation] TEXT,
    [State Name]         TEXT
);


-- Table: ZipCodes
CREATE TABLE ZipCodes (
    zip       INT     PRIMARY KEY,
    city      TEXT,
    state     TEXT,
    latitude  NUMERIC,
    longitude NUMERIC
);


-- View: HW08Q01
CREATE VIEW HW08Q01 AS
    SELECT *
      FROM Q040SalesByGeoZip
     WHERE 22500 > (69 * (33.4307 - latitude) + (69 * 0.0559626) );


-- View: Q010SalesValueByOrder
CREATE VIEW Q010SalesValueByOrder AS
    SELECT OrderType,
           OrderID,
           orders.PartID,
           Quantity,
           CustID,
           Date,
           Name,
           Price,
           UPC,
           orders.Quantity * parts.Price AS SalesValue,
           OrderType
      FROM orders
           INNER JOIN
           parts ON parts.PartID = orders.PartID;


-- View: Q020RRSalesByCustomer
CREATE VIEW Q020RRSalesByCustomer AS
    SELECT CustID,
           SUM(SalesValue) AS RRSales,
           UPC,
           OrderType
      FROM Q010SalesValueByOrder
     WHERE OrderType = 'RR'
     GROUP BY CustID;


-- View: Q020SalesByCustomer
CREATE VIEW Q020SalesByCustomer AS
    SELECT CustID,
           OrderType,
           CASE WHEN OrderType = 'EO' THEN SUM(SalesValue) ELSE 0 END AS EOSales,
           CASE WHEN OrderType = 'RR' THEN SUM(SalesValue) ELSE 0 END AS RRSales
      FROM Q010SalesValueByOrder
     GROUP BY CustID,
              OrderType;


-- View: Q030SalesByType
CREATE VIEW Q030SalesByType AS
    SELECT RR.CustID,
           RR.RRSales,
           EO.EOSales,
           ROUND(100 * (EO.EOSales / RR.RRSales) ) AS RatioEmergencySale,
           RR.RRSales + EO.EOSales AS Sales
      FROM Q020SalesByCustomer AS RR
           INNER JOIN
           Q020SalesByCustomer AS EO ON EO.CustID = RR.CustID
     GROUP BY RR.CustID
     ORDER BY Sales DESC;


-- View: Q031SalesWithZip
CREATE VIEW Q031SalesWithZip AS
    SELECT Q030SalesByType.CustID,
           Sales,
           RatioEmergencySale,
           Zip
      FROM customers
           INNER JOIN
           Q030SalesByType ON customers.CustID = Q030SalesByType.CustID;


-- View: Q040SalesByGeoZip
CREATE VIEW Q040SalesByGeoZip AS
    SELECT CustID,
           Q031SalesWithZip.Zip,
           Sales,
           RatioEmergencySale,
           city,
           state,
           latitude,
           longitude
      FROM Q031SalesWithZip
           INNER JOIN
           ZipCodes ON Q031SalesWithZip.Zip = ZipCodes.zip
     ORDER BY Q031SalesWithZip.Zip ASC;


COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
