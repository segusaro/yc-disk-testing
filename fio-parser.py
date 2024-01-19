import os
import json
import xlsxwriter
from datetime import datetime

# script to create Excel file with fio test results from the list of fio .json output files in folder fio_results_dir/
# script add average IOPS, BW, latency data from fio results
# but you can add more columns and data from fio .json output based on example below

fio_results_dir = 'results/'
device_name = "network-ssd"
workbook = xlsxwriter.Workbook('fio-summary.xlsx')
output = workbook.add_worksheet()
bold_format = workbook.add_format()
bold_format.set_bold()
output.set_row(0, None, bold_format)
date_format = workbook.add_format({'num_format': 'dd.mm hh:mm'})
output.write('A1', 'disk type', bold_format)
output.write('B1', 'test type', bold_format)
output.write('C1', 'IOPS, K', bold_format)
output.write('D1', 'BW, MiB/s', bold_format)
output.write('E1', 'latency, usec', bold_format)
output.write('F1', 'test start datetime', bold_format)
output.write('G1', 'VM id', bold_format)
output.write('H1', 'disk id (host id for local-ssd)', bold_format)

row = 1
for filename in sorted(os.listdir(fio_results_dir)):
    f = open(fio_results_dir+filename)
    rjson = f.read()
    rdata = json.loads(rjson)

    test_info = filename.split("_")

    if test_info[1] == "rand-read":
        operation = "read"
    else:
        operation = "write"
        
    iops = round((rdata['jobs'][0][operation]['iops'])/1000, 1)
    bw = round((rdata['jobs'][0][operation]['bw'])/1024)
    latency = round((rdata['jobs'][0][operation]['lat_ns']['mean'])/1000)
    timestamp = str(test_info[2] + " " + test_info[3].replace('-',':'))

    output.write(row, 0, test_info[0])
    output.write(row, 1, test_info[1])
    output.write_number(row, 2, iops)
    output.write_number(row, 3, bw)
    output.write_number(row, 4, latency)
    output.write_datetime(row, 5, datetime.strptime(timestamp, '%Y.%m.%d %H:%M:%S'), date_format)
    output.write(row, 6, test_info[4])
    output.write(row, 7, test_info[5][:-5])
    row += 1    
   
output.autofit()
workbook.close()
