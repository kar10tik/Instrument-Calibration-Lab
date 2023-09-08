# Instrument-Calibration-Lab #
Relational Database Design for an Instrument Calibration Laboratory

## Problem Statement ##

Consider an independently operative Instrument Calibration Laboratory (ICL) accessible by industrial and academic organisations for calibrating digital and analogue electrical, thermal, mechanical, and analytical laboratory instruments. Together with the calibration managers and account manager, the chief executive officer (CEO) manages all ICL operations. The CEO deals with external organisations and supervises the account manager and the electrical, thermal, and mechanical calibration managers. The calibration managers ensure that calibration engineers (CEs) follow ISO calibration standards while calibrating instruments. The account manager manages all employee payrolls. The CEO and the managers oversee four types of operations: calibration order management, calibration process management, calibrator inventory management, and employee payroll management. 

### Calibration order management ###

1. Each calibration order is from a specific organisation and contains one or more instruments. 
2. Each instrument requiring calibration belongs to only one order. 
3. An order references only one organisation, and each organisation may have zero, one, or many orders. 
4. Each ordered item line corresponds to one inventory type, and each inventory type can be referenced by one or many order-item lines. 
5. Organisations placing calibration orders may send instruments to the ICL or request on-site calibration. 
6. If organisations send instruments to the ICL, they need to pay a shipping fee of INR 150 for pickup locations in Delhi and INR 200 elsewhere in India. 
7. The ICL uses a courier service that ensures all shipments are received within 3 days of the order date. 
8. Organisations requesting on-site visits need to specify the visit date, time, and location, arrange for a stable power supply and ambient environment, and pay a visit fee of INR 300 for visits outside Delhi and INR 250 for visits within Delhi. 

### Calibration process management ###

1. All calibrations in the ICL are performed using a digital-display calibrating device termed a calibrator. 
2. All calibrators can be set to calibrate both analog and digital instruments. 
3. A CE may calibrate zero, one, or many instruments. 
4. Each instrument needs calibration exactly one year after it was calibrated. 
5. Each calibration log entry is made by only one CE. 
6. The CE documents calibration details such as type of instrument, condition before calibration, calibration date, ambient humidity and temperature during calibration, errors, standards used, calibration cost, and units of the calibrated quantity. 
7. Each calibrated instrument is classified by class, type, and subtype. 
8. For example, an analog ammeter with range 0 – 10 mA is an instrument of class ‘analog’, type 'electrical', and subtype 'ammeter'. 

### Calibrator inventory management ###

1. The calibrator inventory comprises calibrators for thermal, mechanical, and electrical instruments grouped by type. 
2. A calibrator needs repair (recalibration) from the vendor after exactly three years after its last recalibration.
3. Each repair entry refers to only one calibrator. 
4. Each vendor may have zero, one, or many calibrators returned for repair. 
5. Each calibrator requiring repair is returned only to its original vendor. 

### Employee payroll management ###

 1. The ICL pays the CEO and managers a fixed monthly amount. 
 2. Thermal, mechanical, and electrical CEs are salaried monthly based on the days worked per month. 
 3. Each CE is assigned a work schedule (the dates and times each CE must work) with at least one day each week and each work schedule assignment is made for one CE. 
 4. The number of scheduled working days for each CE is 5. 
 5. The account manager reviews the days worked by each CE and calculates the corresponding payroll accordingly.